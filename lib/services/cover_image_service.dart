import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';

class CoverImageService {

  Future<Uint8List?> extractCoverImage(String filePath) async {
    PdfDocument? document;
    PdfPage? page;
    try {
      document = await PdfDocument.openFile(filePath);
      if (document.pagesCount < 1) {
        return null;
      }
      page = await document.getPage(1);
      final pageImage = await page.render(
        width: 200,
        height: 300,
        backgroundColor: '#FFFFFF',
      );
      return pageImage?.bytes;
    } catch (e) {
      return null;
    } finally {
      await page?.close();
      await document?.close();
    }
  }
}
