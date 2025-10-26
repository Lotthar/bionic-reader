import 'dart:developer';

import 'package:bionic_reader/mixins/reader_screen_styles.dart';
import 'package:bionic_reader/services/document_loader_service.dart';
import 'package:bionic_reader/services/text_pagination_service.dart';
import 'package:bionic_reader/utils/bionic_conversion_isolate.dart';
import 'package:bionic_reader/widgets/custom_app_bar.dart';
import 'package:bionic_reader/widgets/custom_drawer.dart';
import 'package:bionic_reader/widgets/swipe_detector.dart';
import 'package:bionic_reader/widgets/home/text_pagination_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReaderScreen extends StatefulWidget {

  const ReaderScreen({super.key });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with BionicReaderScreenStyles{
  // --- State Variables ---
  bool _isLoading = false;
  bool _allPagesConverted = false;
  String _statusMessage = 'Tap to select a document';
  int _currentPageIndex = 0; // 0-based index for the current page
  List<String> _pages = []; // List to hold paginated text content
  final Map<int, List<TextSpan>> _bionicPagesCache = {};

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides the necessary constraints (width and height) for dynamic pagination
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Bionic Reader',
            actions: !_isLoading && _pages.isNotEmpty && !_allPagesConverted ?
                BionicReaderScreenStyles.pagesNavigationPlaceholder :
                _buildPaginationActions(),
          ),
          drawer: const CustomDrawer(),
          body: SwipeDetector(
            onSwipeLeft: _nextPage,
            onSwipeRight: _previousPage,
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _buildDocumentContent(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // Pass constraints to the file picker function so it can paginate immediately after loading.
            onPressed: () => _pickAndConvertFile(constraints),
            tooltip: 'Select Document',
            child: const Icon(Icons.upload_file),
          ),
        );
      },
    );
  }

  Widget _convertedTextSpans(List<TextSpan> spans) {
    return SingleChildScrollView(
      child: Padding(
        padding: paddingLTRB,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: BionicReaderScreenStyles.maxContentWidth,
          ),
          alignment: Alignment.topLeft,
          // NEW: Use RichText to display the list of TextSpan
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              // The base style is necessary for general font properties (line height, etc.)
              style: baseTextStyle,
              children: spans, // Pass the converted list of spans
            ),
          ),
        ),
      ),
    );
  }

  // How you would use it in the AppBar:
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

  /// Builds the main reading area, applying book-style padding and constraints.
  Widget _buildDocumentContent() {
    // 1. Check the cache for the converted bionic page
    final List<TextSpan>? bionicSpans = _bionicPagesCache[_currentPageIndex];
    // 2. If the current page hasn't been converted yet (loading async), show a spinner
    if (_pages.isNotEmpty && bionicSpans == null) return _fileConvertingSpinner();
    // Fallback for initial state or error state if cache is empty
    if (_pages.isEmpty || bionicSpans == null) return _displayStatusFallback();
    // 3. Use RichText to display the converted TextSpans
    return _convertedTextSpans(bionicSpans);
  }

  void _pickAndConvertFile(BoxConstraints constraints) async {
    setState(() {
      _isLoading = true;
      _pages = [];
      _bionicPagesCache.clear();
      _statusMessage = 'Loading document...';
    });

    try {
      final loader = DocumentLoaderService();
      String fullText = await loader.loadPdfText();
      await _setPagesFromStream(fullText, constraints);
    } on FileLoaderException catch (e) {
      _handleFileLoaderException(e);
    } catch (e) {
      _handlePickAndConvertFileException(e);
    }
  }

  Future<void> _setPagesFromStream(String fullText, BoxConstraints constraints) async {
    final paginationService = TextPaginationService(
      horizontalPadding: horizontalPadding,
      verticalPadding: totalVerticalPadding / 2,
      textStyle: baseTextStyle,
      appBarHeight: kToolbarHeight,
      boxConstraints: constraints
    );
    _pages.clear();
    _bionicPagesCache.clear();

    final streamOfPages = paginationService.paginateText(fullText);
    await _convertIncomingPaginatedText(streamOfPages);

    log('All pages are converted');
    setState(() {
      _statusMessage = 'Document loaded: ${_pages.length} pages.';
      _allPagesConverted = true;
    });
  }

  Future<void> _convertIncomingPaginatedText(Stream<String> incomingPages) async {
    bool isFirstPage = true;
    await for (final pageText in incomingPages) {
      _pages.add(pageText);
      final newPageIndex = _pages.length - 1;
      if (isFirstPage) {
        // For the first page, convert it synchronously and update the UI
        await _convertPageInBackground(0);
        setState(() {
          _currentPageIndex = 0;
          _isLoading = false; // We have content to show, so stop loading indicator
          _statusMessage = 'Page 1 loaded. More pages loading...';
        });
        log('First page is converted, continuing with rest of the pages in BG...');
        isFirstPage = false;
      }
      if (newPageIndex > 0) _convertPageInBackground(newPageIndex);
    }
  }

  Future<void> _convertPageInBackground(int pageIndex) async {
    if (_bionicPagesCache.containsKey(pageIndex)) return;
    final payload = BionicConverterPayload(
      _pages[pageIndex],
      baseTextStyle,
      boldTextStyle,
    );
    final bionicSpans = await compute(convertPageToBionicTextIsolate, payload);
    if(mounted) {
      setState(() {
        _bionicPagesCache[pageIndex] = bionicSpans;
      });
    }
  }

  Widget _fileConvertingSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
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

  void _handleFileLoaderException(FileLoaderException e) {
    setState(() {
      _statusMessage = 'Load Failed: ${e.message}';
      _pages = [e.message]; // Display error on page
      _bionicPagesCache.clear();
      _isLoading = false;
    });
  }

  void _handlePickAndConvertFileException(Object e) {
    setState(() {
      _statusMessage = 'An unexpected error occurred: ${e.toString()}';
      _pages = [_statusMessage];
      _bionicPagesCache.clear();
      _isLoading = false;
    });
  }

  // --- Navigation Methods ---
  void _nextPage() {
    if (!_allPagesConverted) return;
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _previousPage() {
    if (!_allPagesConverted) return;
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }
}
