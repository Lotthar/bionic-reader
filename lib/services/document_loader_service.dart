import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

// Custom Exception to make error handling clearer in the UI layer
class FileLoaderException implements Exception {
  final String message;
  FileLoaderException(this.message);
  @override
  String toString() => 'FileLoaderException: $message';
}

class DocumentLoaderService {
  Future<PDFDoc> loadPdfDocFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileLoaderException('File not found at the specified path.');
    }
    try {
      return await PDFDoc.fromPath(filePath);
    } catch (e) {
      throw FileLoaderException('Error processing PDF file: ${e.toString()}');
    }
  }

  /// Opens the file picker, extracts text from the selected PDF.
  ///
  /// Returns a record containing the file path and the extracted text.
  /// Throws [FileLoaderException] on failure or cancellation.
  Future<({String path, String text})> pickAndLoadPdfText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      throw FileLoaderException('File selection canceled.');
    }

    final path = result.files.single.path!;
    final file = File(path);
    final text = await _extractTextFromFile(file);

    return (path: path, text: text);
  }

  /// Loads and extracts text from a PDF at the given [filePath].
  ///
  /// Throws [FileLoaderException] if the file doesn't exist or fails processing.
  Future<String> loadPdfTextFromPath(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileLoaderException('File not found at the specified path.');
    }

    return await _extractTextFromFile(file);
  }

  /// Extracts text from the given PDF [File] object.
  Future<String> _extractTextFromFile(File file) async {
    try {
      PDFDoc pdfDoc = await PDFDoc.fromFile(file);
      String fullText = await pdfDoc.text;

      if (fullText.trim().isEmpty) {
        throw FileLoaderException('The selected PDF contains no readable text.');
      }
      return fullText;
    } catch (e) {
      throw FileLoaderException('Error processing PDF file: ${e.toString()}');
    }
  }

  @Deprecated('Use pickAndLoadPdfText() instead to get both path and text.')
  Future<String> loadPdfText() async {
    final result = await pickAndLoadPdfText();
    return result.text;
  }
}
