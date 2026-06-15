import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class PdfTextExtractor {
  /// Extract all text from a PDF file using Syncfusion.
  Future<String> extractText(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      throw Exception('PDF file not found at $filePath');
    }

    final bytes = await file.readAsBytes();

    try {
      final document = sf.PdfDocument(inputBytes: bytes);
      final extractor = sf.PdfTextExtractor(document);

      final pageCount = document.pages.count;
      final buffer = StringBuffer();

      for (int i = 0; i < pageCount; i++) {
        try {
          final pageText = extractor.extractText(
            startPageIndex: i,
            endPageIndex: i,
          );

          debugPrint(
            '📄 Page ${i + 1}: ${pageText.length} chars',
          );

          if (pageText.trim().isNotEmpty) {
            buffer.writeln(pageText.trim());
            buffer.writeln();
          }
        } catch (e) {
          debugPrint(
            '❌ Failed extracting page ${i + 1}: $e',
          );
        }
      }

      final result = buffer.toString().trim();

      debugPrint(
        '📄 Extracted ${result.length} characters from $pageCount pages',
      );

      document.dispose();

      if (result.length < 30) {
        throw Exception(
          'SCANNED_PDF: This PDF appears to be a scanned image — '
              'no readable text found. Please type your syllabus manually.',
        );
      }

      return result;
    } catch (e) {
      final msg = e.toString();

      if (msg.contains('SCANNED_PDF')) {
        rethrow;
      }


      throw Exception(
        'PDF_READ_ERROR: Could not read this PDF ($e). '
            'Try a different PDF or type manually.',
      );
    }
  }
}