import 'package:bionic_reader/models/conversion_status.dart';

class Book {
  final String id;
  final String filePath;
  final String title;
  final String? author;
  final String? coverImagePath;
  final ConversionStatus conversionStatus;
  final double progress;
  final int totalPages;
  final int lastReadPage;

  Book({
    required this.id,
    required this.filePath,
    required this.title,
    this.author,
    this.coverImagePath,
    this.conversionStatus = ConversionStatus.QUEUED,
    this.progress = 0.0,
    this.totalPages = 0,
    this.lastReadPage = 0,
  });

  Book copyWith({
    String? id,
    String? filePath,
    String? title,
    String? author,
    String? coverImagePath,
    ConversionStatus? conversionStatus,
    double? progress,
    int? totalPages,
    int? lastReadPage,
  }) {
    return Book(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      conversionStatus: conversionStatus ?? this.conversionStatus,
      progress: progress ?? this.progress,
      totalPages: totalPages ?? this.totalPages,
      lastReadPage: lastReadPage ?? this.lastReadPage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'author': author,
      'coverImagePath': coverImagePath,
      'conversionStatus': conversionStatus.name,
      'progress': progress,
      'totalPages': totalPages,
      'lastReadPage': lastReadPage,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      filePath: map['filePath'],
      title: map['title'],
      author: map['author'],
      coverImagePath: map['coverImagePath'],
      conversionStatus: ConversionStatus.values.byName(map['conversionStatus']),
      progress: map['progress'],
      totalPages: map['totalPages'],
      lastReadPage: map['lastReadPage'] ?? 0,
    );
  }
}
