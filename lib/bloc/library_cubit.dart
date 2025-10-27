import 'dart:async';

import 'package:bionic_reader/bloc/library_state.dart';
import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/background_conversion_service.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final DatabaseService _databaseService;
  final BackgroundConversionService _conversionService;
  final BookCacheService _bookCacheService;
  late final StreamSubscription<List<Book>> _bookSubscription;

  LibraryCubit(this._databaseService, this._conversionService, this._bookCacheService)
      : super(const LibraryState()) {
    _bookSubscription = _databaseService.watchAllBooks().listen((books) {
      emit(state.copyWith(status: LibraryStatus.success, books: books));
    });
  }

  Future<void> pickAndAddNewBook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        await addNewBook(result.files.single.path!);
      }
    } catch (e) {
      emit(state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: 'Failed to pick a file.'));
    }
  }

  Future<void> addNewBook(String filePath) async {
    final book = Book(
      id: const Uuid().v4(),
      filePath: filePath,
      title: p.basenameWithoutExtension(filePath),
      conversionStatus: ConversionStatus.QUEUED,
    );
    await _databaseService.addBook(book);
    _conversionService.processQueue();
  }

  Future<void> deleteBook(String id) async {
    await _databaseService.deleteBook(id);
    await _bookCacheService.deleteBookCache(id);
  }

  @override
  Future<void> close() {
    _bookSubscription.cancel();
    return super.close();
  }
}
