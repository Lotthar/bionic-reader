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
  /// Opens the file picker, extracts text from the selected PDF, and returns it.
  /// Throws FileLoaderException on failure or cancellation.
  Future<String> loadPdfText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      throw FileLoaderException('File selection canceled.');
    }

    File file = File(result.files.single.path!);

    try {
      // Use the pdf_text package to extract content
      PDFDoc pdfDoc = await PDFDoc.fromFile(file);
      String fullText = await pdfDoc.text;

      if (fullText.trim().isEmpty) {
        throw FileLoaderException('The selected PDF contains no readable text.');
      }
      return fullText;

    } catch (e) {
      // Catch PDF processing errors
      throw FileLoaderException('Error processing PDF file: ${e.toString()}');
    }
  }
}