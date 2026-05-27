import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/groq_client.dart';
import '../models/exam_question_model.dart';
import '../models/syllabus_model.dart';

class ExamAiService {
  final GroqClient _client = GroqClient();

  /// Feature A: Generate 2-mark, 5-mark, and 10-mark exam questions
  /// from a lecture transcript
  Future<List<ExamQuestion>> generateExamBlueprint({
    required String lectureId,
    required String lectureTitle,
    required String transcript,
    required String summary,
  }) async {
    const system =
        'You are a strict university professor writing exam questions. '
        'You always respond with ONLY valid JSON. No explanations, no markdown, no extra text.';

    final user =
        'Analyze this lecture and generate a university exam blueprint.\n\n'
        'LECTURE TITLE: $lectureTitle\n'
        'SUMMARY: $summary\n'
        'TRANSCRIPT: $transcript\n\n'
        'Generate this EXACT JSON structure:\n'
        '{\n'
        '  "two_mark": [\n'
        '    {\n'
        '      "question": "question text here",\n'
        '      "key_criteria": ["term1", "term2", "term3"]\n'
        '    },\n'
        '    {\n'
        '      "question": "question text here",\n'
        '      "key_criteria": ["term1", "term2"]\n'
        '    }\n'
        '  ],\n'
        '  "five_mark": [\n'
        '    {\n'
        '      "question": "question text here",\n'
        '      "key_criteria": ["concept1", "concept2", "concept3", "concept4"]\n'
        '    },\n'
        '    {\n'
        '      "question": "question text here",\n'
        '      "key_criteria": ["concept1", "concept2", "concept3"]\n'
        '    }\n'
        '  ],\n'
        '  "ten_mark": [\n'
        '    {\n'
        '      "question": "comprehensive scenario-based question here",\n'
        '      "key_criteria": ["point1", "point2", "point3", "point4", "point5"]\n'
        '    }\n'
        '  ]\n'
        '}\n\n'
        'Make questions realistic for university exams. '
        '2-mark: definitions/identification. '
        '5-mark: explanation/procedure. '
        '10-mark: analysis/synthesis/scenario.';

    final raw = await _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 1500,
      temperature: 0.3,
    );

    debugPrint('📝 Raw exam blueprint: $raw');
    return _parseBlueprint(raw, lectureId);
  }

  List<ExamQuestion> _parseBlueprint(String raw, String lectureId) {
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw Exception('JSON_PARSE_ERROR: No JSON in blueprint response');
    }

    final json = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
    final questions = <ExamQuestion>[];
    const uuid = Uuid();

    void parseGroup(String key, int marks, String label) {
      final group = json[key] as List? ?? [];
      for (final item in group) {
        questions.add(ExamQuestion(
          id: uuid.v4(),
          lectureId: lectureId,
          questionText: item['question'] as String? ?? '',
          marks: marks,
          keyEvaluationCriteria:
          List<String>.from(item['key_criteria'] ?? []),
          markLabel: label,
          generatedAt: DateTime.now(),
        ));
      }
    }

    parseGroup('two_mark', 2, '2-Mark');
    parseGroup('five_mark', 5, '5-Mark');
    parseGroup('ten_mark', 10, '10-Mark');

    return questions;
  }

  /// Feature B: Syllabus alignment — which unit does this lecture cover?
  Future<Map<String, dynamic>> alignLectureToSyllabus({
    required String lectureTitle,
    required String summary,
    required List<String> extractedSkills,
    required List<SyllabusUnit> syllabusUnits,
  }) async {
    if (syllabusUnits.isEmpty) {
      return {'unit_id': null, 'matched_sections': [], 'confidence': 0.0};
    }

    final syllabusIndex = syllabusUnits
        .map((u) =>
    '${u.unitNumber}: ${u.unitTitle} — Sections: ${u.sections.join(", ")}')
        .join('\n');

    const system =
        'You are an academic assistant mapping lecture content to syllabus units. '
        'Respond with ONLY valid JSON.';

    final user =
        'Match this lecture to the most relevant syllabus unit.\n\n'
        'LECTURE TITLE: $lectureTitle\n'
        'LECTURE SUMMARY: $summary\n'
        'SKILLS COVERED: ${extractedSkills.join(", ")}\n\n'
        'SYLLABUS:\n$syllabusIndex\n\n'
        'Return this EXACT JSON:\n'
        '{\n'
        '  "unit_id_index": 0,\n'
        '  "matched_sections": ["section name 1", "section name 2"],\n'
        '  "confidence": 0.85,\n'
        '  "coverage_note": "One sentence explaining what was covered"\n'
        '}';

    final raw = await _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 300,
      temperature: 0.1,
    );

    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1) return {'unit_id': null, 'matched_sections': []};

    final result = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
    final index = (result['unit_id_index'] as num?)?.toInt() ?? 0;

    if (index >= 0 && index < syllabusUnits.length) {
      result['unit_id'] = syllabusUnits[index].id;
    }
    return result;
  }
}