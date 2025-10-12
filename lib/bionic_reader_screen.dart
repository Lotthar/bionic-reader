import 'package:bionic_reader/services/bionic_text_converter_service.dart';
import 'package:bionic_reader/services/document_loader_service.dart';
import 'package:bionic_reader/services/text_pagination_service.dart';
import 'package:bionic_reader/widgets/pagination_actions.dart';
import 'package:flutter/material.dart';

class BionicReaderHomeScreen extends StatefulWidget {
  final String title;
  const BionicReaderHomeScreen({super.key, required this.title});

  @override
  State<BionicReaderHomeScreen> createState() => _BionicReaderScreenState();
}

class _BionicReaderScreenState extends State<BionicReaderHomeScreen> {
  // --- State Variables ---
  List<String> _pages = []; // List to hold paginated text content
  final Map<int, List<TextSpan>> _bionicPagesCache = {};
  int _currentPageIndex = 0; // 0-based index for the current page
  bool _isLoading = false;
  String _statusMessage = 'Tap to select a document';

  // --- Configuration for Book Format ---
  final double _horizontalPadding = 32.0;
  final double _verticalTopPadding = 32.0; // Explicit constant for top padding
  final double _verticalBottomPadding = 64.0; // Explicit, larger constant for bottom padding
  // Standard max width for comfortable reading on large screens
  static const double _maxContentWidth = 700.0;

  // NEW: Utility Styles for Bionic Conversion
  TextStyle get _baseTextStyle => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontSize: 18.0,
    height: 1.5,
    color: Colors.black, // Default color for unbolded text
  );

  TextStyle get _boldTextStyle => _baseTextStyle.copyWith(
    fontWeight: FontWeight.w900,
    color: Theme.of(context).colorScheme.primary, // Highlight color
  );

  // NEW: Conversion and Async Logic
  List<TextSpan> _convertPageToBionic(String pageText) {
    final converter = BionicTextConverter(
      baseStyle: _baseTextStyle,
      boldStyle: _boldTextStyle,
      fixateLength: 3,
    );
    return converter.convert(pageText);
  }

  void _startAsyncConversion() async {
    // Start from page 1, as page 0 is converted synchronously in _setPages
    for (int i = 1; i < _pages.length; i++) {
      // Use microtask to ensure this runs off the main event loop queue
      await Future.microtask(() {
        if (!_bionicPagesCache.containsKey(i)) {
          final bionicSpans = _convertPageToBionic(_pages[i]);
          _bionicPagesCache[i] = bionicSpans;

          // Only trigger a rebuild if the newly converted page is the one the user is viewing
          if (_currentPageIndex == i && mounted) {
            setState(() {});
          }
        }
      });
    }
  }

  void _setPages(String fullText, BoxConstraints constraints) {
    // Use _baseTextStyle for pagination service measurement
    final TextStyle paginationStyle = _baseTextStyle;
    final double totalVerticalPadding = _verticalTopPadding + _verticalBottomPadding;

    final service = TextPaginationService(
      horizontalPadding: _horizontalPadding,
      verticalPadding: totalVerticalPadding / 2,
      textStyle: paginationStyle, // Use the base style for accurate measurement
      appBarHeight: kToolbarHeight,
    );

    final newPlainPages = service.paginateTextToFit(fullText, constraints);

    // 1. Update the plain page list and clear the cache
    _bionicPagesCache.clear();
    _pages = newPlainPages;

    if (_pages.isEmpty) {
      _pages = ['Document is empty or could not be processed.'];
    }

    // 2. Convert the first page (index 0) synchronously for immediate display
    _bionicPagesCache[0] = _convertPageToBionic(_pages[0]);

    setState(() {
      _currentPageIndex = 0;
      _statusMessage = 'Document loaded: ${_pages.length} pages. Converting...';
      // Note: _isLoading is set to false in _pickAndConvertFile
    });

    // 3. Start the async background conversion for the rest
    if (_pages.length > 1) {
      _startAsyncConversion();
    }
  }

  void _pickAndConvertFile(BoxConstraints constraints) async {
    setState(() {
      _isLoading = true;
      _pages = []; // Assuming you use _pages now, not _pages
      _statusMessage = 'Loading document...';
    });

    try {
      final loader = DocumentLoaderService();
      String fullText = await loader.loadPdfText();

      _setPages(fullText, constraints);

    } on FileLoaderException catch (e) {
      setState(() {
        _statusMessage = 'Load Failed: ${e.message}';
        _pages = [e.message]; // Display error on page
        _bionicPagesCache.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An unexpected error occurred: ${e.toString()}';
        _pages = [_statusMessage];
        _bionicPagesCache.clear();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Existing state methods, now acting as callbacks:
  void _goToPreviousPage() {
    setState(() {
      if (_currentPageIndex > 0) {
        _currentPageIndex--;
      }
    });
  }

  void _goToNextPage() {
    setState(() {
      if (_currentPageIndex < _pages.length - 1) {
        _currentPageIndex++;
      }
    });
  }

// How you would use it in the AppBar:
  List<Widget>? _buildPaginationActions() {
    final actionsHelper = PaginationActions(
      _pages,
      _isLoading,
      _currentPageIndex,
      onPreviousPage: _goToPreviousPage,
      onNextPage: _goToNextPage,
    );
    return actionsHelper.buildPaginationActions();
  }

  /// Builds the main reading area, applying book-style padding and constraints.
  Widget _buildDocumentContent() {
    // 1. Check the cache for the converted bionic page
    final List<TextSpan>? bionicSpans = _bionicPagesCache[_currentPageIndex];

    // 2. If the current page hasn't been converted yet (loading async), show a spinner
    if (_pages.isNotEmpty && bionicSpans == null) {
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

    // Fallback for initial state or error state if cache is empty
    if (_pages.isEmpty || bionicSpans == null) {
      return Center(
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: _baseTextStyle,
        ),
      );
    }

    // 3. Use RichText to display the converted TextSpans
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _horizontalPadding,
          _verticalTopPadding,
          _horizontalPadding,
          _verticalBottomPadding,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: _maxContentWidth,
          ),
          alignment: Alignment.topLeft,
          // NEW: Use RichText to display the list of TextSpan
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              // The base style is necessary for general font properties (line height, etc.)
              style: _baseTextStyle,
              children: bionicSpans, // Pass the converted list of spans
            ),
          ),
        ),
      ),
    );
  }

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
}
