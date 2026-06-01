import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../../1_voice_to_notes/providers/lectures_provider.dart';
import '../../providers/exam_predictor_provider.dart';
import '../../providers/syllabus_provider.dart';
// import '../providers/exam_predictor_provider.dart';
// import '../providers/syllabus_provider.dart';
// import '../../1_voice_to_notes/providers/lectures_provider.dart';
// import '../../1_voice_to_notes/data/models/lecture_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'exam_blueprint_screen.dart';
import 'syllabus_tracker_screen.dart';

class StudyBuddyScreen extends StatefulWidget {
  const StudyBuddyScreen({super.key});

  @override
  State<StudyBuddyScreen> createState() => _StudyBuddyScreenState();
}

class _StudyBuddyScreenState extends State<StudyBuddyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LecturesProvider>().startListening();
      context.read<SyllabusProvider>().loadUnits();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Consumer2<LecturesProvider, SyllabusProvider>(
                  builder: (_, lectures, syllabus, __) {
                    return CustomScrollView(
                      slivers: [
                        // Syllabus progress banner
                        SliverToBoxAdapter(
                          child: _SyllabusBanner(
                            progress: syllabus.overallProgress,
                            hasUnits: syllabus.hasUnits,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SyllabusTrackerScreen(),
                              ),
                            ),
                          ),
                        ),

                        // Section header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: SectionHeader(
                              title: 'Study a Lecture',
                              subtitle: 'Select a lecture to generate exam questions',
                            ),
                          ),
                        ),

                        // Lectures list
                        if (lectures.isLoading)
                          SliverToBoxAdapter(
                            child: _buildShimmer(),
                          )
                        else if (lectures.lectures.isEmpty)
                          SliverToBoxAdapter(
                            child: _buildEmpty(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (ctx, i) => _LectureStudyCard(
                                  lecture: lectures.lectures[i],
                                  onTap: () => _openExamBlueprint(
                                    lectures.lectures[i],
                                  ),
                                ),
                                childCount: lectures.lectures.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.amber, Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exam Predictor',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              Text(
                'Study like an upperclassman',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExamBlueprint(LectureModel lecture) async {
    final provider = context.read<ExamPredictorProvider>();
    await provider.loadQuestionsForLecture(lecture);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamBlueprintScreen(lecture: lecture),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 16),
        )),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.mic_none_rounded,
                    color: AppTheme.amber, size: 40),
                const SizedBox(height: 16),
                Text(
                  'No lectures yet',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Record a lecture in Phase 1 first, then come back here to generate exam questions.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Syllabus Banner ──────────────────────────────────────────────────────────
class _SyllabusBanner extends StatelessWidget {
  final double progress;
  final bool hasUnits;
  final VoidCallback onTap;

  const _SyllabusBanner({
    required this.progress,
    required this.hasUnits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withOpacity(0.15),
              AppTheme.amber.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          color: AppTheme.accentLight, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Syllabus Mapper',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hasUnits) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.borderOf(context),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toInt()}% of syllabus covered',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ] else
                    Text(
                      'Upload your syllabus to track progress',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                ],
              ),
            ),
             Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryOf(context)),
          ],
        ),
      ),
    );
  }
}

// ─── Lecture Study Card ───────────────────────────────────────────────────────
class _LectureStudyCard extends StatelessWidget {
  final LectureModel lecture;
  final VoidCallback onTap;

  const _LectureStudyCard({required this.lecture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz_outlined,
                  color: AppTheme.amber, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lecture.extractedSkills.length} skills • Tap to generate exam questions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
             Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondaryOf(context), size: 16),
          ],
        ),
      ),
    );
  }
}