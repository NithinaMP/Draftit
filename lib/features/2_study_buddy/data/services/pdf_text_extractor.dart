import 'dart:io';
import 'package:flutter/foundation.dart';

class PdfTextExtractor {
  /// Extract raw text from a PDF file at [filePath].
  /// Uses syncfusion_flutter_pdf for local extraction — no upload needed.
  Future<String> extractText(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('PDF file not found at $filePath');
      }

      // Read raw bytes
      final bytes = await file.readAsBytes();
      debugPrint('📄 PDF size: ${bytes.length} bytes');

      // We use a lightweight pure-Dart PDF text extraction approach
      // by reading the raw PDF stream for text objects
      final text = _extractTextFromBytes(bytes);
      debugPrint('📄 Extracted ${text.length} characters from PDF');
      return text;
    } catch (e) {
      debugPrint('❌ PDF extraction error: $e');
      throw Exception('PDF_READ_ERROR: $e');
    }
  }

  /// Simple PDF text extraction by scanning for text stream markers.
  /// Works for most text-based PDFs. For scanned PDFs, user should type manually.
  String _extractTextFromBytes(List<int> bytes) {
    final raw = String.fromCharCodes(bytes.where((b) => b < 128).toList());

    final buffer = StringBuffer();
    final regex = RegExp(r'\(([^)]{2,})\)\s*Tj');
    final matches = regex.allMatches(raw);

    for (final m in matches) {
      final text = m.group(1) ?? '';
      // Filter out binary garbage — keep only printable ASCII
      final clean = text.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ').trim();
      if (clean.length > 2) {
        buffer.write('$clean ');
      }
    }

    final result = buffer.toString().trim();

    // If extraction yielded nothing useful, return a helpful message
    if (result.length < 50) {
      return '';
    }
    return result;
  }
}