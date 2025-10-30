const String createBooksTable = '''
  CREATE TABLE books (
    id TEXT PRIMARY KEY,
    filePath TEXT,
    title TEXT,
    author TEXT,
    coverImagePath TEXT,
    conversionStatus TEXT,
    progress REAL,
    totalPages INTEGER,
    lastReadPage INTEGER 
  )
''';

// Add other table creation strings here in the future
// const String createUserPrefsTable = ''' ... ''';

/// A list of all table creation statements.
/// This is used by the DatabaseProvider to initialize the database.
final List<String> allTables = [
  createBooksTable,
  // createUserPrefsTable,
];
