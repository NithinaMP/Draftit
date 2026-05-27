import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam_question_model.dart';

class HiveExamBox {
  static const _boxName = 'exam_questions_box';
  Box<ExamQuestion>? _box;

  Future<Box<ExamQuestion>> get box async {
    _box ??= await Hive.openBox<ExamQuestion>(_boxName);
    return _box!;
  }

  /// Save all questions for a lecture (replaces previous ones for same lectureId)
  Future<void> saveQuestionsForLecture(
      String lectureId, List<ExamQuestion> questions) async {
    final b = await box;
    // Delete old questions for this lecture first
    final oldKeys = b.values
        .where((q) => q.lectureId == lectureId)
        .map((q) => q.key)
        .toList();
    await b.deleteAll(oldKeys);
    // Save new ones
    for (final q in questions) {
      await b.put(q.id, q);
    }
  }

  /// Get all questions for a specific lecture
  Future<List<ExamQuestion>> getQuestionsForLecture(String lectureId) async {
    final b = await box;
    return b.values.where((q) => q.lectureId == lectureId).toList()
      ..sort((a, b) => a.marks.compareTo(b.marks));
  }

  /// Check if questions exist for a lecture already
  Future<bool> hasQuestionsForLecture(String lectureId) async {
    final b = await box;
    return b.values.any((q) => q.lectureId == lectureId);
  }

  Future<void> deleteForLecture(String lectureId) async {
    final b = await box;
    final keys = b.values
        .where((q) => q.lectureId == lectureId)
        .map((q) => q.key)
        .toList();
    await b.deleteAll(keys);
  }
}