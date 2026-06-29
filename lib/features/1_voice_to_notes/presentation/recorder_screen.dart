import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/audio_recording_provider.dart';
import '../providers/notes_generation_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orb1Ctrl;
  late final AnimationController _orb2Ctrl;
  late final AnimationController _recBadgeCtrl;

  @override
  void initState() {
    super.initState();
    _orb1Ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _orb2Ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _recBadgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesGenerationProvider>().reset();
    });
  }

  @override
  void dispose() {
    _orb1Ctrl.dispose();
    _orb2Ctrl.dispose();
    _recBadgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRecordToggle(BuildContext context) async {
    final recorder = context.read<AudioRecordingProvider>();
    final generator = context.read<NotesGenerationProvider>();

    if (recorder.isIdle) {
      final started = await recorder.startRecording();
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone permission required'),
          backgroundColor: AppTheme.error,
        ));
      }
    } else if (recorder.isRecording) {
      final path = await recorder.stopRecording();

      // Safeguard 3 — file too large
      if (path == null && recorder.limitError != null) {
        if (mounted) {
          _showLimitDialog(context, recorder.limitError!);
          recorder.clearLimitError();
        }
        return;
      }

      if (path != null && recorder.currentLectureId != null) {
        await generator.processAudio(
          audioPath: path,
          lectureId: recorder.currentLectureId!,
        );

        // Safeguard — better rate limit message
        if (generator.status == NotesStatus.error && mounted) {
          final err = generator.errorMessage ?? '';
          if (err.contains('RATE_LIMIT')) {
            _showRateLimitDialog(context);
            return;
          }
        }

        if (generator.status == NotesStatus.done &&
            generator.lastLecture != null &&
            mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.notesViewer,
            arguments: generator.lastLecture!.id,
          );
        }
      }
    }
  }

  void _showLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.timer_off_rounded, color: AppTheme.amber, size: 22),
          const SizedBox(width: 8),
          Text('Recording Limit',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context))),
        ]),
        content: Text(message,
            style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.textSecondaryOf(context),
                height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it',
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showRateLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.amber, size: 22),
          const SizedBox(width: 8),
          Text('Daily Limit Reached',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context))),
        ]),
        content: Text(
          "You've reached today's AI processing limit.\n\n"
              "Your recording has been saved — come back tomorrow to generate notes. "
              "The limit resets every 24 hours.",
          style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondaryOf(context),
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Stack(
        children: [
          _Orb(ctrl: _orb1Ctrl, top: -80, left: -60, size: 280,
              color: AppTheme.accent.withOpacity(0.15)),
          _Orb(ctrl: _orb2Ctrl, bottom: -60, right: -80, size: 240,
              color: const Color(0xFF9D40FF).withOpacity(0.12)),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Consumer2<AudioRecordingProvider,
                      NotesGenerationProvider>(
                    builder: (context, recorder, generator, _) {
                      if (generator.isProcessing ||
                          generator.status == NotesStatus.error) {
                        return _buildProcessingView(generator);
                      }
                      return _buildRecorderView(context, recorder);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Text('New Recording', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildRecorderView(
      BuildContext context, AudioRecordingProvider recorder) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Waveform
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _WaveformDisplay(bars: recorder.waveformBars),
        ),

        const SizedBox(height: 32),

        // Timer
        Text(
          recorder.formattedElapsed,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context),
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 6),

        // Remaining time (shown when recording)
        // if (recorder.isRecording)
        //   Text(
        //     recorder.formattedRemaining,
        //     style: GoogleFonts.spaceGrotesk(
        //       fontSize: 12,
        //       color: recorder.showWarning
        //           ? AppTheme.amber
        //           : AppTheme.textSecondaryOf(context),
        //       fontWeight: recorder.showWarning
        //           ? FontWeight.w600
        //           : FontWeight.w400,
        //     ),
        //   ),

        const SizedBox(height: 8),

        // Duration progress bar (shown when recording)
        // if (recorder.isRecording) ...[
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 48),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(4),
        //       child: LinearProgressIndicator(
        //         value: recorder.durationProgress,
        //         backgroundColor: AppTheme.borderOf(context),
        //         valueColor: AlwaysStoppedAnimation(
        //           recorder.showWarning ? AppTheme.amber : AppTheme.accent,
        //         ),
        //         minHeight: 4,
        //       ),
        //     ),
        //   ),
        //   const SizedBox(height: 8),
        // ],

        // Safeguard 2 — warning banner at 45 minutes
        // if (recorder.showWarning)
        //   Container(
        //     margin: const EdgeInsets.symmetric(horizontal: 24),
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: AppTheme.amber.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(10),
        //       border: Border.all(color: AppTheme.amber.withOpacity(0.35)),
        //     ),
        //     child: Row(
        //       children: [
        //         const Icon(Icons.warning_amber_rounded,
        //             color: AppTheme.amber, size: 18),
        //         const SizedBox(width: 8),
        //         Expanded(
        //           child: Text(
        //             'Recording stops automatically at 50 min. '
        //                 'Stop now to avoid cutoff.',
        //             style: GoogleFonts.dmSans(
        //                 fontSize: 12,
        //                 color: AppTheme.amber,
        //                 height: 1.4),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),

        // REC badge
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedBuilder(
            animation: _recBadgeCtrl,
            builder: (_, __) => Opacity(
              opacity: recorder.isRecording ? _recBadgeCtrl.value : 0.0,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: AppTheme.error.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        color: AppTheme.error, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('RECORDING',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppTheme.error)),
                ]),
              ),
            ),
          ),
        ),

        const Spacer(flex: 2),

        // Record button
        _RecordButton(
          isRecording: recorder.isRecording,
          isStopping: recorder.isStopping,
          onPressed: () => _handleRecordToggle(context),
        ),

        const SizedBox(height: 20),

        Text(
          recorder.isIdle
              ? 'Tap to start recording'
              : recorder.isRecording
              ? 'Tap again to stop and generate notes'
              : 'Processing...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildProcessingView(NotesGenerationProvider generator) {
    final steps = [
      'Transcribing audio',
      'Structuring notes',
      'Saving to your library',
    ];

    if (generator.status == NotesStatus.error) {
      final isRateLimit =
          generator.errorMessage?.contains('RATE_LIMIT') ?? false;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isRateLimit ? AppTheme.amber : AppTheme.error)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRateLimit
                      ? Icons.cloud_off_rounded
                      : Icons.error_outline,
                  color: isRateLimit ? AppTheme.amber : AppTheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isRateLimit ? 'Daily Limit Reached' : 'Processing Failed',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isRateLimit
                    ? "You've reached today's AI processing limit.\n\n"
                    "Your recording has been saved — come back tomorrow "
                    "to generate notes. The limit resets every 24 hours."
                    : generator.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  generator.reset();
                  Navigator.pop(context);
                },
                child: Text(isRateLimit ? 'Got it' : 'Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60, height: 60,
              child: CircularProgressIndicator(
                  color: AppTheme.accent, strokeWidth: 3),
            ),
            const SizedBox(height: 40),
            Text('Creating Your Notes',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            ...List.generate(steps.length, (i) {
              final stepDone = generator.currentStep > i;
              final stepActive = generator.currentStep == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: stepDone
                            ? AppTheme.success.withOpacity(0.15)
                            : stepActive
                            ? AppTheme.accent.withOpacity(0.15)
                            : AppTheme.surfaceElevOf(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stepDone
                              ? AppTheme.success
                              : stepActive
                              ? AppTheme.accent
                              : AppTheme.borderOf(context),
                        ),
                      ),
                      child: Center(
                        child: stepDone
                            ? const Icon(Icons.check_rounded,
                            size: 16, color: AppTheme.success)
                            : stepActive
                            ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent))
                            : Text('${i + 1}',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                color: AppTheme.textSecondaryOf(
                                    context))),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(steps[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: stepDone || stepActive
                              ? AppTheme.textPrimaryOf(context)
                              : AppTheme.textSecondaryOf(context),
                          fontWeight: stepActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Record Button ────────────────────────────────────────────────────────────
class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final bool isStopping;
  final VoidCallback onPressed;
  const _RecordButton(
      {required this.isRecording,
        required this.isStopping,
        required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isStopping ? null : onPressed,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isRecording
                  ? AppTheme.error.withOpacity(0.4)
                  : AppTheme.accent.withOpacity(0.3),
              width: 3,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 76, height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isRecording
                  ? [AppTheme.error, const Color(0xFFFF6B6B)]
                  : [AppTheme.accent, const Color(0xFF9D40FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isRecording ? AppTheme.error : AppTheme.accent)
                    .withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isStopping
                ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
                : Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white, size: 32),
          ),
        ),
      ]),
    );
  }
}

// ─── Waveform Display ─────────────────────────────────────────────────────────
class _WaveformDisplay extends StatelessWidget {
  final List<double> bars;
  const _WaveformDisplay({required this.bars});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: bars.map((h) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 4,
          height: 80 * h.clamp(0.05, 1.0),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppTheme.accent, AppTheme.accentLight.withOpacity(0.6)],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ─── Animated Orb ─────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final AnimationController ctrl;
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  const _Orb(
      {required this.ctrl,
        this.top, this.bottom, this.left, this.right,
        required this.size,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, Tween<double>(begin: -12, end: 12).evaluate(
              CurvedAnimation(parent: ctrl, curve: Curves.easeInOut))),
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}