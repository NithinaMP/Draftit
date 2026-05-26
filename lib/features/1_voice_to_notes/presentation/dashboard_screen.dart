import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/lectures_provider.dart';
import '../data/models/lecture_model.dart';
// import '../../../auth/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/router/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);

    // Start listening to Firestore stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LecturesProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Top gradient blob
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.07),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Consumer<LecturesProvider>(
                    builder: (context, provider, _) {
                      return CustomScrollView(
                        slivers: [
                          // Hero section
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _heroAnim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(_heroAnim),
                                child: _buildHero(context),
                              ),
                            ),
                          ),

                          // Stats row
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: _buildStats(provider),
                            ),
                          ),

                          // Section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              child: SectionHeader(
                                title: 'Your Lectures',
                                subtitle:
                                '${provider.lectures.length} notes captured',
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 16)),

                          // Lectures list
                          if (provider.isLoading)
                            SliverToBoxAdapter(child: _buildShimmerList())
                          else if (provider.error != null)
                            SliverToBoxAdapter(
                                child: _buildError(provider.error!))
                          else if (provider.lectures.isEmpty)
                              SliverToBoxAdapter(child: _buildEmpty())
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                        (context, i) => _LectureCard(
                                      lecture: provider.lectures[i],
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRouter.notesViewer,
                                        arguments: provider.lectures[i].id,
                                      ),
                                      onDelete: () =>
                                          provider.deleteLecture(
                                              provider.lectures[i].id),
                                    ),
                                    childCount: provider.lectures.length,
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

          // FAB
          Positioned(
            bottom: 28,
            right: 24,
            child: _RecordFAB(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRouter.recorder);
                // Refresh is automatic via Firestore stream
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D40FF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'DraftIt',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          _ProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final name = auth.user?.displayName?.split(' ').first ??
        auth.user?.email?.split('@').first ??
        'Student';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name 👋',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppTheme.textPrimary, AppTheme.accentLight],
            ).createShader(bounds),
            child: Text(
              'Your\nKnowledge Hub',
              style: GoogleFonts.playfairDisplay(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'From classroom to career, one draft at a time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(LecturesProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Lectures',
            value: '${provider.lectures.length}',
            icon: Icons.mic_none_rounded,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Skills',
            value: '${provider.totalSkills}',
            icon: Icons.bolt_rounded,
            color: AppTheme.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Mastered',
            value: '${provider.masteredCount}',
            icon: Icons.verified_rounded,
            color: AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
              (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerBox(
              width: double.infinity,
              height: 100,
              borderRadius: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.mic_none_rounded,
                    color: AppTheme.accent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No lectures yet',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the microphone button to record your first lecture and let AI transform it into structured notes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lecture Card ─────────────────────────────────────────────────────────────
class _LectureCard extends StatelessWidget {
  final LectureModel lecture;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LectureCard({
    required this.lecture,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lecture.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CardMenu(onDelete: onDelete),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lecture.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Skills chips
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: lecture.extractedSkills
                          .take(3)
                          .map((s) => SkillChip(label: s))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Date
                  Text(
                    DateFormat('MMM d').format(lecture.createdAt),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card Menu ────────────────────────────────────────────────────────────────
class _CardMenu extends StatelessWidget {
  final VoidCallback onDelete;
  const _CardMenu({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
      color: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'delete') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text('Delete lecture?'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ),
              ],
            ),
          );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Profile Menu ─────────────────────────────────────────────────────────────
class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final initial = (auth.user?.displayName?.isNotEmpty == true
        ? auth.user!.displayName!
        : auth.user?.email ?? 'U')
        .substring(0, 1)
        .toUpperCase();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _ProfileSheet(
            email: auth.user?.email ?? '',
            onSignOut: () async {
              await auth.signOut();
              Navigator.pop(context);
            },
          ),
        );
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppTheme.accent.withOpacity(0.2),
        child: Text(
          initial,
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.accentLight,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final String email;
  final VoidCallback onSignOut;

  const _ProfileSheet({required this.email, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Sign Out',
            icon: Icons.logout_rounded,
            onPressed: onSignOut,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Record FAB ───────────────────────────────────────────────────────────────
class _RecordFAB extends StatefulWidget {
  final VoidCallback onPressed;
  const _RecordFAB({required this.onPressed});

  @override
  State<_RecordFAB> createState() => _RecordFABState();
}

class _RecordFABState extends State<_RecordFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, Color(0xFF9D40FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}