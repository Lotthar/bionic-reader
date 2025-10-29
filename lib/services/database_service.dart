import 'dart:async';

import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/book_metadata.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  final _booksController = StreamController<List<Book>>.broadcast();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'book_library.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        filePath TEXT,
        title TEXT,
        author TEXT,
        coverImage TEXT,
        conversionStatus TEXT,
        progress REAL,
        totalPages INTEGER,
        lastReadPage INTEGER 
      )
    ''');
  }

  Stream<List<Book>> watchAllBooks() {
    getAllBooks().then((books) => _booksController.add(books));
    return _booksController.stream;
  }

  Future<void> addBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _notifyListeners();
  }
  
  Future<void> updateBookDetails(String id, BookMetadata metadata) async {
    final db = await database;
    final Map<String, dynamic> data = {
      'title': metadata.title,
      'author': metadata.author,
    };
    await db.update('books', data, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> updateBookLastReadPage(String id, int page) async {
    final db = await database;
    await db.update('books', {'lastReadPage': page}, where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<void> updateBookStatus(String id, ConversionStatus status,
      {double? progress, int? totalPages}) async {
    final db = await database;
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
    final db = await database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
    _notifyListeners();
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
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
