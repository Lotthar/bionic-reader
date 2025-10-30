import 'package:bionic_reader/bloc/library_cubit.dart';
import 'package:bionic_reader/bloc/library_state.dart';
import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:bionic_reader/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/library/book_grid_view.dart';
import '../widgets/library/book_list_view.dart';

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
        title: Text('Library'),
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
      body: LibraryBody(
        isGridView: _isGridView,
        onDelete: (book) => _showDeleteConfirmation(context, book),
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

  void _showDeleteConfirmation(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text('Are you sure you want to delete "${book.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Use the original screen's context to find the cubit
                context.read<LibraryCubit>().deleteBook(book.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/// The body of the LibraryScreen, responsible for displaying the list of books.
class LibraryBody extends StatelessWidget {
  final bool isGridView;
  final void Function(Book book) onDelete;

  const LibraryBody({
    super.key,
    required this.isGridView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryStatus.loading || state.status == LibraryStatus.initial) {
          return const Center(child: LoadingSpinner(size: 20.0));
        }
        if (state.status == LibraryStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'An error occurred'));
        }
        if (state.books.isEmpty) {
          return const Center(child: Text('No books in your library.'));
        }
        return isGridView
            ? BookGridView(books: state.books, onDelete: onDelete)
            : BookListView(books: state.books, onDelete: onDelete);
      },
    );
  }
}




