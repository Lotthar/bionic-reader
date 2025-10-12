import 'package:flutter/material.dart';

class PaginationActions {

  final List<String> pages;
  final bool isLoading;
  final int currentPageIndex;
  // NEW: Callbacks to notify the parent (BionicReaderHomeScreen) of page changes
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  PaginationActions(
      this.pages,
      this.isLoading,
      this.currentPageIndex,
      {required this.onPreviousPage, required this.onNextPage} // Update constructor
      );

  List<Widget>? buildPaginationActions() {
    if (pages.isEmpty || isLoading) {
      return null;
    }

    return [
      // Previous Page Button
      IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        // Call the external callback on press
        onPressed: currentPageIndex > 0 ? onPreviousPage : null,
      ),
      // Page Counter
      Center(
        child: Text(
          'Page ${currentPageIndex + 1} of ${pages.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Next Page Button
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios),
        // Call the external callback on press
        onPressed: currentPageIndex < pages.length - 1 ? onNextPage : null,
      ),
      const SizedBox(width: 8.0),
    ];
  }
}