import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/job_application_provider.dart';
// import '../providers/master_profile_provider.dart';
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
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Consumer<JobApplicationProvider>(
          builder: (_, provider, __) {
            final job = provider.currentJob;
            if (job == null) {
              return const Center(child: Text('No job selected'));
            }
            return Column(
              children: [
                _buildHeader(context, provider, job),
                _buildScoreHero(job),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _AnalysisTab(job: job, provider: provider),
                      _ResumeTab(job: job, provider: provider),
                      _ImprovementTab(
                        improvementPlan: provider.improvementPlan,
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

  Widget _buildHeader(BuildContext context, JobApplicationProvider provider,
      dynamic job) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary),
            onPressed: () {
              provider.reset();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.roleTitle as String,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job.companyName as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Regenerate button
          Consumer<MasterProfileProvider>(
            builder: (_, profileProvider, __) => IconButton(
              icon: provider.isProcessing
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent))
                  : const Icon(Icons.refresh_rounded,
                  color: AppTheme.textSecondary),
              tooltip: 'Regenerate with updated profile',
              onPressed: provider.isProcessing
                  ? null
                  : () => provider.regenerateResume(
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
      padding: const EdgeInsets.all(20),
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
          // Score circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeWidth: 7,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(job.matchedSkills as List).length} of ${(job.requiredSkills as List).length} required skills matched',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                // Tone badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tone: ${(job.companyTone as String)[0].toUpperCase()}${(job.companyTone as String).substring(1)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.bg,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.spaceGrotesk(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Analysis'),
            Tab(text: 'Resume'),
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
    final matched = job.matchedSkills as List<String>;
    final missing = job.missingSkills as List<String>;
    final required = job.requiredSkills as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matched skills
          if (matched.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Skills You Have (${matched.length})',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matched
                  .map((s) => _SkillBadge(
                  label: s, color: AppTheme.success, icon: Icons.check))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Missing skills
          if (missing.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.error, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Missing Skills (${missing.length})',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missing
                  .map((s) => _SkillBadge(
                  label: s, color: AppTheme.error, icon: Icons.add))
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Add missing skill prompt
            Consumer<MasterProfileProvider>(
              builder: (_, profileProvider, __) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: AppTheme.amber.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppTheme.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Have some of these skills? Add them to your Master Profile and tap Regenerate to boost your score.',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // All required skills
          const SectionHeader(title: 'All Required Skills'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: required
                .map((s) => SkillChip(
              label: s,
              highlighted: matched.contains(s),
            ))
                .toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Resume Tab ───────────────────────────────────────────────────────────────
class _ResumeTab extends StatelessWidget {
  final dynamic job;
  final JobApplicationProvider provider;

  const _ResumeTab({required this.job, required this.provider});

  @override
  Widget build(BuildContext context) {
    final resume = job.generatedResume as String;

    if (provider.isProcessing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(provider.statusLabel,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (resume.isEmpty) {
      return Center(
        child: Text('No resume generated yet.',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Column(
      children: [
        // Copy button bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: resume));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Resume copied to clipboard'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Resume'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    foregroundColor: AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Resume content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: SelectableText(
                resume,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.7,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded,
                  color: AppTheme.success, size: 48),
              const SizedBox(height: 16),
              Text(
                'Full Match!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have all the required skills for this role. Your resume is fully optimized.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gap alert header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.error, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skill Gap Alert',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are missing ${missingSkills.length} required skill${missingSkills.length > 1 ? "s" : ""} for ${job.roleTitle}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Missing skills chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingSkills
                .map((s) => _SkillBadge(
                label: s, color: AppTheme.error, icon: Icons.close))
                .toList(),
          ),

          const SizedBox(height: 24),

          // AI improvement plan
          if (improvementPlan.isNotEmpty) ...[
            const SectionHeader(
              title: 'Your Action Plan',
              subtitle: 'AI-generated steps to close the gap',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accent.withOpacity(0.25)),
              ),
              child: Text(
                improvementPlan,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.7,
                ),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Skill Badge ──────────────────────────────────────────────────────────────
class _SkillBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SkillBadge(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}