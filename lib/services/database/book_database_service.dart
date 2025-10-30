import 'dart:async';

import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/book_metadata.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class BookDatabaseService {
  final DatabaseProvider _dbProvider;
  final _booksController = StreamController<List<Book>>.broadcast();

  BookDatabaseService(this._dbProvider);

  Stream<List<Book>> watchAllBooks() {
    _notifyListeners(); // Initial data push
    return _booksController.stream;
  }

  Future<void> addBook(Book book) async {
    final db = await _dbProvider.database;
    await db.insert('books', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _notifyListeners();
  }
  
  Future<void> updateBookDetails(String id, BookMetadata metadata) async {
    final db = await _dbProvider.database;
    final Map<String, dynamic> data = {
      'title': metadata.title,
      'author': metadata.author,
    };
    await db.update('books', data, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> updateBookCover(String id, String coverImagePath) async {
    final db = await _dbProvider.database;
    await db.update('books', {'coverImagePath': coverImagePath}, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> updateBookLastReadPage(String id, int page) async {
    final db = await _dbProvider.database;
    await db.update('books', {'lastReadPage': page}, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> updateBookStatus(String id, ConversionStatus status,
      {double? progress, int? totalPages}) async {
    final db = await _dbProvider.database;
    final Map<String, dynamic> data = {
      'conversionStatus': status.name,
    };
    if (progress != null) {
      data['progress'] = progress;
    }
    if (totalPages != null) {
      data['totalPages'] = totalPages;
    }
    await db.update('books', data, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    final db = await _dbProvider.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<List<Book>> getAllBooks() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<void> _notifyListeners() async {
    final books = await getAllBooks();
    _booksController.add(books);
  }

  void dispose() {
    _booksController.close();
  }
}
