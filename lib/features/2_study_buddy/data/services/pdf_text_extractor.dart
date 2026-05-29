import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class PdfTextExtractor {
  /// Extract all text from a PDF file using Syncfusion.
  /// Works on compressed, modern PDFs — fully local, no upload needed.
  Future<String> extractText(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('PDF file not found at $filePath');
    }

    final bytes = await file.readAsBytes();
    debugPrint('📄 PDF size: ${bytes.length} bytes');

    try {
      final document = sf.PdfDocument(inputBytes: bytes);
      final extractor = sf.PdfTextExtractor(document);

      final buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        if (pageText.trim().isNotEmpty) {
          buffer.writeln(pageText.trim());
          buffer.writeln(); // blank line between pages
        }
      }

      document.dispose();

      final result = buffer.toString().trim();
      debugPrint('📄 Extracted ${result.length} characters from ${document.pages.count} pages');

      if (result.length < 30) {
        throw Exception(
          'SCANNED_PDF: This PDF appears to be a scanned image — '
              'no readable text found. Please type your syllabus manually.',
        );
      }

      return result;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SCANNED_PDF')) rethrow;
      debugPrint('❌ PDF read error: $e');
      throw Exception(
        'PDF_READ_ERROR: Could not read this PDF ($e). '
            'Try a different PDF or type manually.',
      );
    }
  }
}