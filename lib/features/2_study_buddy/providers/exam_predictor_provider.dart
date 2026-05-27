import 'package:flutter/material.dart';
import '../data/local/hive_exam_box.dart';
import '../data/models/exam_question_model.dart';
import '../data/models/answer_evaluation_model.dart';
import '../data/services/exam_ai_service.dart';
import '../data/services/answer_grader_service.dart';
import '../../1_voice_to_notes/data/models/lecture_model.dart';

enum ExamGenStatus { idle, generating, done, error }
enum GradingStatus { idle, grading, done, error }

class ExamPredictorProvider extends ChangeNotifier {
  final ExamAiService _examService = ExamAiService();
  final AnswerGraderService _graderService = AnswerGraderService();
  final HiveExamBox _examBox = HiveExamBox();

  // ── Question generation state ──────────────────────────────────────────────
  ExamGenStatus _genStatus = ExamGenStatus.idle;
  List<ExamQuestion> _questions = [];
  String? _genError;

  // ── Grading state ──────────────────────────────────────────────────────────
  GradingStatus _gradingStatus = GradingStatus.idle;
  AnswerEvaluation? _lastEvaluation;
  String? _gradingError;

  // Current lecture being studied
  LectureModel? _currentLecture;

  // ── Getters ────────────────────────────────────────────────────────────────
  ExamGenStatus get genStatus => _genStatus;
  GradingStatus get gradingStatus => _gradingStatus;
  List<ExamQuestion> get questions => _questions;
  List<ExamQuestion> get twoMarkQuestions =>
      _questions.where((q) => q.marks == 2).toList();
  List<ExamQuestion> get fiveMarkQuestions =>
      _questions.where((q) => q.marks == 5).toList();
  List<ExamQuestion> get tenMarkQuestions =>
      _questions.where((q) => q.marks == 10).toList();
  String? get genError => _genError;
  AnswerEvaluation? get lastEvaluation => _lastEvaluation;
  String? get gradingError => _gradingError;
  LectureModel? get currentLecture => _currentLecture;
  bool get isGenerating => _genStatus == ExamGenStatus.generating;
  bool get isGrading => _gradingStatus == GradingStatus.grading;

  /// Load existing questions for a lecture from Hive (instant, no API call)
  Future<void> loadQuestionsForLecture(LectureModel lecture) async {
    _currentLecture = lecture;
    _genError = null;
    _genStatus = ExamGenStatus.idle;
    notifyListeners();

    final cached = await _examBox.getQuestionsForLecture(lecture.id);
    if (cached.isNotEmpty) {
      _questions = cached;
      _genStatus = ExamGenStatus.done;
      notifyListeners();
    }
  }

  /// Generate fresh exam blueprint via Groq (replaces cached)
  Future<void> generateBlueprint(LectureModel lecture) async {
    _currentLecture = lecture;
    _genError = null;
    _genStatus = ExamGenStatus.generating;
    notifyListeners();

    try {
      final questions = await _examService.generateExamBlueprint(
        lectureId: lecture.id,
        lectureTitle: lecture.title,
        transcript: lecture.rawTranscript,
        summary: lecture.summary,
      );

      await _examBox.saveQuestionsForLecture(lecture.id, questions);
      _questions = questions;
      _genStatus = ExamGenStatus.done;

      // Mark lecture as having exam questions ready in Firestore via callback
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Blueprint generation failed: $e');
      _genError = _friendlyError(e.toString());
      _genStatus = ExamGenStatus.error;
      notifyListeners();
    }
  }

  /// Grade a student's answer
  Future<void> gradeAnswer({
    required ExamQuestion question,
    required String studentAnswer,
  }) async {
    if (_currentLecture == null) return;

    _gradingError = null;
    _lastEvaluation = null;
    _gradingStatus = GradingStatus.grading;
    notifyListeners();

    try {
      final evaluation = await _graderService.gradeAnswer(
        question: question,
        studentAnswer: studentAnswer,
        lectureTranscript: _currentLecture!.rawTranscript,
        lectureSummary: _currentLecture!.summary,
      );

      _lastEvaluation = evaluation;
      _gradingStatus = GradingStatus.done;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Grading failed: $e');
      _gradingError = _friendlyError(e.toString());
      _gradingStatus = GradingStatus.error;
      notifyListeners();
    }
  }

  void resetGrading() {
    _lastEvaluation = null;
    _gradingError = null;
    _gradingStatus = GradingStatus.idle;
    notifyListeners();
  }

  void resetAll() {
    _genStatus = ExamGenStatus.idle;
    _gradingStatus = GradingStatus.idle;
    _questions = [];
    _genError = null;
    _gradingError = null;
    _lastEvaluation = null;
    _currentLecture = null;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('AUTH_ERROR')) return '❌ API key error. Check your .env file.';
    if (raw.contains('RATE_LIMIT')) return '⏱ Too many requests. Wait 1 minute.';
    if (raw.contains('TIMEOUT'))    return '⏰ Request timed out. Try again.';
    if (raw.contains('NETWORK_ERROR')) return '🌐 No internet connection.';
    return '❌ Error: $raw';
  }
}