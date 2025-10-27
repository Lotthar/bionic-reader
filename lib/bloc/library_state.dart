import 'package:bionic_reader/models/book.dart';
import 'package:equatable/equatable.dart';

enum LibraryStatus { initial, loading, success, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.books = const <Book>[],
    this.errorMessage,
  });

  final LibraryStatus status;
  final List<Book> books;
  final String? errorMessage;

  LibraryState copyWith({
    LibraryStatus? status,
    List<Book>? books,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      books: books ?? this.books,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, books, errorMessage];
}
