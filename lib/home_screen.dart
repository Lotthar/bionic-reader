import 'package:bionic_reader/mixins/reader_screen_styles.dart';
import 'package:bionic_reader/services/document_loader_service.dart';
import 'package:bionic_reader/services/text_converter_service.dart';
import 'package:bionic_reader/services/text_pagination_service.dart';
import 'package:bionic_reader/widgets/pagination_actions.dart';
import 'package:flutter/material.dart';

class BionicReaderHomeScreen extends StatefulWidget {
  final String title;
  const BionicReaderHomeScreen({super.key, required this.title});

  @override
  State<BionicReaderHomeScreen> createState() => _BionicReaderScreenState();
}

class _BionicReaderScreenState extends State<BionicReaderHomeScreen> with BionicReaderScreenStyles{
  // --- State Variables ---
  bool _isLoading = false;
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
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: _buildPaginationActions(),
          ),
          body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _buildDocumentContent(),
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
      onPreviousPage: () => setState(() {
        if (_currentPageIndex > 0) {
          _currentPageIndex--;
        }
      }),
      onNextPage: () => setState(() {
        if (_currentPageIndex < _pages.length - 1) {
          _currentPageIndex++;
        }
      }),
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
    if (_pages.isEmpty || bionicSpans == null) return _statusFallback();
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


    // After the stream is done, update the status
    if (mounted) {
      setState(() {
        _statusMessage = 'Document loaded: ${_pages.length} pages.';
      });
    }
  }

  Future<void> _convertIncomingPaginatedText(Stream<String> incomingPages) async {
    bool isFirstPage = true;
    await for (final pageText in incomingPages) {
      if (!mounted) return;

      _pages.add(pageText);
      final newPageIndex = _pages.length - 1;
      if (isFirstPage) {
        // For the first page, convert it synchronously and update the UI
        _bionicPagesCache[0] = _convertPageToBionicText(_pages[0]);
        setState(() {
          _currentPageIndex = 0;
          _isLoading = false; // We have content to show, so stop loading indicator
          _statusMessage = 'Page 1 loaded. More pages loading...';
        });
        isFirstPage = false;
      } else {
        setState(() {
          _statusMessage = 'Document loaded: ${_pages.length} pages. Converting...';
        });
      }
      if (newPageIndex > 0) _convertPageInBackground(newPageIndex);
    }
  }

  List<TextSpan> _convertPageToBionicText(String pageText) {
    final converter = BionicTextConverter(
      baseStyle: baseTextStyle,
      boldStyle: boldTextStyle,
      fixateLength: 3,
    );
    return converter.convert(pageText);
  }

  void _convertPageInBackground(int pageIndex) async {
    await Future.microtask(() {
      if (!mounted || _bionicPagesCache.containsKey(pageIndex)) return;
      final bionicSpans = _convertPageToBionicText(_pages[pageIndex]);
      _bionicPagesCache[pageIndex] = bionicSpans;

      if (_currentPageIndex == pageIndex) {
        setState(() {});
      }
    });
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

  Widget _statusFallback() {
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
}
