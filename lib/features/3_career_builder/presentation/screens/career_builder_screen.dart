import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/job_application_model.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/master_profile_provider.dart';
// import '../providers/job_application_provider.dart';
// import '../data/models/job_application_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'master_profile_screen.dart';
import 'jd_input_screen.dart';
import 'optimization_view_screen.dart';

class CareerBuilderScreen extends StatefulWidget {
  const CareerBuilderScreen({super.key});

  @override
  State<CareerBuilderScreen> createState() => _CareerBuilderScreenState();
}

class _CareerBuilderScreenState extends State<CareerBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;


  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MasterProfileProvider>().load();
      await context.read<JobApplicationProvider>().loadApplications();
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
          opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
          child: Consumer2<MasterProfileProvider, JobApplicationProvider>(
            builder: (_, profileProvider, jobProvider, __) {

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, profileProvider)),
                  SliverToBoxAdapter(
                    child: _buildProfileBanner(context, profileProvider),
                  ),
                  SliverToBoxAdapter(
                    child: _buildApplyButton(context, profileProvider),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                      child: SectionHeader(
                        title: 'Application Tracker',
                        subtitle:
                        '${jobProvider.applications.length} applications',

                      ),
                    ),
                  ),




                  if (jobProvider.applications.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyApps(context))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _ApplicationCard(
                            app: jobProvider.applications[i],
                            onTap: () {
                              jobProvider.setCurrentJob(
                                  jobProvider.applications[i]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const OptimizationViewScreen(),
                                ),
                              );
                            },
                            onDelete: () => jobProvider.deleteApplication(
                                jobProvider.applications[i].id),
                            onStatusChange: (status) =>
                                jobProvider.updateStatus(
                                  jobProvider.applications[i].id,
                                  status,
                                ),
                          ),
                          childCount: jobProvider.applications.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context,MasterProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Career Architect',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                Text(
                  'Build resumes that pass ATS',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon:  Icon(Icons.person_outline_rounded,
                color: AppTheme.textSecondaryOf(context)),
            tooltip: 'Edit Master Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MasterProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBanner(
      BuildContext context, MasterProfileProvider provider) {
    final isComplete = provider.isComplete;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MasterProfileScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isComplete
                ? [
              const Color(0xFF00C9FF).withOpacity(0.12),
              const Color(0xFF92FE9D).withOpacity(0.08),
            ]
                : [
              AppTheme.amber.withOpacity(0.1),
              AppTheme.amber.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete
                ? const Color(0xFF00C9FF).withOpacity(0.3)
                : AppTheme.amber.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isComplete
                  ? Icons.verified_user_rounded
                  : Icons.warning_amber_rounded,
              color: isComplete
                  ? const Color(0xFF00C9FF)
                  : AppTheme.amber,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isComplete
                        ? 'Master Profile Ready'
                        : 'Complete Your Master Profile',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isComplete
                        ? '${provider.profile.skills.length} skills • ${provider.profile.experiences.length} experiences'
                        : 'Add your details once to generate unlimited targeted resumes',
                    style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildApplyButton(
      BuildContext context, MasterProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GradientButton(
        label: 'Target a New Job',
        icon: Icons.rocket_launch_rounded,
        onPressed: provider.isComplete
            ? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JdInputScreen()),
        )
            : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Complete your Master Profile first'),
              backgroundColor: AppTheme.amber,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MasterProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyApps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: Column(
          children: [
             Icon(Icons.business_center_outlined,
                color: AppTheme.textSecondaryOf(context), size: 40),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paste a job description and watch your resume get rewritten to match it perfectly.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final JobApplication app;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;

  const _ApplicationCard({
    required this.app,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  static const _statusColors = {
    'draft': AppTheme.textSecondary,
    'applied': AppTheme.accent,
    'interview': AppTheme.amber,
    'offer': AppTheme.success,
    'rejected': AppTheme.error,
  };

  static const _statusLabels = {
    'draft': 'Draft',
    'applied': 'Applied',
    'interview': 'Interview',
    'offer': 'Offer ',         //🎉
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[app.status] ?? AppTheme.textSecondaryOf(context);
    final scoreColor = app.matchScore >= 80
        ? AppTheme.success
        : app.matchScore >= 60
        ? AppTheme.amber
        : AppTheme.error;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.roleTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(app.companyName,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                // Match score badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${app.matchScore}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon:  Icon(Icons.more_vert,
                      color: AppTheme.textSecondaryOf(context), size: 18),
                  color: AppTheme.surfaceElevOf(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                    else onStatusChange(v);
                  },
                  itemBuilder: (_) => [
                    ..._statusLabels.entries.map(
                          (e) => PopupMenuItem(
                        value: e.key,
                        child: Row(children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _statusColors[e.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.value),
                        ]),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: AppTheme.error, size: 16),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppTheme.error)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabels[app.status] ?? app.status,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMM d, yyyy').format(app.createdAt),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}