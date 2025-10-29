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
  bool _isGridView = true;

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
          if (state.status == LibraryStatus.loading || state.status == LibraryStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LibraryStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'An error occurred'));
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
        onPressed: () => context.read<LibraryCubit>().pickAndAddNewBook(),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4,
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
      leading: const Icon(Icons.book), // Placeholder for cover image
      title: Text(book.title),
      subtitle: book.conversionStatus == ConversionStatus.CONVERTING
          ? LinearProgressIndicator(value: book.progress)
          : Text(book.conversionStatus.name),
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
    return Card(
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
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.book, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  Text(book.conversionStatus.name),
                  if (book.conversionStatus == ConversionStatus.COMPLETED)
                    const Icon(Icons.check_circle, color: Colors.green),
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
