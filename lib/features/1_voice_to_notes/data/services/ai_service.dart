// import 'dart:convert';
// import '../../../../core/network/huggingface_client.dart';
//
// class AiService {
//   final HuggingFaceClient _client = HuggingFaceClient();
//
//   /// Transcribe audio bytes directly — no file storage needed
//   Future<String> transcribeAudio(List<int> audioBytes) {
//     return _client.transcribeAudio(audioBytes);
//   }
//
//   /// Structure raw transcript into a JSON note payload
//   Future<Map<String, dynamic>> structureTranscript(String transcript) async {
//     final prompt = '''[INST]
// You are an expert academic note-taker. Given a raw lecture transcript, produce ONLY a valid JSON object with exactly these fields:
// - "title": a string of 5-8 words summarizing the lecture topic
// - "summary": a string of 3-5 sentences summarizing the key concepts
// - "key_points": an array of 4-6 strings, each being an important point from the lecture
// - "extracted_skills": an array of strings naming specific skills mentioned (e.g. "linear regression", "gradient descent")
//
// RULES:
// - Respond with ONLY the JSON object
// - No preamble, no explanation, no markdown code fences
// - All fields are required
//
// TRANSCRIPT:
// $transcript
// [/INST]''';
//
//     final raw = await _client.generateText(prompt: prompt);
//
//     // Strip any accidental markdown fences
//     final cleaned = raw
//         .replaceAll('```json', '')
//         .replaceAll('```', '')
//         .trim();
//
//     // Find the first { and last } to extract JSON
//     final start = cleaned.indexOf('{');
//     final end = cleaned.lastIndexOf('}');
//     if (start == -1 || end == -1) {
//       throw Exception('No valid JSON found in AI response:\n$cleaned');
//     }
//
//     return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
//   }
// }



import 'dart:convert';
import 'dart:typed_data';                    // ← Add this
import '../../../../core/network/huggingface_client.dart';

class AiService {
  final HuggingFaceClient _client = HuggingFaceClient();

  /// Transcribe audio bytes directly
  Future<String> transcribeAudio(Uint8List audioBytes) async {
    return await _client.transcribeAudio(audioBytes);
  }

  /// Structure raw transcript into structured JSON
  Future<Map<String, dynamic>> structureTranscript(String transcript) async {
    final prompt = '''[INST] You are an expert academic note-taker. 
Given a raw lecture transcript, produce ONLY a valid JSON object with exactly these fields:

- "title": string (5-8 words summarizing the topic)
- "summary": string (3-5 sentences)
- "key_points": array of 4-6 strings (most important points)
- "extracted_skills": array of strings (specific skills, e.g. "linear regression", "public speaking")

RULES:
- Respond with ONLY valid JSON. No explanations, no markdown, no extra text.
- All fields are required.

TRANSCRIPT: $transcript
[/INST]''';

    try {
      final raw = await _client.generateText(
        prompt: prompt,
        maxNewTokens: 900,
        temperature: 0.2,
      );

      // Clean the response
      String cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Extract JSON if there's extra text
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');

      if (start == -1 || end == -1) {
        throw Exception('No valid JSON found in AI response');
      }

      final jsonString = cleaned.substring(start, end + 1);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to structure notes: $e');
    }
  }
}