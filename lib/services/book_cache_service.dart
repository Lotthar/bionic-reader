import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BookCacheService {
  Future<Directory> _getCacheDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(dir.path, 'book_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> savePage(String bookId, int pageIndex, String pageContent) async {
    final cacheDir = await _getCacheDirectory();
    final bookDir = Directory(p.join(cacheDir.path, bookId));
    if (!await bookDir.exists()) {
      await bookDir.create(recursive: true);
    }
    final file = File(p.join(bookDir.path, '$pageIndex.txt'));
    await file.writeAsString(pageContent);
  }

  Future<String?> loadPage(String bookId, int pageIndex) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File(p.join(cacheDir.path, bookId, '$pageIndex.txt'));
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteBookCache(String bookId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final bookDir = Directory(p.join(cacheDir.path, bookId));
      if (await bookDir.exists()) {
        await bookDir.delete(recursive: true);
      }
    } catch (e) {
      // Handle exceptions
    }
  }
}
