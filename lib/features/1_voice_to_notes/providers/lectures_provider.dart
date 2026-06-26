import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/lecture_model.dart';
import '../data/repositories/lecture_repository.dart';

class LecturesProvider extends ChangeNotifier {
  final LectureRepository _repository = LectureRepository();

  List<LectureModel> _lectures = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<List<LectureModel>>? _subscription;

  List<LectureModel> get lectures => List.unmodifiable(_lectures);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalSkills =>
      _lectures.expand((l) => l.extractedSkills).toSet().length;

  int get masteredCount =>
      _lectures.where((l) => l.skillsMastered).length;

  void startListening() {
    _subscription?.cancel();
    _subscription = _repository.watchLectures().listen(
          (list) {
        _lectures = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Failed to load lectures. Please check your connection.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Called by ExamPredictorProvider when both mastery conditions are met.
  /// Updates Firestore + Hive + notifies dashboard immediately.
  Future<void> markMastered(String lectureId) async {
    final idx = _lectures.indexWhere((l) => l.id == lectureId);
    if (idx == -1) return; // lecture not found
    if (_lectures[idx].skillsMastered) return; // already mastered — skip

    // Create updated copy with skillsMastered = true
    final updated = _lectures[idx].copyWith(skillsMastered: true);

    // Persist to Firestore + Hive
    await _repository.saveLecture(updated);

    // Update in-memory list so dashboard updates instantly
    // (Firestore stream will also re-emit but this is faster)
    final mutable = List<LectureModel>.from(_lectures);
    mutable[idx] = updated;
    _lectures = mutable;
    notifyListeners();
  }

  Future<void> deleteLecture(String id) async {
    try {
      await _repository.deleteLecture(id);
    } catch (_) {
      _error = 'Failed to delete lecture';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}