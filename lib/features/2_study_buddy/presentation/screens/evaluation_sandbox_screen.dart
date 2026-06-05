import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../providers/exam_predictor_provider.dart';
// import '../providers/exam_predictor_provider.dart';
// import '../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class EvaluationSandboxScreen extends StatefulWidget {
  final dynamic question;
  final LectureModel lecture;

  const EvaluationSandboxScreen({
    super.key,
    required this.question,
    required this.lecture,
  });

  @override
  State<EvaluationSandboxScreen> createState() =>
      _EvaluationSandboxScreenState();
}

class _EvaluationSandboxScreenState extends State<EvaluationSandboxScreen> {
  final _answerCtrl = TextEditingController();
  bool _hasTyped = false;

  @override
  void initState() {
    super.initState();
    _answerCtrl.addListener(() {
      final has = _answerCtrl.text.trim().isNotEmpty;
      if (has != _hasTyped) setState(() => _hasTyped = has);
    });
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Consumer<ExamPredictorProvider>(
          builder: (_, provider, __) {
            return Column(
              children: [
                _buildHeader(provider),
                Expanded(
                  child: provider.lastEvaluation != null
                      ? _buildResults(provider)
                      : _buildAnswerInput(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ExamPredictorProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary),
            onPressed: () {
              provider.resetGrading();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Text(
              'Answer Evaluator',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (provider.lastEvaluation != null)
            TextButton(
              onPressed: () {
                provider.resetGrading();
                _answerCtrl.clear();
              },
              child: Text(
                'Try Again',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.accentLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(ExamPredictorProvider provider) {
    final q = widget.question;
    final markColor = q.marks == 2
        ? AppTheme.success
        : q.marks == 5
        ? AppTheme.amber
        : AppTheme.error;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question display
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: markColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border:
                    Border.all(color: markColor.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: markColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              q.markLabel,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: markColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q.questionText,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: AppTheme.textPrimaryOf(context),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Your Answer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Write your best answer. The AI will grade it like a real examiner.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                // Answer text field
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: TextField(
                    controller: _answerCtrl,
                    maxLines: 10,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppTheme.textPrimaryOf(context),
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write your answer here...',
                      hintStyle: GoogleFonts.dmSans(
                        color: AppTheme.textSecondaryOf(context),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                if (provider.gradingStatus == GradingStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        provider.gradingError ?? 'Grading failed',
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Submit button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Submit for Grading',
            icon: Icons.grading_rounded,
            isLoading: provider.isGrading,
            onPressed: _hasTyped && !provider.isGrading
                ? () => provider.gradeAnswer(
              question: widget.question,
              studentAnswer: _answerCtrl.text.trim(),
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildResults(ExamPredictorProvider provider) {
    final eval = provider.lastEvaluation!;
    final scoreColor = eval.scorePercent >= 0.9
        ? AppTheme.success
        : eval.scorePercent >= 0.6
        ? AppTheme.amber
        : AppTheme.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withOpacity(0.12),
                  scoreColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.grade,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eval.overallFeedback,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.textPrimaryOf(context),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Score circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: eval.scorePercent,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        strokeWidth: 6,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${eval.scoredMarks}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '/ ${eval.maxMarks}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Missing points
          if (eval.missingPoints.isNotEmpty) ...[
            const SectionHeader(
              title: 'Missing Points',
              subtitle: 'Include these to improve your score',
            ),
            const SizedBox(height: 12),
            ...eval.missingPoints.map(
                  (point) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.error.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.remove_circle_outline_rounded,
                        color: AppTheme.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.textPrimaryOf(context),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // How to get full marks
          if (eval.howToGetFullMarks.isNotEmpty) ...[
            const SectionHeader(
              title: 'How to Get Full Marks',
              subtitle: 'Add this to your answer',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.success.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppTheme.success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      eval.howToGetFullMarks,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textPrimaryOf(context),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Try again button
          GradientButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: () {
              provider.resetGrading();
              _answerCtrl.clear();
            },
          ),
        ],
      ),
    );
  }
}