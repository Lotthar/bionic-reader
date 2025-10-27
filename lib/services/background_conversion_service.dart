import 'dart:async';
import 'dart:isolate';

import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database_service.dart';
import 'package:bionic_reader/services/document_loader_service.dart';
import 'package:flutter/services.dart';

import '../utils/text_sanitization.dart';

class BackgroundConversionService {
  static final BackgroundConversionService _instance =
      BackgroundConversionService._internal();
  factory BackgroundConversionService() => _instance;
  BackgroundConversionService._internal();

  final _databaseService = DatabaseService();
  bool _isProcessing = false;

  Future<void> processQueue() async {
    if (_isProcessing) return;

    try {
      final books = await _databaseService.getAllBooks();
      final queuedBook = books.firstWhere(
        (book) => book.conversionStatus == ConversionStatus.QUEUED,
      );

      _isProcessing = true;
      await _databaseService.updateBookStatus(
          queuedBook.id, ConversionStatus.CONVERTING);

      final receivePort = ReceivePort();
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw Exception("Failed to get RootIsolateToken");
      }
      
      await Isolate.spawn(
          _conversionIsolate, [receivePort.sendPort, queuedBook, rootIsolateToken]);

      receivePort.listen((data) {
        if (data is double) {
          _databaseService.updateBookStatus(queuedBook.id, ConversionStatus.CONVERTING,
              progress: data);
        } else if (data is int) {
            _databaseService.updateBookStatus(queuedBook.id, ConversionStatus.COMPLETED,
                progress: 1.0, totalPages: data);
            _isProcessing = false;
            processQueue();
        } else if (data is String) {
          _databaseService.updateBookStatus(
              queuedBook.id, ConversionStatus.FAILED);
          _isProcessing = false;
          processQueue();
        }
      });
    } catch (e) {
      // No queued books
      _isProcessing = false;
    }
  }

  static void _conversionIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    Book book = args[1];
    RootIsolateToken rootIsolateToken = args[2];
    
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    
    final docLoader = DocumentLoaderService();
    final cacheService = BookCacheService();

    try {
      final fullText = await docLoader.loadPdfTextFromPath(book.filePath);
      final sanitizedText = TextSanitizer(fullText).sanitizedText;
      // --- REPLACEMENT PAGINATION LOGIC ---
      // This logic avoids using TextPainter and the Flutter engine.
      const int charsPerPage = 1500; // Approximate characters per page.
      final List<String> pages = [];
      int startIndex = 0;
      while (startIndex < sanitizedText.length) {
        int endIndex = startIndex + charsPerPage;
        if (endIndex > sanitizedText.length) {
          endIndex = sanitizedText.length;
        } else {
          // Try to end on a whitespace to avoid splitting words.
          int lastSpace = sanitizedText.lastIndexOf(RegExp(r'\s'), endIndex);
          if (lastSpace > startIndex) {
            endIndex = lastSpace;
          }
        }
        pages.add(sanitizedText.substring(startIndex, endIndex).trim());
        startIndex = endIndex;
      }
      // --- END OF REPLACEMENT LOGIC ---

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
}
