import 'package:bionic_reader/models/book.dart';
import 'package:bionic_reader/models/conversion_status.dart';
import 'package:bionic_reader/services/book_cache_service.dart';
import 'package:bionic_reader/services/database_service.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:bionic_reader/widgets/home/text_pagination_actions.dart';
import 'package:bionic_reader/widgets/swipe_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../mixins/reading_screen_styles.dart';
import '../service_locator.dart';
import '../services/bionic_text_converter.dart';

class ReadingScreen extends StatefulWidget {
  final String bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> with ReadingScreenStyles {
  // --- State Variables ---
  bool _isLoading = true;
  String _statusMessage = 'Loading...';
  int _currentPageIndex = 0;
  List<String> _pages = [];
  final Map<int, List<TextSpan>> _bionicPagesCache = {};
  Book? _book;

  final BookCacheService _bookCacheService = locator<BookCacheService>();
  final DatabaseService _databaseService = locator<DatabaseService>();

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final books = await _databaseService.getAllBooks();
    final book = books.firstWhere((b) => b.id == widget.bookId);
    setState(() {
      _book = book;
      _currentPageIndex = book.lastReadPage; // Start at the last read page
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
    _convertPageInBackground(_currentPageIndex);
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
          child: _isLoading
              ? ReadingScreenStyles.loadingSpinner(60.0, context)
              : _buildDocumentContent(),
        ),
      ),
    );
  }

  Widget _convertedTextSpans(List<TextSpan> spans) {
    return SingleChildScrollView(
      child: Padding(
        padding: paddingLTRB,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: ReadingScreenStyles.maxContentWidth,
          ),
          alignment: Alignment.topLeft,
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: baseTextStyle,
              children: spans,
            ),
          ),
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

  Widget _buildDocumentContent() {
    if (_pages.isEmpty) {
      if (_book != null && _book!.conversionStatus != ConversionStatus.COMPLETED) {
        return _stillConvertingSpinner();
      }
      return _displayStatusFallback();
    }

    final List<TextSpan>? bionicSpans = _bionicPagesCache[_currentPageIndex];
    if (bionicSpans == null) {
      _convertPageInBackground(_currentPageIndex);
      return _pageConvertingSpinner();
    }
    
    return _convertedTextSpans(bionicSpans);
  }

  Future<void> _convertPageInBackground(int pageIndex) async {
    if (_bionicPagesCache.containsKey(pageIndex) || _pages.isEmpty) return;

    final payload = BionicConverterPayload(
      _pages[pageIndex],
      baseTextStyle,
      boldTextStyle,
    );
    final bionicSpans = await compute(convertPageToBionicText, payload);
    if (mounted) {
      setState(() {
        _bionicPagesCache[pageIndex] = bionicSpans;
      });
    }
  }

   Widget _stillConvertingSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReadingScreenStyles.loadingSpinner(60.0, context),
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

  Widget _pageConvertingSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReadingScreenStyles.loadingSpinner(60.0, context),
          const SizedBox(height: 16),
          Text('Converting page ${_currentPageIndex + 1}...'),
        ],
      ),
    );
  }

  Widget _displayStatusFallback() {
    return Center(
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: baseTextStyle,
      ),
    );
  }

  void _updateLastReadPage(int pageIndex) {
    if (_book != null) {
      _databaseService.updateBookLastReadPage(_book!.id, pageIndex);
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _updateLastReadPage(_currentPageIndex); // Save on page turn
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _updateLastReadPage(_currentPageIndex); // Save on page turn
      });
    }
  }
}
