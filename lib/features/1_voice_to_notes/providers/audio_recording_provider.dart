import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum RecordingState { idle, recording, stopping }

// Safeguard constants
const _kMaxRecordingDuration = Duration(minutes: 50); // hard stop
const _kWarnRecordingDuration = Duration(minutes: 45); // warning
const _kMaxFileSizeBytes = 24 * 1024 * 1024; // 24MB — Groq limit is 25MB

class AudioRecordingProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  RecordingState _state = RecordingState.idle;
  String? _currentLectureId;
  String? _currentFilePath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  List<double> _waveformBars = List.filled(30, 0.05);

  // Safeguard state
  bool _showWarning = false;
  String? _limitError; // set when hard stop or file too large

  RecordingState get state => _state;
  String? get currentLectureId => _currentLectureId;
  String? get currentFilePath => _currentFilePath;
  Duration get elapsed => _elapsed;
  List<double> get waveformBars => _waveformBars;
  bool get showWarning => _showWarning;
  String? get limitError => _limitError;

  bool get isRecording => _state == RecordingState.recording;
  bool get isStopping  => _state == RecordingState.stopping;
  bool get isIdle      => _state == RecordingState.idle;

  // Progress toward limit (0.0 to 1.0) — used for UI progress bar
  double get durationProgress =>
      (_elapsed.inSeconds / _kMaxRecordingDuration.inSeconds).clamp(0.0, 1.0);

  String get formattedElapsed {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedRemaining {
    final remaining = _kMaxRecordingDuration - _elapsed;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s remaining';
  }

  Future<bool> startRecording() async {
    if (!await _recorder.hasPermission()) return false;

    _currentLectureId = const Uuid().v4();
    final dir = await getApplicationDocumentsDirectory();
    _currentFilePath = '${dir.path}/$_currentLectureId.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
      ),
      path: _currentFilePath!,
    );

    _elapsed = Duration.zero;
    _showWarning = false;
    _limitError = null;
    _state = RecordingState.recording;
    _startTimer();
    notifyListeners();
    return true;
  }

  /// Returns the file path, or null if an error occurred.
  /// Sets [limitError] if file is too large.
  Future<String?> stopRecording() async {
    _state = RecordingState.stopping;
    notifyListeners();

    _timer?.cancel();
    final path = await _recorder.stop();

    _state = RecordingState.idle;
    _elapsed = Duration.zero;
    _showWarning = false;
    _waveformBars = List.filled(30, 0.05);

    // Safeguard 3 — check file size before returning path
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        final sizeBytes = await file.length();
        if (sizeBytes > _kMaxFileSizeBytes) {
          _limitError =
          'Recording is too long for AI processing (file exceeded 24MB). '
              'Try splitting your lecture into shorter segments under 50 minutes.';
          notifyListeners();
          return null; // caller should not attempt to process
        }
      }
    }

    notifyListeners();
    return path;
  }

  void clearLimitError() {
    _limitError = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsed += const Duration(milliseconds: 100);
      _updateWaveform();

      // Safeguard 1 — hard stop at 50 minutes
      if (_elapsed >= _kMaxRecordingDuration) {
        _autoStop();
        return;
      }

      // Safeguard 2 — warning at 45 minutes
      if (_elapsed >= _kWarnRecordingDuration && !_showWarning) {
        _showWarning = true;
      }

      notifyListeners();
    });
  }

  Future<void> _autoStop() async {
    _timer?.cancel();
    // _limitError =
    // 'Recording automatically stopped at 50 minutes — the maximum length '
    //     'for AI processing. Your recording has been saved.';

    _limitError =
    'Recording stopped automatically.\n\n'
        'Recordings are limited to 50 minutes per session to ensure '
        'the best AI processing quality. Your recording has been saved '
        '— tap Generate Notes to continue.';
    await stopRecording();
  }

  void _updateWaveform() {
    final newBars = List<double>.from(_waveformBars);
    for (int i = 0; i < newBars.length - 1; i++) {
      newBars[i] = newBars[i + 1];
    }
    final t = _elapsed.inMilliseconds / 100.0;
    final bar = (0.1 +
        0.6 *
            ((0.5 + 0.5 * _sin(t * 0.13)) *
                (0.5 + 0.5 * _sin(t * 0.37)) *
                (0.5 + 0.5 * _sin(t * 0.71))))
        .clamp(0.05, 0.95);
    newBars[newBars.length - 1] = bar;
    _waveformBars = newBars;
  }

  double _sin(double x) {
    x = x % (2 * 3.141592653589793);
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}