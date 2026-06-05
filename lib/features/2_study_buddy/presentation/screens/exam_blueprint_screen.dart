import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../providers/exam_predictor_provider.dart';
import '../../providers/syllabus_provider.dart';
// import '../providers/exam_predictor_provider.dart';
// import '../providers/syllabus_provider.dart';
// import '../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'evaluation_sandbox_screen.dart';

class ExamBlueprintScreen extends StatefulWidget {
  final LectureModel lecture;
  const ExamBlueprintScreen({super.key, required this.lecture});

  @override
  State<ExamBlueprintScreen> createState() => _ExamBlueprintScreenState();
}

class _ExamBlueprintScreenState extends State<ExamBlueprintScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);

    // Auto-align lecture to syllabus in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyllabusProvider>().alignLecture(widget.lecture);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildAlignmentBanner(),
            _buildTabBar(),
            Expanded(
              child: Consumer<ExamPredictorProvider>(
                builder: (_, provider, __) {
                  if (provider.isGenerating) return _buildGenerating();
                  if (provider.genStatus == ExamGenStatus.error) {
                    return _buildError(provider.genError ?? 'Unknown error');
                  }
                  if (provider.questions.isEmpty) return _buildGeneratePrompt(provider);
                  return _buildQuestions(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon:  Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Blueprint',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  widget.lecture.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Regenerate button
          Consumer<ExamPredictorProvider>(
            builder: (_, p, __) => IconButton(
              icon:  Icon(Icons.refresh_rounded, color: AppTheme.textSecondaryOf(context)),
              tooltip: 'Regenerate questions',
              onPressed: p.isGenerating
                  ? null
                  : () => p.generateBlueprint(widget.lecture),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentBanner() {
    return Consumer<SyllabusProvider>(
      builder: (_, syllabus, __) {
        if (!syllabus.hasUnits) return const SizedBox.shrink();
        if (syllabus.lastAlignmentNote == null) return const SizedBox.shrink();

        final matchedUnit = syllabus.units
            .where((u) => u.id == syllabus.lastMatchedUnitId)
            .firstOrNull;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.success.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppTheme.success, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matchedUnit != null)
                      Text(
                        '${matchedUnit.unitNumber}: ${matchedUnit.unitTitle}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    Text(
                      syllabus.lastAlignmentNote ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.amber, Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: '2 Mark'),
            Tab(text: '5 Mark'),
            Tab(text: '10 Mark'),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                color: AppTheme.amber,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Building Your\nExam Blueprint',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Analyzing lecture content and generating\n2-mark, 5-mark, and 10-mark questions...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratePrompt(ExamPredictorProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.quiz_outlined,
                      color: AppTheme.amber, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    'Generate Exam Questions',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let AI analyze your lecture and predict exactly what types of questions your professor will ask — broken down by mark weight.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Generate Blueprint',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () => provider.generateBlueprint(widget.lecture),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions(ExamPredictorProvider provider) {
    final groups = [
      provider.twoMarkQuestions,
      provider.fiveMarkQuestions,
      provider.tenMarkQuestions,
    ];

    return TabBarView(
      controller: _tabCtrl,
      children: List.generate(3, (tabIndex) {
        final questions = groups[tabIndex];
        final marks = [2, 5, 10][tabIndex];

        if (questions.isEmpty) {
          return Center(
            child: Text(
              'No $marks-mark questions generated',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          itemCount: questions.length,
          itemBuilder: (_, i) => _QuestionCard(
            question: questions[i],
            index: i + 1,
            onPractice: () {
              provider.resetGrading();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EvaluationSandboxScreen(
                    question: questions[i],
                    lecture: widget.lecture,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 16),
            Text(msg,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<ExamPredictorProvider>().generateBlueprint(widget.lecture),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────
class _QuestionCard extends StatefulWidget {
  final dynamic question;
  final int index;
  final VoidCallback onPractice;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onPractice,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _criteriaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final color = q.marks == 2
        ? AppTheme.success
        : q.marks == 5
        ? AppTheme.amber
        : AppTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    q.markLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Q${widget.index}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),

          // Question text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              q.questionText,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppTheme.textPrimaryOf(context),
                height: 1.55,
              ),
            ),
          ),

          // Key criteria (expandable)
          GestureDetector(
            onTap: () =>
                setState(() => _criteriaExpanded = !_criteriaExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                   Icon(Icons.key_rounded,
                      size: 14, color: AppTheme.textSecondaryOf(context)),
                  const SizedBox(width: 5),
                  Text(
                    'Key Criteria',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _criteriaExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ],
              ),
            ),
          ),

          if (_criteriaExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (q.keyEvaluationCriteria as List<String>)
                    .map((c) => SkillChip(label: c, highlighted: true))
                    .toList(),
              ),
            ),

          // Practice button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onPractice,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Practice Answer'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withOpacity(0.5)),
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}