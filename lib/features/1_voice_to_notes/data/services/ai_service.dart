import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/network/groq_client.dart';

class AiService {
  final GroqClient _client = GroqClient();

  /// Transcribe audio bytes using Groq Whisper
  Future<String> transcribeAudio(Uint8List audioBytes) async {
    // Give the file a timestamped name so Groq can identify the format
    final filename = 'lecture_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return _client.transcribeAudio(audioBytes, filename);
  }

  /// Structure raw transcript into JSON using Groq Llama 3
  Future<Map<String, dynamic>> structureTranscript(String transcript) async {
    const systemPrompt =
        'You are an expert academic note-taker. '
        'Your job is to analyze lecture transcripts and return structured JSON. '
        'Always respond with ONLY valid JSON — no explanation, no markdown, no code fences.';

    final userMessage =
        'Analyze this lecture transcript and return a JSON object with exactly these fields:\n'
        '- "title": string (5-8 words summarizing the topic)\n'
        '- "summary": string (3-5 sentences summarizing key concepts)\n'
        '- "key_points": array of 4-6 strings (most important points)\n'
        '- "extracted_skills": array of strings (specific skills mentioned, '
        'e.g. "linear regression", "public speaking", "data analysis")\n\n'
        'TRANSCRIPT:\n$transcript';

    final raw = await _client.generateText(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
    );

    debugPrint('📝 Raw Llama output: $raw');

    // Clean any accidental markdown fences
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = cleaned.indexOf('{');
    final end   = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1) {
      throw Exception('JSON_PARSE_ERROR: No JSON object found in: $cleaned');
    }

    return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
  }
}