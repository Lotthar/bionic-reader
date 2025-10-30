import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A generic database provider responsible only for initializing and providing
/// the database connection. It is completely agnostic of any table structure.
class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  Database? _database;
  bool _isInitialized = false;

  /// Initializes the database with a specific name and a list of SQL statements
  /// to execute on creation. This must be called once before the database is accessed.
  Future<void> init({
    required String dbName,
    required List<String> tableCreationSqls,
  }) async {
    if (_isInitialized) {
      debugPrint("DatabaseProvider already initialized.");
      return;
    }

    String path = join(await getDatabasesPath(), dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (final sql in tableCreationSqls) {
          await db.execute(sql);
        }
      },
    );
    _isInitialized = true;
  }

  /// Provides the database connection. Throws an error if `init` has not been called.
  Future<Database> get database async {
    if (!_isInitialized || _database == null) {
      throw Exception(
          "DatabaseProvider not initialized. Call `init()` before accessing the database.");
    }
    return _database!;
  }
}
