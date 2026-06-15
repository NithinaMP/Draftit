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
      _lectures.expand((lecture) => lecture.extractedSkills).toSet().length;

  int get masteredCount =>
      _lectures.where((lecture) => lecture.skillsMastered).length;

  void startListening() {
    _subscription?.cancel();

    _subscription = _repository.watchLectures().listen(
          (lecturesList) {
        _lectures = lecturesList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load lectures. Please check your connection.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteLecture(String id) async {
    try {
      await _repository.deleteLecture(id);
    } catch (e) {
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