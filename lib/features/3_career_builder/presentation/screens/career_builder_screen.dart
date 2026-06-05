import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/job_application_model.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
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
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
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

  Map<String, int> _counts(List apps) {
    final m = <String, int>{'all': apps.length};
    for (final s in ['draft', 'applied', 'interview', 'offer', 'rejected']) {
      m[s] = apps.where((a) => a.status == s).length;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.bgOf(context);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
          child: Consumer2<MasterProfileProvider, JobApplicationProvider>(
            builder: (_, profileProv, jobProv, __) {
              final allApps = jobProv.applications;
              final filtered = _filter == 'all'
                  ? allApps
                  : allApps.where((a) => a.status == _filter).toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header(context, profileProv)),
                  SliverToBoxAdapter(child: _profileBanner(context, profileProv)),
                  SliverToBoxAdapter(child: _applyBtn(context, profileProv)),

                  // ── Tracker header ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                      child: SectionHeader(
                        title: 'Application Tracker',
                        subtitle: '${allApps.length} applications',
                      ),
                    ),
                  ),

                  // ── Filter bar ──
                  SliverToBoxAdapter(
                    child: _FilterBar(
                      selected: _filter,
                      counts: _counts(allApps),
                      onSelect: (f) => setState(() => _filter = f),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // ── List ──
                  if (allApps.isEmpty)
                    SliverToBoxAdapter(child: _emptyApps(context))
                  else if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'No "$_filter" applications yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _AppCard(
                            app: filtered[i],
                            onTap: () {
                              jobProv.setCurrentJob(filtered[i]);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const OptimizationViewScreen()));
                            },
                            onDelete: () =>
                                jobProv.deleteApplication(filtered[i].id),
                            onStatusChange: (s) =>
                                jobProv.updateStatus(filtered[i].id, s),
                          ),
                          childCount: filtered.length,
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

  Widget _header(BuildContext context, MasterProfileProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.work_outline_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Career Architect',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context))),
          Text('Build resumes that pass ATS',
              style: Theme.of(context).textTheme.bodyMedium),
        ])),
        IconButton(
          icon: Icon(Icons.person_outline_rounded,
              color: AppTheme.textSecondaryOf(context)),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MasterProfileScreen())),
        ),
      ]),
    );
  }

  Widget _profileBanner(BuildContext context, MasterProfileProvider p) {
    final ok = p.isComplete;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MasterProfileScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: ok
              ? [const Color(0xFF00C9FF).withOpacity(0.12),
            const Color(0xFF92FE9D).withOpacity(0.08)]
              : [AppTheme.amber.withOpacity(0.1),
            AppTheme.amber.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: ok ? const Color(0xFF00C9FF).withOpacity(0.3)
                  : AppTheme.amber.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(ok ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
              color: ok ? const Color(0xFF00C9FF) : AppTheme.amber, size: 28),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ok ? 'Master Profile Ready' : 'Complete Your Master Profile',
                style: GoogleFonts.spaceGrotesk(fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context))),
            const SizedBox(height: 3),
            Text(ok
                ? '${p.profile.skills.length} skills • ${p.profile.experiences.length} experiences'
                : 'Add your details once to generate unlimited targeted resumes',
                style: Theme.of(context).textTheme.bodyMedium),
          ])),
          Icon(Icons.chevron_right_rounded,
              color: AppTheme.textSecondaryOf(context)),
        ]),
      ),
    );
  }

  Widget _applyBtn(BuildContext context, MasterProfileProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GradientButton(
        label: 'Target a New Job',
        icon: Icons.rocket_launch_rounded,
        onPressed: p.isComplete
            ? () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JdInputScreen()))
            : () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Complete your Master Profile first'),
              backgroundColor: AppTheme.amber));
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MasterProfileScreen()));
        },
      ),
    );
  }

  Widget _emptyApps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderOf(context)),
        ),
        child: Column(children: [
          Icon(Icons.business_center_outlined,
              color: AppTheme.textSecondaryOf(context), size: 40),
          const SizedBox(height: 16),
          Text('No applications yet',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: 8),
          Text('Paste a job description and watch your resume get rewritten to match it perfectly.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String selected;
  final Map<String, int> counts;
  final Function(String) onSelect;

  const _FilterBar({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  static const _items = [
    ('all',       'All',         Color(0xFF6C63FF)),
    ('draft',     'Draft',       Color(0xFF8888AA)),
    ('applied',   'Applied',     Color(0xFF6C63FF)),
    ('interview', 'Interview',   Color(0xFFFFB830)),
    ('offer',     'Offer',   Color(0xFF4CAF82)),
    ('rejected',  'Rejected',    Color(0xFFFF5252)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label, color) = _items[i];
          final active = selected == key;
          final count = counts[key] ?? 0;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? color.withOpacity(0.15)
                    : AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? color : AppTheme.borderOf(context),
                    width: active ? 1.5 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? color
                          : AppTheme.textSecondaryOf(context),
                    )),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withOpacity(0.25)
                          : AppTheme.surfaceElevOf(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? color
                              : AppTheme.textSecondaryOf(context),
                        )),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────
class _AppCard extends StatelessWidget {
  final JobApplication app;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;

  const _AppCard({
    required this.app,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  static const _statusColors = {
    'draft':     Color(0xFF8888AA),
    'applied':   Color(0xFF6C63FF),
    'interview': Color(0xFFFFB830),
    'offer':     Color(0xFF4CAF82),
    'rejected':  Color(0xFFFF5252),
  };

  static const _statusLabels = {
    'draft':     'Draft',
    'applied':   'Applied',
    'interview': 'Interview',
    'offer':     'Offer',
    'rejected':  'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _statusColors[app.status] ?? AppTheme.textSecondaryOf(context);
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.roleTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(app.companyName,
                  style: Theme.of(context).textTheme.bodyMedium),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${app.matchScore}%',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scoreColor)),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: AppTheme.textSecondaryOf(context), size: 18),
              color: AppTheme.surfaceElevOf(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onSelected: (v) {
                if (v == 'delete') onDelete();
                else onStatusChange(v);
              },
              itemBuilder: (_) => [
                ..._statusLabels.entries.map((e) => PopupMenuItem(
                  value: e.key,
                  child: Row(children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: _statusColors[e.key],
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(e.value),
                  ]),
                )),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: AppTheme.error, size: 16),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppTheme.error)),
                  ]),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_statusLabels[app.status] ?? app.status,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
            const SizedBox(width: 10),
            Text(DateFormat('MMM d, yyyy').format(app.createdAt),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.textSecondaryOf(context))),
          ]),
        ]),
      ),
    );
  }
}