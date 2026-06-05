import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/models/lecture_model.dart';
import '../data/repositories/lecture_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class NotesViewerScreen extends StatefulWidget {
  final String lectureId;
  const NotesViewerScreen({super.key, required this.lectureId});

  @override
  State<NotesViewerScreen> createState() => _NotesViewerScreenState();
}

class _NotesViewerScreenState extends State<NotesViewerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final LectureRepository _repo = LectureRepository();

  LectureModel? _lecture;
  bool _isLoading = true;
  String? _error;
  bool _transcriptExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadLecture();
  }

  Future<void> _loadLecture() async {
    try {
      final lecture = await _repo.getLecture(widget.lectureId);
      if (mounted) {
        setState(() {
          _lecture = lecture;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load notes';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_lecture == null) return _buildError(msg: 'Lecture not found');

    final lecture = _lecture!;

    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(lecture),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildNotesTab(lecture),
                  _buildSkillsTab(lecture),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LectureModel lecture) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon:  Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimaryOf(context)),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              // Copy button
              IconButton(
                icon:  Icon(Icons.copy_rounded,
                    color: AppTheme.textSecondaryOf(context), size: 20),
                tooltip: 'Copy notes',
                onPressed: () => _copyNotes(lecture),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                     Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppTheme.textSecondaryOf(context)),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMMM d, yyyy').format(lecture.createdAt),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.bolt_rounded,
                        size: 13, color: AppTheme.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${lecture.extractedSkills.length} skills',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            colors: [AppTheme.accent, Color(0xFF9D40FF)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondaryOf(context),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Notes'),
          Tab(text: 'Skills'),
        ],
      ),
    );
  }

  Widget _buildNotesTab(LectureModel lecture) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.1),
                  const Color(0xFF9D40FF).withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.accentLight, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Summary',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  lecture.summary,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppTheme.textPrimaryOf(context),
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Key points
          const SectionHeader(title: 'Key Points'),
          const SizedBox(height: 14),
          ...List.generate(lecture.keyPoints.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lecture.keyPoints[i],
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppTheme.textPrimaryOf(context),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Collapsible raw transcript
          GestureDetector(
            onTap: () =>
                setState(() => _transcriptExpanded = !_transcriptExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderOf(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Icon(Icons.text_snippet_outlined,
                          color: AppTheme.textSecondaryOf(context), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Raw Transcript',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _transcriptExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ],
                  ),
                  if (_transcriptExpanded) ...[
                    const SizedBox(height: 12),
                     Divider(color: AppTheme.borderOf(context)),
                    const SizedBox(height: 12),
                    Text(
                      lecture.rawTranscript,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(LectureModel lecture) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills intro
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.amber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppTheme.amber, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${lecture.extractedSkills.length} skills identified from this lecture. These will power your career builder in Phase 3.',
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

          const SizedBox(height: 24),

          SectionHeader(
            title: 'Extracted Skills',
            subtitle: 'Automatically detected from your lecture',
          ),
          const SizedBox(height: 16),

          // Skills grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: lecture.extractedSkills.length,
            itemBuilder: (context, i) {
              return AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 200 + (i * 60)),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: Text(
                    lecture.extractedSkills[i],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentLight,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _copyNotes(LectureModel lecture) {
    final text = '''${lecture.title}

SUMMARY
${lecture.summary}

KEY POINTS
${lecture.keyPoints.map((p) => '• $p').join('\n')}

SKILLS
${lecture.extractedSkills.join(', ')}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notes copied to clipboard'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  Widget _buildLoading() {
    return  Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      ),
    );
  }

  Widget _buildError({String? msg}) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 16),
            Text(msg ?? _error ?? 'Error',
                style:  TextStyle(color: AppTheme.textSecondaryOf(context))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}