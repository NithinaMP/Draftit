import 'package:hive_flutter/hive_flutter.dart';

part 'exam_question_model.g.dart';

@HiveType(typeId: 1)
class ExamQuestion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lectureId; // links back to Phase 1

  @HiveField(2)
  final String questionText;

  @HiveField(3)
  final int marks; // 2, 5, or 10

  @HiveField(4)
  final List<String> keyEvaluationCriteria; // must-include terms for full marks

  @HiveField(5)
  final String markLabel; // '2-Mark', '5-Mark', '10-Mark'

  @HiveField(6)
  final DateTime generatedAt;

  ExamQuestion({
    required this.id,
    required this.lectureId,
    required this.questionText,
    required this.marks,
    required this.keyEvaluationCriteria,
    required this.markLabel,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'lecture_id': lectureId,
    'question_text': questionText,
    'marks': marks,
    'key_evaluation_criteria': keyEvaluationCriteria,
    'mark_label': markLabel,
    'generated_at': generatedAt.toIso8601String(),
  };

  factory ExamQuestion.fromMap(Map<String, dynamic> m) => ExamQuestion(
    id: m['id'],
    lectureId: m['lecture_id'],
    questionText: m['question_text'],
    marks: m['marks'],
    keyEvaluationCriteria: List<String>.from(m['key_evaluation_criteria'] ?? []),
    markLabel: m['mark_label'],
    generatedAt: DateTime.parse(m['generated_at']),
  );
}