import 'dart:convert';

/// An immutable data class to hold the reading state.
class ReadingState {
  final String documentId;
  final int pageIndex;

  const ReadingState({
    required this.documentId,
    required this.pageIndex,
  });

  /// Creates a ReadingState instance from a JSON map.
  factory ReadingState.fromJson(Map<String, dynamic> json) {
    return ReadingState(
      documentId: json['documentId'] as String,
      pageIndex: json['pageIndex'] as int,
    );
  }

  /// Converts the ReadingState instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'pageIndex': pageIndex,
    };
  }
}
