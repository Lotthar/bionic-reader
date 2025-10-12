import 'package:bionic_reader/services/text_pagination_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'dart:io';

class BionicReaderHomeScreen extends StatefulWidget {
  final String title;
  const BionicReaderHomeScreen({super.key, required this.title});

  @override
  State<BionicReaderHomeScreen> createState() => _BionicReaderScreenState();
}

class _BionicReaderScreenState extends State<BionicReaderHomeScreen> {
  // --- State Variables ---
  List<String> _pages = []; // List to hold paginated text content
  int _currentPageIndex = 0; // 0-based index for the current page
  bool _isLoading = false;
  String _statusMessage = 'Tap to select a document';

  // --- Configuration for Book Format ---
  final double _horizontalPadding = 32.0;
  final double _verticalTopPadding = 32.0; // Explicit constant for top padding
  final double _verticalBottomPadding = 64.0; // Explicit, larger constant for bottom padding
  // Standard max width for comfortable reading on large screens
  static const double _maxContentWidth = 700.0;

  // --- Core Logic: Setup Pagination (Delegates to Service) ---
  /// Uses the TextPaginationService to calculate the page breaks based on
  /// current screen constraints and text style.
  void _setPages(String fullText, BoxConstraints constraints) {
    // Define the text style used in the body content
    final TextStyle textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 18.0,
      height: 1.5,
    );

    // Calculate the total vertical padding consumed by the UI
    final double totalVerticalPadding = _verticalTopPadding + _verticalBottomPadding;

    // Initialize the external service with layout parameters
    final service = TextPaginationService(
      horizontalPadding: _horizontalPadding,
      // We pass half the total vertical padding, assuming the service internally
      // multiplies the verticalPadding argument by 2 when calculating available height.
      verticalPadding: totalVerticalPadding / 2,
      textStyle: textStyle,
      appBarHeight: kToolbarHeight, // Material constant for standard AppBar height
    );

    // Get the page list from the service
    final newPages = service.paginateTextToFit(fullText, constraints);

    setState(() {
      _pages = newPages;
      _currentPageIndex = 0;
      _statusMessage = 'Document loaded: ${_pages.length} pages';
    });
  }

  // --- File Picker and Text Extraction ---
  void _pickAndConvertFile(BoxConstraints constraints) async {
    setState(() {
      _isLoading = true;
      _pages = [];
      _statusMessage = 'Loading document...';
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF files for now
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      try {
        // Use the pdf_text package to extract content
        PDFDoc pdfDoc = await PDFDoc.fromFile(file);
        String fullText = await pdfDoc.text;

        // Pass the extracted text and screen constraints to the paginator
        _setPages(fullText, constraints);

      } catch (e) {
        setState(() {
          _statusMessage = 'Error loading PDF: $e';
          _pages = [_statusMessage];
        });
      }
    } else {
      setState(() {
        _statusMessage = 'File selection canceled.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // --- UI Navigation ---
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

  // --- UI BUILDERS (SRP Adherence) ---

  /// Builds the navigation controls shown in the AppBar.
  List<Widget>? _buildPaginationActions() {
    if (_pages.isEmpty || _isLoading) {
      return null;
    }

    return [
      // Previous Page Button
      IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
      ),
      // Page Counter
      Center(
        child: Text(
          'Page ${_currentPageIndex + 1} of ${_pages.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Next Page Button
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: _currentPageIndex < _pages.length - 1 ? _goToNextPage : null,
      ),
      const SizedBox(width: 8.0),
    ];
  }

  /// Builds the main reading area, applying book-style padding and constraints.
  Widget _buildDocumentContent() {
    final String currentText = _pages.isNotEmpty
        ? _pages[_currentPageIndex]
        : _statusMessage;

    // Use SingleChildScrollView to prevent overflow issues on small screens,
    // although dynamic pagination should prevent vertical scroll.
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _horizontalPadding,
          _verticalTopPadding,
          _horizontalPadding,
          _verticalBottomPadding, // Applied the increased bottom padding here
        ),
        child: Container(
          // Constrain text width for better readability (book format)
          constraints: const BoxConstraints(
            maxWidth: _maxContentWidth,
          ),
          alignment: Alignment.topLeft,
          child: Text(
            currentText,
            textAlign: TextAlign.justify, // Set text alignment to justify
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 18.0,
              height: 1.5,
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
