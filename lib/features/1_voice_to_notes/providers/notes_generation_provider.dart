import 'dart:io';
import 'dart:typed_data';
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

  int get currentStep {
    switch (_status) {
      case NotesStatus.transcribing: return 0;
      case NotesStatus.structuring:  return 1;
      case NotesStatus.saving:       return 2;
      case NotesStatus.done:         return 3;
      default:                       return -1;
    }
  }

  Future<void> processAudio({
    required String audioPath,
    required String lectureId,
  }) async {
    _errorMessage = null;

    try {
      // Step 1 — Read and transcribe
      _setStatus(NotesStatus.transcribing);
      final file = File(audioPath);
      if (!file.existsSync()) {
        throw Exception('AUDIO_FILE_MISSING: File not found at $audioPath');
      }

      final Uint8List audioBytes = await file.readAsBytes();
      debugPrint('📁 Audio file size: ${audioBytes.length} bytes');

      if (audioBytes.isEmpty) {
        throw Exception('AUDIO_EMPTY: Recorded file is empty');
      }

      final transcript = await _aiService.transcribeAudio(audioBytes);
      debugPrint('📜 Transcript: $transcript');

      if (transcript.trim().isEmpty) {
        throw Exception('NO_SPEECH: No speech detected in recording');
      }

      // Step 2 — Structure
      _setStatus(NotesStatus.structuring);
      final structured = await _aiService.structureTranscript(transcript);

      // Step 3 — Save
      _setStatus(NotesStatus.saving);
      final lecture = LectureModel(
        id: lectureId,
        title: _str(structured['title'], 'Untitled Lecture'),
        rawTranscript: transcript,
        summary: _str(structured['summary'], ''),
        keyPoints: _list(structured['key_points']),
        extractedSkills: _list(structured['extracted_skills']),
        createdAt: DateTime.now(),
      );

      await _repository.saveLecture(lecture);
      _lastLecture = lecture;
      _setStatus(NotesStatus.done);
    } catch (e) {
      debugPrint('❌ processAudio failed: $e');
      _errorMessage = _friendlyMessage(e.toString());
      _setStatus(NotesStatus.error);
    }
  }

  void reset() {
    _status = NotesStatus.idle;
    _lastLecture = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _str(dynamic v, String fallback) =>
      (v is String && v.isNotEmpty) ? v : fallback;

  List<String> _list(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : [];

  String _friendlyMessage(String raw) {
    if (raw.contains('AUTH_ERROR')) {
      return '❌ API Key Error\n\nOpen your .env file and set:\nGROQ_API_KEY=gsk_yourkey\n\nGet a free key at console.groq.com';
    }
    if (raw.contains('RATE_LIMIT')) {
      return '⏱ Too many requests\n\nWait 1 minute and try again.';
    }
    if (raw.contains('TIMEOUT')) {
      return '⏰ Request timed out\n\nCheck your internet and try again.';
    }
    if (raw.contains('NO_SPEECH')) {
      return '🎤 No speech detected\n\nSpeak clearly and try again.';
    }
    if (raw.contains('AUDIO_FILE_MISSING') || raw.contains('AUDIO_EMPTY')) {
      return '🎙 Recording error\n\nThe audio was not saved. Try recording again.';
    }
    if (raw.contains('JSON_PARSE_ERROR')) {
      return '🤖 AI response error\n\nTry recording again.';
    }
    if (raw.contains('NETWORK_ERROR') || raw.contains('SERVICE_DOWN')) {
      return '🌐 Cannot reach Groq servers\n\nCheck your internet connection and try again.';
    }
    return '❌ Error: $raw';
  }

  void _setStatus(NotesStatus s) {
    _status = s;
    notifyListeners();
  }
}