import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../data/services/resume_pdf_service.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/job_application_provider.dart';
// import '../providers/master_profile_provider.dart';
// import '../data/services/resume_pdf_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class OptimizationViewScreen extends StatefulWidget {
  const OptimizationViewScreen({super.key});

  @override
  State<OptimizationViewScreen> createState() => _OptimizationViewScreenState();
}

class _OptimizationViewScreenState extends State<OptimizationViewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final ResumePdfService _pdfService = ResumePdfService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
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
        child: Consumer2<JobApplicationProvider, MasterProfileProvider>(
          builder: (_, jobProvider, profileProvider, __) {
            final job = jobProvider.currentJob;
            if (job == null) {
              return const Center(child: Text('No job selected'));
            }
            return Column(
              children: [
                _buildHeader(context, jobProvider, profileProvider),
                _buildScoreHero(job),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _AnalysisTab(job: job, provider: jobProvider),
                      _ResumePdfTab(
                        job: job,
                        profile: profileProvider.profile,
                        pdfService: _pdfService,
                        isAts: false,
                      ),
                      _ResumePdfTab(
                        job: job,
                        profile: profileProvider.profile,
                        pdfService: _pdfService,
                        isAts: true,
                      ),
                      _ImprovementTab(
                        improvementPlan: jobProvider.improvementPlan,
                        missingSkills: job.missingSkills,
                        job: job,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JobApplicationProvider jobProvider,
      MasterProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () {
              jobProvider.reset();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobProvider.currentJob?.roleTitle ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  jobProvider.currentJob?.companyName ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Consumer<MasterProfileProvider>(
            builder: (_, profileProvider, __) => IconButton(
              icon: jobProvider.isProcessing
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent))
                  : Icon(Icons.refresh_rounded,
                  color: AppTheme.textSecondaryOf(context)),
              tooltip: 'Regenerate with updated profile',
              onPressed: jobProvider.isProcessing
                  ? null
                  : () => jobProvider.regenerateResume(
                profile: profileProvider.profile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero(dynamic job) {
    final score = job.matchScore as int;
    final scoreColor = score >= 80
        ? AppTheme.success
        : score >= 60
        ? AppTheme.amber
        : AppTheme.error;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.12),
            scoreColor.withOpacity(0.04)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: AppTheme.borderOf(context),
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeWidth: 7,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$score',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: scoreColor)),
                Text('%',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.textSecondaryOf(context))),
              ]),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score >= 80
                      ? 'Strong Match!'
                      : score >= 60
                      ? 'Good Match'
                      : 'Needs Work',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: scoreColor),
                ),
                const SizedBox(height: 3),
                Text(
                  '${(job.matchedSkills as List).length} of ${(job.requiredSkills as List).length} required skills matched',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevOf(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tone: ${(job.companyTone as String)[0].toUpperCase()}${(job.companyTone as String).substring(1)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.textSecondaryOf(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.bg,
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          labelStyle: GoogleFonts.spaceGrotesk(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Analysis'),
            Tab(text: 'Visual PDF'),
            Tab(text: 'ATS PDF'),
            Tab(text: 'Improve'),
          ],
        ),
      ),
    );
  }
}

// ─── Analysis Tab ─────────────────────────────────────────────────────────────
class _AnalysisTab extends StatelessWidget {
  final dynamic job;
  final JobApplicationProvider provider;

  const _AnalysisTab({required this.job, required this.provider});

  @override
  Widget build(BuildContext context) {
    final matched = List<String>.from(job.matchedSkills as List);
    final missing = List<String>.from(job.missingSkills as List);
    final required = List<String>.from(job.requiredSkills as List);
    final maxW = MediaQuery.of(context).size.width - 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matched.isNotEmpty) ...[
            _groupHeader('Skills You Have', Icons.check_circle_rounded,
                AppTheme.success, matched.length),
            const SizedBox(height: 10),
            _skillWrap(matched, AppTheme.success, Icons.check, maxW),
            const SizedBox(height: 20),
          ],
          if (missing.isNotEmpty) ...[
            _groupHeader('Missing Skills', Icons.warning_amber_rounded,
                AppTheme.error, missing.length),
            const SizedBox(height: 10),
            _skillWrap(missing, AppTheme.error, Icons.add, maxW),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.amber.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppTheme.amber, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Add missing skills to your Master Profile and tap ↑ Regenerate to boost your score.',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.textSecondaryOf(context),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _groupHeader('All Required Skills', Icons.list_alt_rounded,
              AppTheme.textSecondaryOf(context), required.length),
          const SizedBox(height: 10),
          _skillWrap(required, AppTheme.textSecondaryOf(context), null, maxW,
              highlightList: matched),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _groupHeader(String title, IconData icon, Color color, int count) {
    return Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 6),
      Text(title,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Text('$count',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    ]);
  }

  Widget _skillWrap(List<String> items, Color color, IconData? icon,
      double maxW, {List<String>? highlightList}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((s) {
        final highlighted = highlightList?.contains(s) ?? false;
        final c = highlighted ? AppTheme.success : color;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withOpacity(0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: c),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(s,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: c,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Resume PDF Tab (used for both Visual and ATS) ────────────────────────────
class _ResumePdfTab extends StatefulWidget {
  final dynamic job;
  final dynamic profile;
  final ResumePdfService pdfService;
  final bool isAts;

  const _ResumePdfTab({
    required this.job,
    required this.profile,
    required this.pdfService,
    this.isAts = false,
  });

  @override
  State<_ResumePdfTab> createState() => _ResumePdfTabState();
}

class _ResumePdfTabState extends State<_ResumePdfTab> {
  bool _loading = false;
  String? _error;

  Future<Uint8List> _build(pw.PdfPageFormat _) {
    return widget.isAts
        ? widget.pdfService.generateAtsPdf(
        profile: widget.profile, job: widget.job)
        : widget.pdfService.generatePdf(
        profile: widget.profile, job: widget.job);
  }

  Future<void> _download() async {
    setState(() { _loading = true; _error = null; });
    try {
      final bytes = await _build(PdfPageFormat.a4);
      final suffix = widget.isAts ? 'ATS' : 'Visual';
      await Printing.sharePdf(
        bytes: bytes,
        filename:
        '${widget.job.companyName}_${widget.job.roleTitle}_${suffix}_Resume.pdf'
            .replaceAll(' ', '_'),
      );
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyText() {
    Clipboard.setData(
        ClipboardData(text: widget.job.generatedResume as String));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Resume text copied to clipboard'),
      backgroundColor: AppTheme.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info banner for ATS
        if (widget.isAts)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border:
              Border.all(color: AppTheme.success.withOpacity(0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppTheme.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ATS format — Passes any Applicant Tracking System.',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context)),
                ),
              ),
            ]),
          ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Download',
                color: AppTheme.error,
                isLoading: _loading,
                onTap: _download,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.share_rounded,
                label: 'Share',
                color: AppTheme.accent,
                isLoading: false,
                onTap: _download,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.copy_rounded,
                label: 'Copy Text',
                color: AppTheme.success,
                isLoading: false,
                onTap: _copyText,
              ),
            ),
          ]),
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(_error!,
                  style: const TextStyle(color: AppTheme.error, fontSize: 12)),
            ),
          ),

        const SizedBox(height: 10),

        // PDF Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PdfPreview(
                build: _build,
                allowSharing: true,
                allowPrinting: true,
                canDebug: false,
                pdfPreviewPageDecoration:
                const BoxDecoration(color: Colors.white),
                scrollViewDecoration:
                BoxDecoration(color: AppTheme.bgOf(context)),
                previewPageMargin:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                loadingWidget: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.accent),
                      const SizedBox(height: 12),
                      Text(
                        widget.isAts
                            ? 'Building ATS resume...'
                            : 'Building visual resume...',
                        style: TextStyle(
                            color: AppTheme.textSecondaryOf(context),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Improvement Tab ──────────────────────────────────────────────────────────
class _ImprovementTab extends StatelessWidget {
  final String improvementPlan;
  final List<String> missingSkills;
  final dynamic job;

  const _ImprovementTab({
    required this.improvementPlan,
    required this.missingSkills,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    if (missingSkills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_rounded,
                color: AppTheme.success, size: 52),
            const SizedBox(height: 16),
            Text('Full Match!',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success)),
            const SizedBox(height: 8),
            Text(
              'You have all required skills. Your resume is fully optimized.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
        ),
      );
    }

    final maxW = MediaQuery.of(context).size.width - 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.error.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.error, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skill Gap Alert',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.error)),
                        const SizedBox(height: 4),
                        Text(
                          'Missing ${missingSkills.length} skill${missingSkills.length > 1 ? "s" : ""} for ${job.roleTitle}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingSkills.map((s) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.close_rounded,
                      size: 12, color: AppTheme.error),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(s,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, color: AppTheme.error)),
                  ),
                ]),
              ),
            )).toList(),
          ),
          if (improvementPlan.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Your Action Plan',
              subtitle: 'AI-generated steps to close the gap',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accent.withOpacity(0.25)),
              ),
              child: SelectableText(
                improvementPlan,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimaryOf(context),
                    height: 1.7),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          isLoading
              ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color))
              : Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}