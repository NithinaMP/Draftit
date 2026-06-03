import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/job_application_provider.dart';
// import '../providers/master_profile_provider.dart';
import '../../data/services/resume_pdf_service.dart';
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
    _tabCtrl = TabController(length: 3, vsync: this);
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
                _buildScoreHero(context, job),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _AnalysisTab(job: job, provider: jobProvider),
                      _ResumePdfTab(
                        job: job,
                        profile: profileProvider.profile,
                        pdfService: _pdfService,
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
            icon:  Icon(Icons.arrow_back_ios_new_rounded,
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
          IconButton(
            icon: jobProvider.isProcessing
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.accent))
                :  Icon(Icons.refresh_rounded,
                color: AppTheme.textSecondaryOf(context)),
            tooltip: 'Regenerate with updated profile',
            onPressed: jobProvider.isProcessing
                ? null
                : () => jobProvider.regenerateResume(
              profile: profileProvider.profile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero(  BuildContext context,
      dynamic job) {
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
          colors: [scoreColor.withOpacity(0.12), scoreColor.withOpacity(0.04)],
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
                        fontSize: 11, color: AppTheme.textSecondaryOf(context))),
              ]),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score >= 80 ? 'Strong Match!' : score >= 60 ? 'Good Match' : 'Needs Work',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.w700, color: scoreColor),
                ),
                const SizedBox(height: 3),
                Text(
                  '${(job.matchedSkills as List).length} of ${(job.requiredSkills as List).length} required skills matched',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevOf(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tone: ${(job.companyTone as String)[0].toUpperCase()}${(job.companyTone as String).substring(1)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
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
          indicator: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.bgOf(context),
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          labelStyle: GoogleFonts.spaceGrotesk(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Analysis'),
            Tab(text: 'Resume PDF'),
            Tab(text: 'Improve'),
          ],
        ),
      ),
    );
  }
}

// ─── Analysis Tab — overflow fixed ───────────────────────────────────────────
class _AnalysisTab extends StatelessWidget {
  final dynamic job;
  final JobApplicationProvider provider;
  const _AnalysisTab({required this.job, required this.provider});

  @override
  Widget build(BuildContext context) {
    final matched = List<String>.from(job.matchedSkills as List);
    final missing = List<String>.from(job.missingSkills as List);
    final required = List<String>.from(job.requiredSkills as List);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matched.isNotEmpty) ...[
            _skillGroupHeader('Skills You Have', Icons.check_circle_rounded,
                AppTheme.success, matched.length),
            const SizedBox(height: 10),
            // FIX: Wrap with constrained chips
            _overflowSafeWrap(context, matched, AppTheme.success, Icons.check),
            const SizedBox(height: 20),
          ],

          if (missing.isNotEmpty) ...[
            _skillGroupHeader('Missing Skills', Icons.warning_amber_rounded,
                AppTheme.error, missing.length),
            const SizedBox(height: 10),
            _overflowSafeWrap(context, missing, AppTheme.error, Icons.add),
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
                      'Add these missing skills to your Master Profile and tap Regenerate ↑ to boost your score.',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.textSecondaryOf(context), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          _skillGroupHeader(
              'All Required Skills', Icons.list_alt_rounded,
              AppTheme.textSecondaryOf(context), required.length),
          const SizedBox(height: 10),
          _overflowSafeWrap(
            context,
            required,
            AppTheme.textSecondaryOf(context),
            null,
            highlightList: matched,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _skillGroupHeader(
      String title, IconData icon, Color color, int count) {
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$count',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    ]);
  }

  Widget _overflowSafeWrap(
      BuildContext context,
      List<String> items,
      Color color,
      IconData? icon, {
        List<String>? highlightList,
      }) {
    final maxW = MediaQuery.of(context).size.width - 40;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((s) {
        final highlighted = highlightList?.contains(s) ?? false;
        final effectiveColor = highlighted ? AppTheme.success : color;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: effectiveColor.withOpacity(0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: effectiveColor),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: effectiveColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Resume PDF Tab ────────────────────────────────────────────────────────────
class _ResumePdfTab extends StatefulWidget {
  final dynamic job;
  final dynamic profile;
  final ResumePdfService pdfService;
  const _ResumePdfTab(
      {required this.job, required this.profile, required this.pdfService});

  @override
  State<_ResumePdfTab> createState() => _ResumePdfTabState();
}

class _ResumePdfTabState extends State<_ResumePdfTab> {
  bool _generating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Download PDF',
                color: AppTheme.error,
                isLoading: _generating,
                onTap: _downloadPdf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share / Print',
                color: AppTheme.accent,
                isLoading: false,
                onTap: _sharePdf,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: const TextStyle(color: AppTheme.error, fontSize: 12)),
            ),
          ),

        const SizedBox(height: 12),

        // Live PDF preview using the `printing` package
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
                build: (_) => widget.pdfService.generatePdf(
                  profile: widget.profile,
                  job: widget.job,
                ),
                allowSharing: true,
                allowPrinting: true,
                canDebug: false,
                pdfPreviewPageDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
                scrollViewDecoration:  BoxDecoration(
                  color: AppTheme.bgOf(context),
                ),
                previewPageMargin:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                loadingWidget:  Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppTheme.accent),
                      SizedBox(height: 12),
                      Text('Building your resume...',
                          style: TextStyle(
                              color: AppTheme.textSecondaryOf(context), fontSize: 13)),
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

  Future<void> _downloadPdf() async {
    setState(() { _generating = true; _error = null; });
    try {
      final bytes = await widget.pdfService.generatePdf(
        profile: widget.profile,
        job: widget.job,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename:
        '${widget.job.companyName}_${widget.job.roleTitle}_Resume.pdf'
            .replaceAll(' ', '_'),
      );
    } catch (e) {
      setState(() => _error = 'PDF error: $e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _sharePdf() async {
    try {
      final bytes = await widget.pdfService.generatePdf(
        profile: widget.profile,
        job: widget.job,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Resume_${widget.job.roleTitle}.pdf'.replaceAll(' ', '_'),
      );
    } catch (e) {
      setState(() => _error = 'Share error: $e');
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.job.generatedResume as String));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume text copied to clipboard'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}

// ─── Improvement Tab ──────────────────────────────────────────────────────────
class _ImprovementTab extends StatelessWidget {
  final String improvementPlan;
  final List<String> missingSkills;
  final dynamic job;
  const _ImprovementTab(
      {required this.improvementPlan,
        required this.missingSkills,
        required this.job});

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
              'You have all required skills. Your resume is fully optimized for this role.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
        ),
      );
    }

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
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingSkills.map((s) {
              final maxW = MediaQuery.of(context).size.width - 40;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
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
              );
            }).toList(),
          ),

          if (improvementPlan.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Your Action Plan',
              subtitle: 'AI-generated steps to close the gap',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
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
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
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
              width: 18, height: 18,
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





//
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/foundation.dart';
// import '../../data/models/job_application_model.dart';
// import '../../data/models/master_profile_model.dart';
// // import '../models/master_profile_model.dart';
// // import '../models/job_application_model.dart';
//
// class ResumePdfService {
//   // Brand colors
//   static const _accent = PdfColor.fromInt(0xFF6C63FF);
//   static const _dark = PdfColor.fromInt(0xFF1A1A2E);
//   static const _text = PdfColor.fromInt(0xFF2D2D3A);
//   static const _muted = PdfColor.fromInt(0xFF6B6B80);
//   static const _light = PdfColor.fromInt(0xFFF5F5FF);
//   static const _divider = PdfColor.fromInt(0xFFE0E0F0);
//   static const _white = PdfColors.white;
//
//   Future<Uint8List> generatePdf({
//     required MasterProfile profile,
//     required JobApplication job,
//   }) async {
//     final doc = pw.Document();
//     final fonts = await _loadFonts();
//
//     doc.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.zero,
//         build: (ctx) => [
//           _buildHeader(profile, fonts),
//           pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 32),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.SizedBox(height: 20),
//                 _buildSummary(job, fonts),
//                 pw.SizedBox(height: 18),
//                 _buildTwoColumnBody(profile, job, fonts),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//
//     return doc.save();
//   }
//
//   // ── Header ─────────────────────────────────────────────────────────────────
//   pw.Widget _buildHeader(MasterProfile profile, _Fonts f) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.fromLTRB(32, 32, 32, 24),
//       decoration: const pw.BoxDecoration(color: _dark),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(
//             profile.fullName.isNotEmpty ? profile.fullName : 'Your Name',
//             style: pw.TextStyle(
//               font: f.bold,
//               fontSize: 28,
//               color: _white,
//               letterSpacing: 0.5,
//             ),
//           ),
//           pw.SizedBox(height: 10),
//           // Contact row
//           pw.Wrap(
//             spacing: 16,
//             runSpacing: 4,
//             children: [
//               if (profile.email.isNotEmpty)
//                 _contactChip(profile.email, f),
//               if (profile.phone.isNotEmpty)
//                 _contactChip(profile.phone, f),
//               if (profile.location.isNotEmpty)
//                 _contactChip(profile.location, f),
//               if (profile.linkedIn != null && profile.linkedIn!.isNotEmpty)
//                 _contactChip(_cleanUrl(profile.linkedIn!), f),
//               if (profile.github != null && profile.github!.isNotEmpty)
//                 _contactChip(_cleanUrl(profile.github!), f),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   pw.Widget _contactChip(String text, _Fonts f) {
//     return pw.Text(
//       text,
//       style: pw.TextStyle(
//         font: f.regular,
//         fontSize: 9,
//         color: const PdfColor.fromInt(0xFFCCCCEE),
//       ),
//     );
//   }
//
//   // ── Summary ────────────────────────────────────────────────────────────────
//   pw.Widget _buildSummary(JobApplication job, _Fonts f) {
//     // Extract first paragraph from generated resume as summary
//     final lines = job.generatedResume
//         .split('\n')
//         .map((l) => l.trim())
//         .where((l) => l.isNotEmpty)
//         .toList();
//
//     String summary = '';
//     for (final line in lines) {
//       if (!line.startsWith('•') &&
//           !line.toUpperCase().contains('SUMMARY') &&
//           !line.toUpperCase().contains('SKILLS') &&
//           !line.toUpperCase().contains('EXPERIENCE') &&
//           !line.toUpperCase().contains('EDUCATION') &&
//           line.length > 40) {
//         summary = line;
//         break;
//       }
//     }
//
//     if (summary.isEmpty) return pw.SizedBox();
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('PROFESSIONAL SUMMARY', f),
//         pw.SizedBox(height: 6),
//         pw.Text(
//           summary,
//           style: pw.TextStyle(
//             font: f.regular,
//             fontSize: 9.5,
//             color: _text,
//             lineSpacing: 2,
//           ),
//         ),
//         pw.SizedBox(height: 4),
//         _dividerLine(),
//       ],
//     );
//   }
//
//   // ── Two-column body ────────────────────────────────────────────────────────
//   pw.Widget _buildTwoColumnBody(
//       MasterProfile profile, JobApplication job, _Fonts f) {
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         // Left column — 62%
//         pw.Expanded(
//           flex: 62,
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildExperienceSection(profile, job, f),
//               pw.SizedBox(height: 16),
//               _buildEducationSection(profile, f),
//             ],
//           ),
//         ),
//         pw.SizedBox(width: 20),
//         // Right column — 38%
//         pw.Expanded(
//           flex: 38,
//           child: pw.Container(
//             padding: const pw.EdgeInsets.all(14),
//             decoration: pw.BoxDecoration(
//               color: _light,
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 _buildSkillsSection(profile, job, f),
//                 if (profile.certifications.isNotEmpty) ...[
//                   pw.SizedBox(height: 14),
//                   _buildCertSection(profile, f),
//                 ],
//                 if (profile.languages.isNotEmpty) ...[
//                   pw.SizedBox(height: 14),
//                   _buildLanguagesSection(profile, f),
//                 ],
//                 if (profile.softSkills.isNotEmpty) ...[
//                   pw.SizedBox(height: 14),
//                   _buildSoftSkillsSection(profile, f),
//                 ],
//                 if (job.matchedSkills.isNotEmpty) ...[
//                   pw.SizedBox(height: 14),
//                   _buildMatchedSection(job, f),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Experience ─────────────────────────────────────────────────────────────
//   pw.Widget _buildExperienceSection(
//       MasterProfile profile, JobApplication job, _Fonts f) {
//     // Extract experience bullets from AI resume text
//     final expBullets = _extractSection(job.generatedResume, 'EXPERIENCE');
//
//     if (profile.experiences.isEmpty && expBullets.isEmpty) {
//       return pw.SizedBox();
//     }
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('EXPERIENCE', f),
//         pw.SizedBox(height: 8),
//         if (expBullets.isNotEmpty)
//         // Use AI-generated bullets (better language)
//           ...profile.experiences.asMap().entries.map((entry) {
//             final exp = entry.value;
//             final desc = exp.professionalDescription.isNotEmpty
//                 ? exp.professionalDescription
//                 : exp.rawDescription;
//             final bullets = desc
//                 .split('\n')
//                 .map((l) => l.trim())
//                 .where((l) => l.isNotEmpty)
//                 .toList();
//
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Expanded(
//                       child: pw.Text(
//                         exp.title,
//                         style: pw.TextStyle(
//                           font: f.semiBold,
//                           fontSize: 10,
//                           color: _dark,
//                         ),
//                       ),
//                     ),
//                     pw.Text(
//                       exp.duration,
//                       style: pw.TextStyle(
//                         font: f.italic,
//                         fontSize: 8.5,
//                         color: _muted,
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.Text(
//                   exp.organization,
//                   style: pw.TextStyle(
//                     font: f.regular,
//                     fontSize: 9,
//                     color: _accent,
//                   ),
//                 ),
//                 pw.SizedBox(height: 4),
//                 ...bullets.map((b) => pw.Padding(
//                   padding: const pw.EdgeInsets.only(bottom: 2),
//                   child: pw.Row(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('• ',
//                           style: pw.TextStyle(
//                               font: f.bold, fontSize: 9, color: _accent)),
//                       pw.Expanded(
//                         child: pw.Text(
//                           b.replaceAll('•', '').trim(),
//                           style: pw.TextStyle(
//                               font: f.regular,
//                               fontSize: 9,
//                               color: _text,
//                               lineSpacing: 1.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//                 if (exp.toolsUsed.isNotEmpty)
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.only(top: 3),
//                     child: pw.Text(
//                       'Tools: ${exp.toolsUsed.join(" • ")}',
//                       style: pw.TextStyle(
//                           font: f.italic, fontSize: 8, color: _muted),
//                     ),
//                   ),
//                 pw.SizedBox(height: 10),
//               ],
//             );
//           })
//         else
//           pw.Text(
//             'Experience details in profile',
//             style: pw.TextStyle(font: f.regular, fontSize: 9, color: _muted),
//           ),
//         _dividerLine(),
//       ],
//     );
//   }
//
//   // ── Education ──────────────────────────────────────────────────────────────
//   pw.Widget _buildEducationSection(MasterProfile profile, _Fonts f) {
//     if (profile.education.isEmpty) return pw.SizedBox();
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('EDUCATION', f),
//         pw.SizedBox(height: 8),
//         ...profile.education.map((edu) => pw.Padding(
//           padding: const pw.EdgeInsets.only(bottom: 8),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Expanded(
//                     child: pw.Text(
//                       edu.degree,
//                       style: pw.TextStyle(
//                           font: f.semiBold, fontSize: 10, color: _dark),
//                     ),
//                   ),
//                   pw.Text(
//                     edu.year,
//                     style: pw.TextStyle(
//                         font: f.italic, fontSize: 8.5, color: _muted),
//                   ),
//                 ],
//               ),
//               pw.Text(
//                 edu.institution,
//                 style: pw.TextStyle(
//                     font: f.regular, fontSize: 9, color: _accent),
//               ),
//               if (edu.grade != null && edu.grade!.isNotEmpty)
//                 pw.Text(
//                   'Grade: ${edu.grade}',
//                   style: pw.TextStyle(
//                       font: f.italic, fontSize: 8.5, color: _muted),
//                 ),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
//
//   // ── Skills (right column) ──────────────────────────────────────────────────
//   pw.Widget _buildSkillsSection(
//       MasterProfile profile, JobApplication job, _Fonts f) {
//     if (profile.skills.isEmpty) return pw.SizedBox();
//
//     // Prioritize matched skills first
//     final matched = job.matchedSkills.toSet();
//     final sorted = [
//       ...profile.skills.where((s) => matched.contains(s)),
//       ...profile.skills.where((s) => !matched.contains(s)),
//     ];
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sideTitle('TECHNICAL SKILLS', f),
//         pw.SizedBox(height: 6),
//         pw.Wrap(
//           spacing: 4,
//           runSpacing: 4,
//           children: sorted.take(16).map((s) {
//             final isMatch = matched.contains(s);
//             return pw.Container(
//               padding:
//               const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//               decoration: pw.BoxDecoration(
//                 color: isMatch
//                     ? const PdfColor.fromInt(0xFF6C63FF)
//                     : const PdfColor.fromInt(0xFFE8E8F8),
//                 borderRadius: pw.BorderRadius.circular(3),
//               ),
//               child: pw.Text(
//                 s,
//                 style: pw.TextStyle(
//                   font: f.semiBold,
//                   fontSize: 7.5,
//                   color: isMatch ? _white : _text,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   // ── Certifications ─────────────────────────────────────────────────────────
//   pw.Widget _buildCertSection(MasterProfile profile, _Fonts f) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sideTitle('CERTIFICATIONS', f),
//         pw.SizedBox(height: 6),
//         ...profile.certifications.map((c) => pw.Padding(
//           padding: const pw.EdgeInsets.only(bottom: 3),
//           child: pw.Row(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Container(
//                 width: 4,
//                 height: 4,
//                 margin: const pw.EdgeInsets.only(top: 3, right: 5),
//                 decoration: pw.BoxDecoration(
//                   color: _accent,
//                   shape: pw.BoxShape.circle,
//                 ),
//               ),
//               pw.Expanded(
//                 child: pw.Text(
//                   c,
//                   style: pw.TextStyle(
//                       font: f.regular, fontSize: 8.5, color: _text),
//                 ),
//               ),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
//
//   // ── Languages ──────────────────────────────────────────────────────────────
//   pw.Widget _buildLanguagesSection(MasterProfile profile, _Fonts f) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sideTitle('LANGUAGES', f),
//         pw.SizedBox(height: 6),
//         pw.Wrap(
//           spacing: 4,
//           runSpacing: 4,
//           children: profile.languages.map((l) => pw.Container(
//             padding:
//             const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//             decoration: pw.BoxDecoration(
//               color: const PdfColor.fromInt(0xFFE8E8F8),
//               borderRadius: pw.BorderRadius.circular(3),
//             ),
//             child: pw.Text(
//               l,
//               style: pw.TextStyle(
//                   font: f.regular, fontSize: 8, color: _text),
//             ),
//           )).toList(),
//         ),
//       ],
//     );
//   }
//
//   // ── Soft Skills ────────────────────────────────────────────────────────────
//   pw.Widget _buildSoftSkillsSection(MasterProfile profile, _Fonts f) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sideTitle('SOFT SKILLS', f),
//         pw.SizedBox(height: 6),
//         ...profile.softSkills.map((s) => pw.Padding(
//           padding: const pw.EdgeInsets.only(bottom: 2),
//           child: pw.Row(
//             children: [
//               pw.Container(
//                 width: 4, height: 4,
//                 margin: const pw.EdgeInsets.only(top: 2, right: 5),
//                 decoration: pw.BoxDecoration(
//                     color: _accent, shape: pw.BoxShape.circle),
//               ),
//               pw.Text(s,
//                   style: pw.TextStyle(
//                       font: f.regular, fontSize: 8.5, color: _text)),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
//
//   // ── Matched keywords ───────────────────────────────────────────────────────
//   pw.Widget _buildMatchedSection(JobApplication job, _Fonts f) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         _sideTitle('ATS MATCH', f),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           '${job.matchScore}% match for ${job.roleTitle}',
//           style: pw.TextStyle(
//             font: f.semiBold,
//             fontSize: 8,
//             color: job.matchScore >= 70
//                 ? const PdfColor.fromInt(0xFF4CAF82)
//                 : const PdfColor.fromInt(0xFFFFB830),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────────────────
//   pw.Widget _sectionTitle(String title, _Fonts f) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           title,
//           style: pw.TextStyle(
//             font: f.bold,
//             fontSize: 9,
//             color: _accent,
//             letterSpacing: 1.5,
//           ),
//         ),
//         pw.SizedBox(height: 3),
//         pw.Container(height: 1.5, color: _accent),
//       ],
//     );
//   }
//
//   pw.Widget _sideTitle(String title, _Fonts f) {
//     return pw.Text(
//       title,
//       style: pw.TextStyle(
//         font: f.bold,
//         fontSize: 8,
//         color: _dark,
//         letterSpacing: 1.2,
//       ),
//     );
//   }
//
//   pw.Widget _dividerLine() {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 10),
//       child: pw.Container(height: 0.5, color: _divider),
//     );
//   }
//
//   List<String> _extractSection(String resume, String section) {
//     final lines = resume.split('\n');
//     final bullets = <String>[];
//     bool inSection = false;
//     for (final line in lines) {
//       if (line.toUpperCase().contains(section)) {
//         inSection = true;
//         continue;
//       }
//       if (inSection) {
//         if (line.trim().isEmpty) continue;
//         if (RegExp(r'^[A-Z\s]{4,}$').hasMatch(line.trim()) &&
//             !line.trim().startsWith('•')) {
//           break;
//         }
//         if (line.trim().startsWith('•') || line.trim().isNotEmpty) {
//           bullets.add(line.trim());
//         }
//       }
//     }
//     return bullets;
//   }
//
//   String _cleanUrl(String url) {
//     return url
//         .replaceAll('https://', '')
//         .replaceAll('http://', '')
//         .replaceAll('www.', '');
//   }
//
//   Future<_Fonts> _loadFonts() async {
//     return _Fonts(
//       regular: await PdfGoogleFonts.nunitoRegular(),
//       bold: await PdfGoogleFonts.nunitoBold(),
//       semiBold: await PdfGoogleFonts.nunitoSemiBold(),
//       italic: await PdfGoogleFonts.nunitoItalic(),
//     );
//   }
// }
//
// class _Fonts {
//   final pw.Font regular;
//   final pw.Font bold;
//   final pw.Font semiBold;
//   final pw.Font italic;
//
//   _Fonts({
//     required this.regular,
//     required this.bold,
//     required this.semiBold,
//     required this.italic,
//   });
// }