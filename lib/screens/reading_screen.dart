import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/bionic_text_converter_service.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database/book_database_service.dart';
import 'package:bionic_reader/theme/app_theme.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:bionic_reader/widgets/home/text_pagination_actions.dart';
import 'package:bionic_reader/widgets/loading_spinner.dart';
import 'package:bionic_reader/widgets/swipe_detector.dart';
import 'package:flutter/material.dart';

import '../service_locator.dart';

class ReadingScreen extends StatefulWidget {
  final String bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool _isLoading = true;
  String _statusMessage = 'Loading...';
  int _currentPageIndex = 0;
  List<String> _pages = [];
  final Map<int, List<TextSpan>> _bionicPagesCache = {};
  Book? _book;

  final BookCacheService _bookCacheService = locator<BookCacheService>();
  final BookDatabaseService _bookDbService = locator<BookDatabaseService>();

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final books = await _bookDbService.getAllBooks();
    final book = books.firstWhere((b) => b.id == widget.bookId);
    setState(() {
      _book = book;
      _currentPageIndex = book.lastReadPage;
    });
    _loadPages();
  }

  Future<void> _loadPages() async {
    if (_book == null) return;
    List<String> loadedPages = [];
    for (int i = 0; i < _book!.totalPages; i++) {
      final pageContent = await _bookCacheService.loadPage(_book!.id, i);
      if (pageContent != null) {
        loadedPages.add(pageContent);
      } else {
        loadedPages.add('Error: Could not load page $i');
      }
    }
    setState(() {
      _pages = loadedPages;
      _isLoading = false;
      _statusMessage = '';
    });
    convertPageToBionicText(_currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _book?.title ?? 'Bionic Reader',
        actions: _buildPaginationActions(),
      ),
      drawer: const CustomDrawer(),
      body: SwipeDetector(
        onSwipeLeft: _nextPage,
        onSwipeRight: _previousPage,
        child: Center(
          child:
              _isLoading ? const LoadingSpinner() : _buildReadingPageContent(),
        ),
      ),
    );
  }

  List<Widget>? _buildPaginationActions() {
    final actionsHelper = PaginationActions(
      _pages,
      _isLoading,
      _currentPageIndex,
      onPreviousPage: _previousPage,
      onNextPage: _nextPage,
    );
    return actionsHelper.buildPaginationActions();
  }

  Widget _buildReadingPageContent() {
    if (_pages.isNotEmpty) {
      final List<TextSpan> bionicTextSpans =
          convertPageToBionicText(_currentPageIndex);
      return _displayPageTextSpans(bionicTextSpans);
    }
    if (_book != null && _book!.conversionStatus != ConversionStatus.COMPLETED) {
      return _stillConvertingSpinner();
    }
    return _displayStatusFallback();
  }

  List<TextSpan> convertPageToBionicText(int pageIndex) {
    List<TextSpan>? result = _bionicPagesCache[pageIndex];
    if (result == null) {
      final bionicConverterService = BionicTextConverterService(
        Theme.of(context).xTextStyles.body,
        Theme.of(context).xTextStyles.bodyBold,
      );
      result = bionicConverterService.convert(_pages[pageIndex]);
      setState(() {
        _bionicPagesCache[pageIndex] = result!;
      });
    }
    return result;
  }

  Widget _displayPageTextSpans(List<TextSpan> spans) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 60.0),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 700.0,
          ),
          alignment: Alignment.topLeft,
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: Theme.of(context).xTextStyles.body,
              children: spans,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stillConvertingSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingSpinner(),
          const SizedBox(height: 16),
          const Text('Book is still being converted...'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadPages,
            child: const Text('Refresh'),
          )
        ],
      ),
    );
  }

  Widget _displayStatusFallback() {
    return Center(
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: Theme.of(context).xTextStyles.body,
      ),
    );
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _updateLastReadPage(_currentPageIndex);
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _updateLastReadPage(_currentPageIndex);
      });
    }
  }

  void _updateLastReadPage(int pageIndex) {
    if (_book != null) {
      _bookDbService.updateBookLastReadPage(_book!.id, pageIndex);
    }
  }
}
