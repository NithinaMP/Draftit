// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../data/models/lecture_model.dart';
// import '../data/repositories/lecture_repository.dart';
// import '../data/services/ai_service.dart';
//
// enum NotesStatus { idle, transcribing, structuring, saving, done, error }
//
// class NotesGenerationProvider extends ChangeNotifier {
//   final AiService _aiService = AiService();
//   final LectureRepository _repository = LectureRepository();
//
//   NotesStatus _status = NotesStatus.idle;
//   LectureModel? _lastLecture;
//   String? _errorMessage;
//
//   // ── Getters ────────────────────────────────────────────────────────────────
//   NotesStatus get status => _status;
//   LectureModel? get lastLecture => _lastLecture;
//   String? get errorMessage => _errorMessage;
//
//   bool get isProcessing =>
//       _status == NotesStatus.transcribing ||
//           _status == NotesStatus.structuring ||
//           _status == NotesStatus.saving;
//
//   String get statusLabel {
//     switch (_status) {
//       case NotesStatus.transcribing:
//         return 'Transcribing audio with Whisper...';
//       case NotesStatus.structuring:
//         return 'Structuring notes with Mistral AI...';
//       case NotesStatus.saving:
//         return 'Saving to your library...';
//       case NotesStatus.done:
//         return 'Notes ready!';
//       case NotesStatus.error:
//         return 'Something went wrong';
//       default:
//         return '';
//     }
//   }
//
//   int get currentStep {
//     switch (_status) {
//       case NotesStatus.transcribing:
//         return 0;
//       case NotesStatus.structuring:
//         return 1;
//       case NotesStatus.saving:
//         return 2;
//       case NotesStatus.done:
//         return 3;
//       default:
//         return -1;
//     }
//   }
//
//   // ── Main pipeline ──────────────────────────────────────────────────────────
//   Future<void> processAudio({
//     required String audioPath,
//     required String lectureId,
//   }) async {
//     _errorMessage = null;
//
//     try {
//       // Step 1: Transcribe
//       _setStatus(NotesStatus.transcribing);
//       final audioBytes = await File(audioPath).readAsBytes();
//       final transcript = await _aiService.transcribeAudio(audioBytes);
//
//       // Step 2: Structure with LLM
//       _setStatus(NotesStatus.structuring);
//       final structured = await _aiService.structureTranscript(transcript);
//
//       // Step 3: Build model
//       final lecture = LectureModel(
//         id: lectureId,
//         title: _safeString(structured['title'], 'Lecture Notes'),
//         rawTranscript: transcript,
//         summary: _safeString(structured['summary'], ''),
//         keyPoints: _safeList(structured['key_points']),
//         extractedSkills: _safeList(structured['extracted_skills']),
//         createdAt: DateTime.now(),
//       );
//
//       // Step 4: Save
//       _setStatus(NotesStatus.saving);
//       await _repository.saveLecture(lecture);
//
//       _lastLecture = lecture;
//       _setStatus(NotesStatus.done);
//     } catch (e) {
//       _errorMessage = _friendlyError(e.toString());
//       _setStatus(NotesStatus.error);
//     }
//   }
//
//   void reset() {
//     _status = NotesStatus.idle;
//     _lastLecture = null;
//     _errorMessage = null;
//     notifyListeners();
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────────────────
//   String _safeString(dynamic value, String fallback) {
//     if (value is String && value.isNotEmpty) return value;
//     return fallback;
//   }
//
//   List<String> _safeList(dynamic value) {
//     if (value is List) return value.map((e) => e.toString()).toList();
//     return [];
//   }
//
//   String _friendlyError(String raw) {
//     if (raw.contains('SocketException') || raw.contains('connection')) {
//       return 'Network error. Check your internet connection.';
//     }
//     if (raw.contains('FormatException') || raw.contains('JSON')) {
//       return 'AI response error. Please try again.';
//     }
//     if (raw.contains('403') || raw.contains('401')) {
//       return 'Invalid API key. Check your HuggingFace key.';
//     }
//     return 'Unexpected error. Please try again.';
//   }
//
//   void _setStatus(NotesStatus s) {
//     _status = s;
//     notifyListeners();
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/lecture_model.dart';
import '../data/repositories/lecture_repository.dart';
import '../data/services/ai_service.dart';

enum NotesStatus { idle, transcribing, structuring, saving, done, error }

class NotesGenerationProvider extends ChangeNotifier {
  final AiService _aiService = AiService();
  final LectureRepository _repository = LectureRepository();

  NotesStatus _status = NotesStatus.idle;
  LectureModel? _lastLecture;
  String? _errorMessage;

  NotesStatus get status => _status;
  LectureModel? get lastLecture => _lastLecture;
  String? get errorMessage => _errorMessage;

  bool get isProcessing =>
      _status == NotesStatus.transcribing ||
          _status == NotesStatus.structuring ||
          _status == NotesStatus.saving;

  String get statusLabel {
    switch (_status) {
      case NotesStatus.transcribing:
        return 'Transcribing audio with Whisper...';
      case NotesStatus.structuring:
        return 'Structuring notes with Mistral AI...';
      case NotesStatus.saving:
        return 'Saving to your library...';
      case NotesStatus.done:
        return 'Notes ready!';
      case NotesStatus.error:
        return errorMessage ?? 'Something went wrong';
      default:
        return '';
    }
  }

  int get currentStep {
    switch (_status) {
      case NotesStatus.transcribing: return 0;
      case NotesStatus.structuring:  return 1;
      case NotesStatus.saving:       return 2;
      case NotesStatus.done:         return 3;
      default:                       return -1;
    }
  }

  // Future<void> processAudio({
  //   required String audioPath,
  //   required String lectureId,
  // }) async {
  //   _errorMessage = null;
  //
  //   try {
  //     // Step 1: Transcribe
  //     _setStatus(NotesStatus.transcribing);
  //     final audioBytes = await File(audioPath).readAsBytes();
  //     final transcript = await _aiService.transcribeAudio(audioBytes);
  //
  //     if (transcript.trim().isEmpty) {
  //       throw Exception(
  //         'NO_SPEECH: No speech was detected. Please speak clearly and try again.',
  //       );
  //     }
  //
  //     // Step 2: Structure with LLM
  //     _setStatus(NotesStatus.structuring);
  //     final structured = await _aiService.structureTranscript(transcript);
  //
  //     // Step 3: Build model
  //     final lecture = LectureModel(
  //       id: lectureId,
  //       title: _safeString(structured['title'], 'Lecture Notes'),
  //       rawTranscript: transcript,
  //       summary: _safeString(structured['summary'], ''),
  //       keyPoints: _safeList(structured['key_points']),
  //       extractedSkills: _safeList(structured['extracted_skills']),
  //       createdAt: DateTime.now(),
  //     );
  //
  //     // Step 4: Save
  //     _setStatus(NotesStatus.saving);
  //     await _repository.saveLecture(lecture);
  //
  //     _lastLecture = lecture;
  //     _setStatus(NotesStatus.done);
  //   } catch (e) {
  //     _errorMessage = _parseFriendlyError(e.toString());
  //     _setStatus(NotesStatus.error);
  //   }
  // }
  Future<void> processAudio({
    required String audioPath,
    required String lectureId,
  }) async {
    _errorMessage = null;
    try {
      _setStatus(NotesStatus.transcribing);

      final audioBytes = await File(audioPath).readAsBytes(); // Uint8List

      final transcript = await _aiService.transcribeAudio(audioBytes);

      if (transcript.trim().isEmpty) {
        throw Exception('NO_SPEECH');
      }

      _setStatus(NotesStatus.structuring);
      final structured = await _aiService.structureTranscript(transcript);

      _setStatus(NotesStatus.saving);
      final lecture = LectureModel(
        id: lectureId,
        title: _safeString(structured['title'], 'Untitled Lecture'),
        rawTranscript: transcript,
        summary: _safeString(structured['summary'], ''),
        keyPoints: _safeList(structured['key_points']),
        extractedSkills: _safeList(structured['extracted_skills']),
        createdAt: DateTime.now(),
      );

      await _repository.saveLecture(lecture);
      _lastLecture = lecture;
      _setStatus(NotesStatus.done);
    } catch (e) {
      _errorMessage = _parseFriendlyError(e.toString());
      _setStatus(NotesStatus.error);
      debugPrint('❌ Process Error: $e'); // For debugging
    }
  }

  void reset() {
    _status = NotesStatus.idle;
    _lastLecture = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _safeString(dynamic v, String fallback) =>
      (v is String && v.isNotEmpty) ? v : fallback;

  List<String> _safeList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : [];

  String _parseFriendlyError(String raw) {
    if (raw.contains('AUTH_ERROR')) {
      return '❌ API key error.\n\nRun the app with:\nflutter run --dart-define=HF_API_KEY=hf_yourtoken\n\nGet a free key at huggingface.co/settings/tokens';
    }
    if (raw.contains('MODEL_LOADING')) {
      return '⏳ AI model is warming up.\n\nWait 30 seconds and try recording again.';
    }
    if (raw.contains('RATE_LIMIT')) {
      return '⏱ Too many requests.\n\nWait 1 minute and try again.';
    }
    if (raw.contains('TIMEOUT')) {
      return '⏰ Request timed out.\n\nCheck your internet connection and try again.';
    }
    if (raw.contains('NO_SPEECH')) {
      return '🎤 No speech detected.\n\nSpeak clearly close to the microphone and try again.';
    }
    if (raw.contains('BAD_REQUEST')) {
      return '⚠️ Audio format error.\n\nTry recording again.';
    }
    return '❌ Unexpected error:\n$raw';
  }

  void _setStatus(NotesStatus s) {
    _status = s;
    notifyListeners();
  }
}