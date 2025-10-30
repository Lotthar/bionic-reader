
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../models/conversion_status.dart';
import '../../screens/reading_screen.dart';
import '../../utils/navigation_routes.dart';

class BookGridView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book) onDelete;

  const BookGridView({
    super.key,
    required this.books,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridItem(book: book, onDelete: onDelete);
      },
    );
  }
}

class BookGridItem extends StatelessWidget {
  final Book book;
  final void Function(Book book) onDelete;

  const BookGridItem({
    super.key,
    required this.book,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (book.conversionStatus == ConversionStatus.COMPLETED) {
            Navigation.goToRoute(context, ReadingScreen(bookId: book.id));
          }
        },
        onLongPress: () => onDelete(book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: book.coverImagePath != null
                  ? Image.file(
                File(book.coverImagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.book, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                book.title,
                style: textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (book.author != null && book.author!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  book.author!,
                  style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (book.conversionStatus == ConversionStatus.COMPLETED)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Left at: ${(book.lastReadPage + 1).toString()} of ${book.totalPages.toString()}',
                  style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (book.conversionStatus == ConversionStatus.CONVERTING)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LinearProgressIndicator(value: book.progress),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(book.conversionStatus.name, style: textTheme.bodySmall),
                  if (book.conversionStatus == ConversionStatus.COMPLETED)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}