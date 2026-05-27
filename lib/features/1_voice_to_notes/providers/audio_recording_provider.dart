import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum RecordingState { idle, recording, stopping }

class AudioRecordingProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  RecordingState _state = RecordingState.idle;
  String? _currentLectureId;
  String? _currentFilePath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  List<double> _waveformBars = List.filled(30, 0.05);

  RecordingState get state => _state;
  String? get currentLectureId => _currentLectureId;
  String? get currentFilePath => _currentFilePath;
  Duration get elapsed => _elapsed;
  List<double> get waveformBars => _waveformBars;

  bool get isRecording => _state == RecordingState.recording;
  bool get isStopping  => _state == RecordingState.stopping;
  bool get isIdle      => _state == RecordingState.idle;

  String get formattedElapsed {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<bool> startRecording() async {
    if (!await _recorder.hasPermission()) return false;

    _currentLectureId = const Uuid().v4();
    final dir = await getApplicationDocumentsDirectory();

    // Save as .m4a — Groq accepts m4a (AAC in MPEG-4 container)
    _currentFilePath = '${dir.path}/$_currentLectureId.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,   // AAC codec inside .m4a container
        bitRate: 128000,
        sampleRate: 16000,             // 16kHz is optimal for speech recognition
      ),
      path: _currentFilePath!,
    );

    _elapsed = Duration.zero;
    _state = RecordingState.recording;
    _startTimer();
    notifyListeners();
    return true;
  }

  Future<String?> stopRecording() async {
    _state = RecordingState.stopping;
    notifyListeners();

    _timer?.cancel();
    final path = await _recorder.stop();

    _state = RecordingState.idle;
    _elapsed = Duration.zero;
    _waveformBars = List.filled(30, 0.05);
    notifyListeners();

    return path;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsed += const Duration(milliseconds: 100);
      _updateWaveform();
      notifyListeners();
    });
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