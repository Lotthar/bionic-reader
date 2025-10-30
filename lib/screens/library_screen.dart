import 'dart:io';

import 'package:bionic_reader/bloc/library_cubit.dart';
import 'package:bionic_reader/bloc/library_state.dart';
import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/screens/reading_screen.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Library',
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.view_module),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state.status == LibraryStatus.loading ||
              state.status == LibraryStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LibraryStatus.failure) {
            return Center(
                child: Text(state.errorMessage ?? 'An error occurred'));
          }
          if (state.books.isEmpty) {
            return const Center(child: Text('No books in your library.'));
          }
          return _isGridView
              ? BookGridView(books: state.books)
              : BookListView(books: state.books);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final screenSize = MediaQuery.of(context).size;
          context.read<LibraryCubit>().pickAndAddNewBook(screenSize);
        },
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BookListView extends StatelessWidget {
  final List<Book> books;
  const BookListView({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListItem(book: book);
      },
    );
  }
}

class BookGridView extends StatelessWidget {
  final List<Book> books;
  const BookGridView({super.key, required this.books});

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
        return BookGridItem(book: book);
      },
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;
  const BookListItem({super.key, required this.book});

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingScreen(bookId: book.id),
            ),
          );
        }
      },
      onLongPress: () => _showDeleteConfirmation(context, book),
    );
  }
}

class BookGridItem extends StatelessWidget {
  final Book book;
  const BookGridItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (book.conversionStatus == ConversionStatus.COMPLETED) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(bookId: book.id),
              ),
            );
          }
        },
        onLongPress: () => _showDeleteConfirmation(context, book),
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

void _showDeleteConfirmation(BuildContext context, Book book) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              context.read<LibraryCubit>().deleteBook(book.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
