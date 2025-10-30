
import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../models/conversion_status.dart';
import '../../screens/reading_screen.dart';
import '../../utils/navigation_routes.dart';

class BookListView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book) onDelete;

  const BookListView({
    super.key,
    required this.books,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListItem(book: book, onDelete: onDelete);
      },
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;
  final void Function(Book book) onDelete;

  const BookListItem({
    super.key,
    required this.book,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: book.coverImagePath != null
          ? Image.file(File(book.coverImagePath!), width: 40, fit: BoxFit.cover)
          : const Icon(Icons.book, size: 40),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (book.author != null && book.author!.isNotEmpty)
            Text(
              book.author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 4),
          book.conversionStatus == ConversionStatus.CONVERTING
              ? LinearProgressIndicator(value: book.progress)
              : Text(book.conversionStatus.name),
        ],
      ),
      trailing: book.conversionStatus == ConversionStatus.COMPLETED
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const SizedBox.shrink(),
      onTap: () {
        if (book.conversionStatus == ConversionStatus.COMPLETED) {
          Navigation.goToRoute(context, ReadingScreen(bookId: book.id));
        }
      },
      onLongPress: () => onDelete(book),
    );
  }
}

