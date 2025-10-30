import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/book_metadata.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database/book_database_service.dart';
import 'package:bionic_reader/services/cover_image_service.dart';
import 'package:bionic_reader/services/document_loader_service.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../service_locator.dart';
import '../utils/text_sanitization.dart';

class BackgroundConversionService {
  static final BackgroundConversionService _instance =
      BackgroundConversionService._internal();
  factory BackgroundConversionService() => _instance;
  BackgroundConversionService._internal();

  final _bookDatabaseService = locator<BookDatabaseService>();
  bool _isProcessing = false;

  Future<void> processQueue([Size? screenSize]) async {
    if (_isProcessing) return;
    try {
      final books = await _bookDatabaseService.getAllBooks();
      final queuedBook = books.firstWhere(
        (book) => book.conversionStatus == ConversionStatus.QUEUED,
      );
      _isProcessing = true;
      await _bookDatabaseService.updateBookStatus(
          queuedBook.id, ConversionStatus.CONVERTING);

      _handleQueuedBookConversionProcessing(queuedBook, screenSize);
    } catch (e) {
      _isProcessing = false;
    }
  }

  void _handleQueuedBookConversionProcessing(Book queuedBook, Size? screenSize) async {
    final receivePort = ReceivePort();
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) throw Exception("Failed to get RootIsolateToken");
    await Isolate.spawn(
        _conversionIsolate, [receivePort.sendPort, queuedBook, rootIsolateToken, screenSize]);

    receivePort.listen((data) {
      if (data is BookMetadata) {
        _bookDatabaseService.updateBookDetails(queuedBook.id, data);
      } else if (data is String && data.startsWith('coverPath:')) {
        _bookDatabaseService.updateBookCover(queuedBook.id, data.substring(10));
      } else if (data is double) {
        _bookDatabaseService.updateBookStatus(queuedBook.id, ConversionStatus.CONVERTING,progress: data);
      } else if (data is int) {
        _bookDatabaseService.updateBookStatus(queuedBook.id, ConversionStatus.COMPLETED, progress: 1.0, totalPages: data);
        _isProcessing = false;
        processQueue();
      } else if (data is String) {
        _bookDatabaseService.updateBookStatus(queuedBook.id, ConversionStatus.FAILED);
        _isProcessing = false;
        processQueue();
      }
    });
  }

  static void _conversionIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    Book book = args[1];
    RootIsolateToken rootIsolateToken = args[2];
    Size? screenSize = args[3];
    
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    
    final docLoader = DocumentLoaderService();
    final cacheService = BookCacheService();
    final coverImageService = CoverImageService();

    try {
      final imageBytes = await coverImageService.extractCoverImage(book.filePath);
      if (imageBytes != null) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String coverPath = p.join(appDocDir.path, 'covers', '${book.id}.png');
        final File coverFile = File(coverPath);
        await coverFile.create(recursive: true);
        await coverFile.writeAsBytes(imageBytes);
        sendPort.send('coverPath:$coverPath');
      }

      final pdfDoc = await docLoader.loadPdfDocFromPath(book.filePath);
      
      final info = pdfDoc.info;
      final metadata = BookMetadata(
        title: info.title ?? book.title,
        author: info.author,
      );
      sendPort.send(metadata);

      final fullText = await pdfDoc.text;
      final sanitizedText = TextSanitizer(fullText).sanitizedText;

      final List<String> pages = _approximateCharsPerPage(sanitizedText, screenSize: screenSize);

      int totalPages = pages.length;

      for (int i = 0; i < totalPages; i++) {
        await cacheService.savePage(book.id, i, pages[i]);
        sendPort.send((i + 1) / totalPages);
      }
      sendPort.send(totalPages);
    } catch (e) {
      sendPort.send(e.toString());
    }
  }

  static List<String> _approximateCharsPerPage(String sanitizedText, {Size? screenSize}) {
    int charsPerPage;
    if (screenSize != null) {
      charsPerPage = (screenSize.width * screenSize.height / 250).round();
    } else {
      charsPerPage = 1500;
    }
    final List<String> pages = [];
    int startIndex = 0;
    while (startIndex < sanitizedText.length) {
      int endIndex = startIndex + charsPerPage;
      if (endIndex > sanitizedText.length) {
        endIndex = sanitizedText.length;
      } else {
        int lastSpace = sanitizedText.lastIndexOf(RegExp(r'\s'), endIndex);
        if (lastSpace > startIndex) {
          endIndex = lastSpace;
        }
      }
      pages.add(sanitizedText.substring(startIndex, endIndex).trim());
      startIndex = endIndex;
    }
    return pages;
  }
}
