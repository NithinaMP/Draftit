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
    _tabCtrl = TabController(length: 5, vsync: this);
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
            _buildTabBar(context),
            Expanded(
              child: Consumer<MasterProfileProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _BasicInfoTab(provider: provider),
                      _SkillsTab(provider: provider),
                      _ExperienceTab(provider: provider),
                      _EducationTab(provider: provider),
                      _ExtrasTab(provider: provider),
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
            icon:  Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Master Profile',
                    style: Theme.of(context).textTheme.titleLarge),
                Text('Set up once, generate unlimited targeted resumes',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
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
              fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
            Tab(text: 'Education'),
            Tab(text: 'Extras'),
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
      _linkedInCtrl, _githubCtrl, _portfolioCtrl]) c.dispose();
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
          _dividerLabel('Online Presence (Optional)'),
          _field(_linkedInCtrl, 'LinkedIn URL', Icons.link_rounded),
          _field(_githubCtrl, 'GitHub URL', Icons.code_rounded),
          _field(_portfolioCtrl, 'Portfolio URL', Icons.web_rounded),
          const SizedBox(height: 20),
          if (_saved)
            _successBanner('Profile saved!'),
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
                linkedIn: _linkedInCtrl.text.trim().isEmpty ? null : _linkedInCtrl.text.trim(),
                github: _githubCtrl.text.trim().isEmpty ? null : _githubCtrl.text.trim(),
                portfolio: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
              );
              setState(() => _saved = true);
              Future.delayed(const Duration(seconds: 2),
                      () { if (mounted) setState(() => _saved = false); });
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
        style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
        ),
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
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
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
              final all = lectures.lectures
                  .expand((l) => l.extractedSkills)
                  .toSet()
                  .toList();
              if (all.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => widget.provider.syncLectureSkills(all),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.sync_rounded,
                        color: AppTheme.accentLight, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sync ${all.length} skills from your lecture notes',
                        style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.accentLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.add_rounded,
                        color: AppTheme.accentLight, size: 18),
                  ]),
                ),
              );
            },
          ),

          // Add skill input — supports comma-separated bulk add
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
                decoration: const InputDecoration(
                  labelText: 'Add skills',
                  hintText: 'Flutter, Firebase, Python...',
                  prefixIcon: Icon(Icons.add_circle_outline_rounded, size: 18),
                ),
                onSubmitted: _addSkills,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _addSkills(_ctrl.text),
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
          ]),
          const SizedBox(height: 8),
          Text('Tip: separate multiple skills with commas',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          if (skills.isEmpty)
            Text('No skills yet. Add manually or sync from lectures.',
                style: Theme.of(context).textTheme.bodyMedium)
          else
          // FIX: use Wrap properly — each chip has constrained width
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((s) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 48,
                ),
                child: _RemovableChip(
                  label: s,
                  onRemove: () => widget.provider.removeSkill(s),
                ),
              ))
                  .toList(),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _addSkills(String text) {
    final parts = text.split(',');
    for (final p in parts) {
      widget.provider.addSkill(p.trim());
    }
    _ctrl.clear();
  }
}

// ─── Experience Tab ───────────────────────────────────────────────────────────
class _ExperienceTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _ExperienceTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final exps = provider.profile.experiences;
    return Column(
      children: [
        Expanded(
          child: exps.isEmpty
              ? Center(
              child: Text(
                'No experiences yet.\nTap + to add.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: exps.length,
            itemBuilder: (_, i) => _ExperienceCard(
              exp: exps[i],
              provider: provider,
              onDelete: () => provider.removeExperience(exps[i].id),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Add Experience',
            icon: Icons.add_rounded,
            onPressed: () => _showAddSheet(context, provider),
          ),
        ),
      ],
    );
  }

  static void _showAddSheet(
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
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                const SizedBox(height: 12),
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
                          : AppTheme.textSecondaryOf(context),
                      fontSize: 12,
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                _tf(titleCtrl, 'Title (e.g. Flutter Developer)'),
                _tf(orgCtrl, 'Organization / Company'),
                _tf(durationCtrl, 'Duration (e.g. Jun 2024 – Aug 2024)'),
                _tf(descCtrl, 'What did you do?', maxLines: 4),
                _tf(toolsCtrl, 'Tools Used (Flutter, Firebase, Python...)'),
                _tf(proofCtrl, 'Proof Link — Optional'),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Add Experience',
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    provider.addExperience(provider.buildExperience(
                      title: titleCtrl.text.trim(),
                      organization: orgCtrl.text.trim(),
                      duration: durationCtrl.text.trim(),
                      rawDescription: descCtrl.text.trim(),
                      toolsUsed: toolsCtrl.text
                          .split(',').map((s) => s.trim())
                          .where((s) => s.isNotEmpty).toList(),
                      type: selectedType,
                      proofLink: proofCtrl.text.trim().isEmpty
                          ? null : proofCtrl.text.trim(),
                    ));
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

  static Widget _tf(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        style:  TextStyle(color: AppTheme.textPrimary),
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
              ? Center(child: Text('No education added.',
              style: Theme.of(context).textTheme.bodyMedium))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: edu.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderOf(context)),
              ),
              child: Row(children: [
                const Icon(Icons.school_outlined,
                    color: AppTheme.accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edu[i].degree,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${edu[i].institution} • ${edu[i].year}${edu[i].grade != null ? " • ${edu[i].grade}" : ""}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 18),
                  onPressed: () => provider.removeEducation(i),
                ),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Add Education',
            icon: Icons.add_rounded,
            onPressed: () => _showAddSheet(context, provider),
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, MasterProfileProvider provider) {
    final degreeCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Education',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(controller: degreeCtrl,
              style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(
                  labelText: 'Degree (e.g. B.Tech Computer Science)')),
          const SizedBox(height: 12),
          TextField(controller: instCtrl,
              style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(labelText: 'Institution')),
          const SizedBox(height: 12),
          TextField(controller: yearCtrl,
              style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration:
              const InputDecoration(labelText: 'Year (2021 – 2025)')),
          const SizedBox(height: 12),
          TextField(controller: gradeCtrl,
              style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(
                  labelText: 'Grade / GPA (Optional)')),
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
                    ? null : gradeCtrl.text.trim(),
              ));
              Navigator.pop(ctx);
            },
          ),
        ]),
      ),
    );
  }
}

// ─── Extras Tab — certifications, languages, soft skills ──────────────────────
class _ExtrasTab extends StatefulWidget {
  final MasterProfileProvider provider;
  const _ExtrasTab({required this.provider});

  @override
  State<_ExtrasTab> createState() => _ExtrasTabState();
}

class _ExtrasTabState extends State<_ExtrasTab> {
  final _certCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final _softCtrl = TextEditingController();

  @override
  void dispose() {
    _certCtrl.dispose();
    _langCtrl.dispose();
    _softCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Certifications ──
          _sectionLabel('Certifications', Icons.verified_outlined, AppTheme.success),
          const SizedBox(height: 10),
          _addRow(_certCtrl, 'e.g. AWS Certified, Google Analytics',
                  () async {
                if (_certCtrl.text.trim().isNotEmpty) {
                  await widget.provider.addCertification(_certCtrl.text.trim());
                  _certCtrl.clear();
                }
              }),
          const SizedBox(height: 10),
          if (p.certifications.isEmpty)
            _emptyHint('No certifications added')
          else
            _chipWrap(p.certifications, AppTheme.success,
                    (c) => widget.provider.removeCertification(
                    p.certifications.indexOf(c))),

          const SizedBox(height: 24),
           Divider(color: AppTheme.borderOf(context)),
          const SizedBox(height: 16),

          // ── Languages ──
          _sectionLabel('Languages Known', Icons.translate_rounded, AppTheme.amber),
          const SizedBox(height: 10),
          _addRow(_langCtrl, 'e.g. English, Malayalam, Hindi',
                  () async {
                final parts = _langCtrl.text.split(',');
                for (final p in parts) {
                  await widget.provider.addLanguage(p.trim());
                }
                _langCtrl.clear();
              }),
          const SizedBox(height: 10),
          if (p.languages.isEmpty)
            _emptyHint('No languages added')
          else
            _chipWrap(p.languages, AppTheme.amber,
                    (l) => widget.provider.removeLanguage(l)),

          const SizedBox(height: 24),
           Divider(color: AppTheme.borderOf(context)),
          const SizedBox(height: 16),

          // ── Soft Skills ──
          _sectionLabel('Soft Skills', Icons.psychology_outlined, AppTheme.accentLight),
          const SizedBox(height: 6),
          Text(
            'These appear in the PDF right column and show recruiters your personality.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _addRow(_softCtrl, 'e.g. Leadership, Communication, Problem Solving',
                  () async {
                final parts = _softCtrl.text.split(',');
                for (final s in parts) {
                  await widget.provider.addSoftSkill(s.trim());
                }
                _softCtrl.clear();
              }),
          const SizedBox(height: 10),
          if (p.softSkills.isEmpty)
            _emptyHint('No soft skills added')
          else
            _chipWrap(p.softSkills, AppTheme.accentLight,
                    (s) => widget.provider.removeSoftSkill(s)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(label,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context))),
    ]);
  }

  Widget _addRow(
      TextEditingController ctrl, String hint, VoidCallback onAdd) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: ctrl,
          style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                color: AppTheme.textSecondaryOf(context), fontSize: 13),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:  BorderSide(color: AppTheme.borderOf(context))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:  BorderSide(color: AppTheme.borderOf(context))),
          ),
          onSubmitted: (_) => onAdd(),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D40FF)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]);
  }

  Widget _emptyHint(String msg) {
    return Text(msg,
        style: GoogleFonts.dmSans(
            color: AppTheme.textSecondaryOf(context), fontSize: 13));
  }

  Widget _chipWrap(
      List<String> items, Color color, Function(String) onRemove) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => onRemove(item),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppTheme.textSecondary),
            ),
          ]),
        );
      }).toList(),
    );
  }
}

// ─── Divider helpers ──────────────────────────────────────────────────────────
Widget _dividerLabel(String label) {
  return Builder(builder: (ctx) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
       Expanded(child: Divider(color: AppTheme.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label,
            style: Theme.of(ctx).textTheme.labelMedium),
      ),
      const Expanded(child: Divider(color: AppTheme.border)),
    ]),
  ));
}

Widget _successBanner(String msg) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.success.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.check_circle_rounded,
          color: AppTheme.success, size: 16),
      const SizedBox(width: 6),
      Text(msg,
          style: GoogleFonts.spaceGrotesk(
              color: AppTheme.success, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ─── Experience Card ──────────────────────────────────────────────────────────
class _ExperienceCard extends StatelessWidget {
  final ExperienceEntry exp;
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
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              exp.type[0].toUpperCase() + exp.type.substring(1),
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppTheme.error, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
          ),
        ]),
        const SizedBox(height: 6),
        Text(exp.title, style: Theme.of(context).textTheme.titleMedium),
        Text('${exp.organization} • ${exp.duration}',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          exp.professionalDescription.isNotEmpty
              ? exp.professionalDescription
              : exp.rawDescription,
          style: GoogleFonts.dmSans(
              fontSize: 13, color: AppTheme.textSecondaryOf(context), height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        if (exp.professionalDescription.isEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isTranslating
                  ? null
                  : () => provider.translateExperience(
                experienceId: exp.id,
                companyTone: 'corporate',
              ),
              icon: isTranslating
                  ? const SizedBox(
                  width: 14, height: 14,
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
      ]),
    );
  }
}

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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: AppTheme.accentLight),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child:  Icon(Icons.close_rounded,
              size: 14, color: AppTheme.textSecondaryOf(context)),
        ),
      ]),
    );
  }
}