import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam_question_model.dart';

class HiveExamBox {
  static const _boxName = 'exam_questions_box';
  String get _prefix => 'eq_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}_';
  Box<ExamQuestion>? _box;

  Future<Box<ExamQuestion>> get box async {
    _box ??= await Hive.openBox<ExamQuestion>(_boxName);
    return _box!;
  }

  Future<void> saveQuestionsForLecture(String lectureId, List<ExamQuestion> questions) async {
    final b = await box;
    final oldKeys = b.keys.where((k) => k.toString().startsWith('${_prefix}$lectureId')).toList();
    await b.deleteAll(oldKeys);
    for (final q in questions) {
      await b.put('${_prefix}${q.id}', q);
    }
  }

  Future<List<ExamQuestion>> getQuestionsForLecture(String lectureId) async {
    final b = await box;
    return b.values
        .where((q) => q.lectureId == lectureId && b.keys.contains('${_prefix}${q.id}'))
        .toList()
      ..sort((a, b) => a.marks.compareTo(b.marks));
  }

  Future<bool> hasQuestionsForLecture(String lectureId) async {
    final questions = await getQuestionsForLecture(lectureId);
    return questions.isNotEmpty;
  }

  Future<void> deleteForLecture(String lectureId) async {
    final b = await box;
    final keys = b.keys.where((k) => k.toString().startsWith('${_prefix}$lectureId')).toList();
    await b.deleteAll(keys);
  }

  void reset() => _box = null;
}