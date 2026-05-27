import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/network/huggingface_client.dart';

class AiService {
  final HuggingFaceClient _client = HuggingFaceClient();

  Future<String> transcribeAudio(Uint8List audioBytes) async {
    return _client.transcribeAudio(audioBytes);
  }

  Future<Map<String, dynamic>> structureTranscript(String transcript) async {
    final prompt =
        '[INST] You are an expert academic note-taker. '
        'Given a raw lecture transcript, produce ONLY a valid JSON object with exactly these fields:\n'
        '- "title": string (5-8 words summarizing the topic)\n'
        '- "summary": string (3-5 sentences)\n'
        '- "key_points": array of 4-6 strings\n'
        '- "extracted_skills": array of skill strings\n\n'
        'RULES: Respond with ONLY valid JSON. No explanations, no markdown, no extra text.\n\n'
        'TRANSCRIPT: $transcript [/INST]';

    final raw = await _client.generateText(prompt: prompt);
    debugPrint('📝 Raw Mistral output: $raw');

    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1) {
      throw Exception('JSON_PARSE_ERROR: No JSON found in: $cleaned');
    }

    return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
  }
}