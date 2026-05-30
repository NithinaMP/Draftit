import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../1_voice_to_notes/providers/lectures_provider.dart';
import '../../data/models/master_profile_model.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/master_profile_provider.dart';
// import '../../1_voice_to_notes/providers/lectures_provider.dart';
// import '../data/models/master_profile_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class MasterProfileScreen extends StatefulWidget {
  const MasterProfileScreen({super.key});

  @override
  State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

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
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<MasterProfileProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accent));
                  }
                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _BasicInfoTab(provider: provider),
                      _SkillsTab(provider: provider),
                      _ExperienceTab(provider: provider),
                      _EducationTab(provider: provider),
                    ],
                  );
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Master Profile',
                    style: Theme.of(context).textTheme.titleLarge),
                Text('Set up once, generate unlimited resumes',
                    style: Theme.of(context).textTheme.bodyMedium),
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
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
            Tab(text: 'Education'),
          ],
        ),
      ),
    );
  }
}

// ─── Basic Info Tab ───────────────────────────────────────────────────────────
class _BasicInfoTab extends StatefulWidget {
  final MasterProfileProvider provider;
  const _BasicInfoTab({required this.provider});

  @override
  State<_BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<_BasicInfoTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _linkedInCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _portfolioCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.provider.profile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone);
    _locationCtrl = TextEditingController(text: p.location);
    _linkedInCtrl = TextEditingController(text: p.linkedIn ?? '');
    _githubCtrl = TextEditingController(text: p.github ?? '');
    _portfolioCtrl = TextEditingController(text: p.portfolio ?? '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _locationCtrl,
      _linkedInCtrl, _githubCtrl, _portfolioCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _field(_nameCtrl, 'Full Name', Icons.person_outline_rounded),
          _field(_emailCtrl, 'Email', Icons.email_outlined,
              type: TextInputType.emailAddress),
          _field(_phoneCtrl, 'Phone', Icons.phone_outlined,
              type: TextInputType.phone),
          _field(_locationCtrl, 'Location (City, Country)',
              Icons.location_on_outlined),
          const SizedBox(height: 8),
          _divider('Online Presence (Optional)'),
          _field(_linkedInCtrl, 'LinkedIn URL', Icons.link_rounded),
          _field(_githubCtrl, 'GitHub URL', Icons.code_rounded),
          _field(_portfolioCtrl, 'Portfolio URL', Icons.web_rounded),
          const SizedBox(height: 20),
          if (_saved)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.success, size: 16),
                  const SizedBox(width: 6),
                  Text('Profile saved!',
                      style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Save Info',
            icon: Icons.save_outlined,
            onPressed: () async {
              await widget.provider.saveBasicInfo(
                fullName: _nameCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                phone: _phoneCtrl.text.trim(),
                location: _locationCtrl.text.trim(),
                linkedIn: _linkedInCtrl.text.trim().isEmpty
                    ? null : _linkedInCtrl.text.trim(),
                github: _githubCtrl.text.trim().isEmpty
                    ? null : _githubCtrl.text.trim(),
                portfolio: _portfolioCtrl.text.trim().isEmpty
                    ? null : _portfolioCtrl.text.trim(),
              );
              setState(() => _saved = true);
              Future.delayed(const Duration(seconds: 2),
                      () => setState(() => _saved = false));
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _divider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          const Expanded(child: Divider(color: AppTheme.border)),
        ],
      ),
    );
  }
}

// ─── Skills Tab ───────────────────────────────────────────────────────────────
class _SkillsTab extends StatefulWidget {
  final MasterProfileProvider provider;
  const _SkillsTab({required this.provider});

  @override
  State<_SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<_SkillsTab> {
  final _skillCtrl = TextEditingController();

  @override
  void dispose() {
    _skillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skills = widget.provider.profile.skills;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sync from lectures
          Consumer<LecturesProvider>(
            builder: (_, lectures, __) {
              final allSkills = lectures.lectures
                  .expand((l) => l.extractedSkills)
                  .toSet()
                  .toList();
              if (allSkills.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => widget.provider.syncLectureSkills(allSkills),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accent.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded,
                          color: AppTheme.accentLight, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sync ${allSkills.length} skills from your lectures',
                          style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.accentLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.add_rounded,
                          color: AppTheme.accentLight, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),

          // Add skill input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Add a skill',
                    hintText: 'e.g. Python, Excel, Public Speaking',
                    prefixIcon:
                    Icon(Icons.add_circle_outline_rounded, size: 18),
                  ),
                  onSubmitted: (v) {
                    widget.provider.addSkill(v);
                    _skillCtrl.clear();
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  widget.provider.addSkill(_skillCtrl.text);
                  _skillCtrl.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.accent, Color(0xFF9D40FF)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (skills.isEmpty)
            Text(
              'No skills added yet. Add manually or sync from your lectures above.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((s) => _RemovableChip(
                label: s,
                onRemove: () => widget.provider.removeSkill(s),
              ))
                  .toList(),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Experience Tab ───────────────────────────────────────────────────────────
class _ExperienceTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _ExperienceTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final experiences = provider.profile.experiences;
    return Column(
      children: [
        Expanded(
          child: experiences.isEmpty
              ? Center(
            child: Text(
              'No experiences yet.\nTap + to add projects, internships, etc.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: experiences.length,
            itemBuilder: (_, i) => _ExperienceCard(
              exp: experiences[i],
              provider: provider,
              onDelete: () => provider.removeExperience(experiences[i].id),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Add Experience',
            icon: Icons.add_rounded,
            onPressed: () => _showAddExperienceSheet(context, provider),
          ),
        ),
      ],
    );
  }

  static void _showAddExperienceSheet(
      BuildContext context, MasterProfileProvider provider) {
    final titleCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final toolsCtrl = TextEditingController();
    final proofCtrl = TextEditingController();
    String selectedType = 'project';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Experience',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                // Type selector
                Wrap(
                  spacing: 8,
                  children: ['project', 'internship', 'volunteering', 'freelance']
                      .map((t) => ChoiceChip(
                    label: Text(t[0].toUpperCase() + t.substring(1)),
                    selected: selectedType == t,
                    onSelected: (_) => setModal(() => selectedType = t),
                    selectedColor: AppTheme.accent.withOpacity(0.2),
                    labelStyle: GoogleFonts.spaceGrotesk(
                      color: selectedType == t
                          ? AppTheme.accentLight
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                _tf(titleCtrl, 'Title (e.g. Flutter Developer)'),
                _tf(orgCtrl, 'Organization / Company'),
                _tf(durationCtrl, 'Duration (e.g. Jun 2024 – Aug 2024)'),
                _tf(descCtrl, 'Describe what you did', maxLines: 4),
                _tf(toolsCtrl,
                    'Tools Used (comma separated: Flutter, Firebase)'),
                _tf(proofCtrl, 'Proof Link (GitHub, Drive) — Optional'),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Add Experience',
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final exp = provider.buildExperience(
                      title: titleCtrl.text.trim(),
                      organization: orgCtrl.text.trim(),
                      duration: durationCtrl.text.trim(),
                      rawDescription: descCtrl.text.trim(),
                      toolsUsed: toolsCtrl.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      type: selectedType,
                      proofLink: proofCtrl.text.trim().isEmpty
                          ? null
                          : proofCtrl.text.trim(),
                    );
                    provider.addExperience(exp);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _tf(TextEditingController c, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

// ─── Education Tab ────────────────────────────────────────────────────────────
class _EducationTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _EducationTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final edu = provider.profile.education;
    return Column(
      children: [
        Expanded(
          child: edu.isEmpty
              ? Center(
            child: Text(
              'No education added yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: edu.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined,
                      color: AppTheme.accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu[i].degree,
                            style:
                            Theme.of(context).textTheme.titleMedium),
                        Text(
                            '${edu[i].institution} • ${edu[i].year}${edu[i].grade != null ? " • ${edu[i].grade}" : ""}',
                            style:
                            Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 18),
                    onPressed: () => provider.removeEducation(i),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Add Education',
            icon: Icons.add_rounded,
            onPressed: () => _showAddEduSheet(context, provider),
          ),
        ),
      ],
    );
  }

  void _showAddEduSheet(BuildContext context, MasterProfileProvider provider) {
    final degreeCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Education',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: degreeCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Degree (e.g. B.Tech Computer Science)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration:
              const InputDecoration(labelText: 'Institution Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Year (e.g. 2021 – 2025)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gradeCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Grade/GPA (Optional)'),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Add',
              onPressed: () {
                if (degreeCtrl.text.trim().isEmpty) return;
                provider.addEducation(EducationEntry(
                  degree: degreeCtrl.text.trim(),
                  institution: instCtrl.text.trim(),
                  year: yearCtrl.text.trim(),
                  grade: gradeCtrl.text.trim().isEmpty
                      ? null
                      : gradeCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small shared widgets ─────────────────────────────────────────────────────
class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppTheme.accentLight)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final dynamic exp;
  final MasterProfileProvider provider;
  final VoidCallback onDelete;

  const _ExperienceCard(
      {required this.exp, required this.provider, required this.onDelete});

  static const _typeColors = {
    'internship': AppTheme.success,
    'project': AppTheme.accent,
    'volunteering': AppTheme.amber,
    'freelance': Color(0xFF00C9FF),
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[exp.type] ?? AppTheme.accent;
    final isTranslating = provider.translatingId == exp.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (exp.type as String)[0].toUpperCase() +
                      (exp.type as String).substring(1),
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.error, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(exp.title as String,
              style: Theme.of(context).textTheme.titleMedium),
          Text('${exp.organization} • ${exp.duration}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          // Show professional version if exists, otherwise raw
          Text(
            (exp.professionalDescription as String).isNotEmpty
                ? exp.professionalDescription as String
                : exp.rawDescription as String,
            style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // AI Translate button
          if ((exp.professionalDescription as String).isEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isTranslating
                    ? null
                    : () => provider.translateExperience(
                  experienceId: exp.id as String,
                  companyTone: 'corporate',
                ),
                icon: isTranslating
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.accent))
                    : const Icon(Icons.auto_awesome_rounded, size: 15),
                label: Text(isTranslating
                    ? 'Translating...'
                    : 'AI Professional Translate'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accent.withOpacity(0.4)),
                  foregroundColor: AppTheme.accentLight,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}