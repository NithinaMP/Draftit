import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/groq_client.dart';
import '../models/answer_evaluation_model.dart';
import '../models/exam_question_model.dart';

class AnswerGraderService {
  final GroqClient _client = GroqClient();

  /// Feature C: Grade a student's answer against the lecture transcript
  Future<AnswerEvaluation> gradeAnswer({
    required ExamQuestion question,
    required String studentAnswer,
    required String lectureTranscript,
    required String lectureSummary,
  }) async {
    const system =
        'You are a strict but fair university exam evaluator. '
        'Grade answers precisely based on the lecture content provided. '
        'Respond with ONLY valid JSON.';

    final user =
        'Evaluate this student answer for a ${question.marks}-mark university exam question.\n\n'
        'QUESTION: ${question.questionText}\n'
        'MAX MARKS: ${question.marks}\n'
        'KEY CRITERIA (must include for full marks): ${question.keyEvaluationCriteria.join(", ")}\n\n'
        'LECTURE CONTENT (ground truth):\n$lectureSummary\n\n'
        'STUDENT ANSWER:\n$studentAnswer\n\n'
        'Return this EXACT JSON:\n'
        '{\n'
        '  "scored_marks": 7,\n'
        '  "missing_points": ["specific point 1 they missed", "specific point 2"],\n'
        '  "how_to_get_full_marks": "Specific paragraph or sentence to add",\n'
        '  "overall_feedback": "2-3 sentence constructive feedback"\n'
        '}';

    final raw = await _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 600,
      temperature: 0.2,
    );

    return _parseEvaluation(raw, question);
  }

  AnswerEvaluation _parseEvaluation(String raw, ExamQuestion question) {
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1) {
      throw Exception('JSON_PARSE_ERROR: Could not parse grading response');
    }

    final json = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;

    final scored = (json['scored_marks'] as num?)?.toInt() ?? 0;

    return AnswerEvaluation(
      questionText: question.questionText,
      maxMarks: question.marks,
      scoredMarks: scored.clamp(0, question.marks),
      missingPoints: List<String>.from(json['missing_points'] ?? []),
      howToGetFullMarks: json['how_to_get_full_marks'] as String? ?? '',
      overallFeedback: json['overall_feedback'] as String? ?? '',
    );
  }
}