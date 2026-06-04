import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../1_voice_to_notes/providers/lectures_provider.dart';
import '../../data/models/master_profile_model.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/master_profile_provider.dart';
// import '../../1_voice_to_notes/providers/lectures_provider.dart';
// import '../data/models/master_profile_model/.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class MasterProfileScreen extends StatefulWidget {
  const MasterProfileScreen({super.key});
  @override State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.bgOf(context);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Consumer<MasterProfileProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent));
                return TabBarView(controller: _tabCtrl, children: [
                  _BasicInfoTab(provider: provider),
                  _SkillsTab(provider: provider),
                  _ExperienceTab(provider: provider),
                  _ProjectsTab(provider: provider),
                  _EducationTab(provider: provider),
                  _ExtrasTab(provider: provider),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimaryOf(context)),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Master Profile', style: Theme.of(context).textTheme.titleLarge),
          Text('Set up once — generate unlimited targeted resumes',
              style: Theme.of(context).textTheme.bodyMedium),
        ])),
      ]),
    );
  }

  Widget _buildTabBar() {
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
            gradient: const LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.bg,
          unselectedLabelColor: AppTheme.textSecondaryOf(context),
          labelStyle: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Info'), Tab(text: 'Skills'), Tab(text: 'Experience'),
            Tab(text: 'Projects'), Tab(text: 'Education'), Tab(text: 'Extras'),
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
  @override State<_BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<_BasicInfoTab> {
  late final TextEditingController _name, _email, _phone, _loc, _li, _gh, _port;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.provider.profile;
    _name = TextEditingController(text: p.fullName);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _loc = TextEditingController(text: p.location);
    _li = TextEditingController(text: p.linkedIn ?? '');
    _gh = TextEditingController(text: p.github ?? '');
    _port = TextEditingController(text: p.portfolio ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name,_email,_phone,_loc,_li,_gh,_port]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _f(_name, 'Full Name', Icons.person_outline_rounded),
        _f(_email, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
        _f(_phone, 'Phone', Icons.phone_outlined, type: TextInputType.phone),
        _f(_loc, 'Location (City, Country)', Icons.location_on_outlined),
        _divLabel('Online Presence (Optional)'),
        _f(_li, 'LinkedIn URL', Icons.link_rounded),
        _f(_gh, 'GitHub URL', Icons.code_rounded),
        _f(_port, 'Portfolio URL', Icons.web_rounded),
        const SizedBox(height: 20),
        if (_saved) _successBanner(),
        const SizedBox(height: 12),
        GradientButton(
          label: 'Save Info', icon: Icons.save_outlined,
          onPressed: () async {
            await widget.provider.saveBasicInfo(
              fullName: _name.text.trim(), email: _email.text.trim(),
              phone: _phone.text.trim(), location: _loc.text.trim(),
              linkedIn: _li.text.trim().isEmpty ? null : _li.text.trim(),
              github: _gh.text.trim().isEmpty ? null : _gh.text.trim(),
              portfolio: _port.text.trim().isEmpty ? null : _port.text.trim(),
            );
            setState(() => _saved = true);
            Future.delayed(const Duration(seconds: 2),
                    () { if (mounted) setState(() => _saved = false); });
          },
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _f(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(controller: c, keyboardType: type,
            style: TextStyle(color: AppTheme.textPrimaryOf(context)),
            decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18))),
      );

  Widget _divLabel(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      const Expanded(child: Divider()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
      const Expanded(child: Divider()),
    ]),
  );

  Widget _successBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
      const SizedBox(width: 6),
      Text('Saved!', style: GoogleFonts.spaceGrotesk(color: AppTheme.success, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ─── Skills Tab ───────────────────────────────────────────────────────────────
class _SkillsTab extends StatefulWidget {
  final MasterProfileProvider provider;
  const _SkillsTab({required this.provider});
  @override State<_SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<_SkillsTab> {
  final _ctrl = TextEditingController();

  void _add(String text) {
    for (final p in text.split(',')) widget.provider.addSkill(p.trim());
    _ctrl.clear();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final skills = widget.provider.profile.skills;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sync from lectures
        Consumer<LecturesProvider>(builder: (_, lec, __) {
          final all = lec.lectures.expand((l) => l.extractedSkills).toSet().toList();
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
                const Icon(Icons.sync_rounded, color: AppTheme.accentLight, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Sync ${all.length} skills from lecture notes',
                    style: GoogleFonts.spaceGrotesk(color: AppTheme.accentLight, fontSize: 13))),
                const Icon(Icons.add_rounded, color: AppTheme.accentLight, size: 18),
              ]),
            ),
          );
        }),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(
                  labelText: 'Add skills (comma separated)',
                  hintText: 'Flutter, Firebase, Python...'),
              onSubmitted: _add,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _add(_ctrl.text),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.accent, Color(0xFF9D40FF)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          Text('No skills yet.', style: Theme.of(context).textTheme.bodyMedium)
        else
          Wrap(spacing: 8, runSpacing: 8,
            children: skills.map((s) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 48),
              child: _RemovableChip(label: s, color: AppTheme.accent,
                  onRemove: () => widget.provider.removeSkill(s)),
            )).toList(),
          ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

// ─── Experience Tab ───────────────────────────────────────────────────────────
class _ExperienceTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _ExperienceTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final exps = provider.profile.experiences;
    return Column(children: [
      Expanded(
        child: exps.isEmpty
            ? Center(child: Text('No experience added. Tap + to add.',
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium))
            : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: exps.length,
            itemBuilder: (_, i) => _ExpCard(
                exp: exps[i], provider: provider,
                onDelete: () => provider.removeExperience(exps[i].id))),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GradientButton(label: 'Add Experience', icon: Icons.add_rounded,
            onPressed: () => _showSheet(context, provider)),
      ),
    ]);
  }

  static void _showSheet(BuildContext context, MasterProfileProvider provider) {
    final titleC = TextEditingController();
    final orgC = TextEditingController();
    final durC = TextEditingController();
    final descC = TextEditingController();
    final toolsC = TextEditingController();
    String type = 'internship';
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Experience', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: ['internship','volunteering','freelance']
                  .map((t) => ChoiceChip(label: Text(t[0].toUpperCase()+t.substring(1)),
                  selected: type == t, onSelected: (_) => setM(() => type = t),
                  selectedColor: AppTheme.accent.withOpacity(0.2),
                  labelStyle: GoogleFonts.spaceGrotesk(
                      color: type == t ? AppTheme.accentLight : AppTheme.textSecondary, fontSize: 12)))
                  .toList()),
              const SizedBox(height: 12),
              _tf(context, titleC, 'Job Title (e.g. Flutter Intern)'),
              _tf(context, orgC, 'Company / Organization'),
              _tf(context, durC, 'Duration (e.g. Jun 2024 – Aug 2024)'),
              _tf(context, descC, 'What did you do?', maxLines: 4),
              _tf(context, toolsC, 'Tools Used (comma separated)'),
              const SizedBox(height: 16),
              GradientButton(label: 'Add', onPressed: () {
                if (titleC.text.trim().isEmpty) return;
                provider.addExperience(provider.buildExperience(
                  title: titleC.text.trim(), organization: orgC.text.trim(),
                  duration: durC.text.trim(), rawDescription: descC.text.trim(),
                  toolsUsed: toolsC.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  type: type,
                ));
                Navigator.pop(ctx);
              }),
            ])),
      )),
    );
  }

  static Widget _tf(BuildContext ctx, TextEditingController c, String label, {int maxLines = 1}) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextField(controller: c, maxLines: maxLines,
              style: TextStyle(color: AppTheme.textPrimaryOf(ctx)),
              decoration: InputDecoration(labelText: label)));
}

// ─── NEW: Projects Tab ────────────────────────────────────────────────────────
class _ProjectsTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _ProjectsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final projects = provider.profile.projects;
    return Column(children: [
      Expanded(
        child: projects.isEmpty
            ? Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.code_rounded, color: AppTheme.accent, size: 36)),
              const SizedBox(height: 16),
              Text('No projects yet', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Add your academic projects, personal builds, and open-source contributions.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ])))
            : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: projects.length,
            itemBuilder: (_, i) => _ProjectCard(
                project: projects[i],
                onDelete: () => provider.removeProject(projects[i].id))),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GradientButton(label: 'Add Project', icon: Icons.add_rounded,
            onPressed: () => _showSheet(context, provider)),
      ),
    ]);
  }

  static void _showSheet(BuildContext context, MasterProfileProvider provider) {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final techC = TextEditingController();
    final durC = TextEditingController();
    final ghC = TextEditingController();
    final liveC = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Academic Project', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _tf(context, titleC, 'Project Title'),
              _tf(context, descC, 'What did you build and what problem does it solve?', maxLines: 4),
              _tf(context, techC, 'Tech Stack (Flutter, Firebase, Python...)'),
              _tf(context, durC, 'Duration (e.g. Jan 2024 – Mar 2024)'),
              _tf(context, ghC, 'GitHub Link (Optional)'),
              _tf(context, liveC, 'Live Demo Link (Optional)'),
              const SizedBox(height: 16),
              GradientButton(label: 'Add Project', onPressed: () {
                if (titleC.text.trim().isEmpty) return;
                provider.addProject(provider.buildProject(
                  title: titleC.text.trim(),
                  description: descC.text.trim(),
                  techStack: techC.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  duration: durC.text.trim(),
                  githubLink: ghC.text.trim().isEmpty ? null : ghC.text.trim(),
                  liveLink: liveC.text.trim().isEmpty ? null : liveC.text.trim(),
                ));
                Navigator.pop(ctx);
              }),
            ])),
      ),
    );
  }

  static Widget _tf(BuildContext ctx, TextEditingController c, String label, {int maxLines = 1}) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextField(controller: c, maxLines: maxLines,
              style: TextStyle(color: AppTheme.textPrimaryOf(ctx)),
              decoration: InputDecoration(labelText: label)));
}

// ─── Education Tab ────────────────────────────────────────────────────────────
class _EducationTab extends StatelessWidget {
  final MasterProfileProvider provider;
  const _EducationTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final edu = provider.profile.education;
    return Column(children: [
      Expanded(child: edu.isEmpty
          ? Center(child: Text('No education added.', style: Theme.of(context).textTheme.bodyMedium))
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
              const Icon(Icons.school_outlined, color: AppTheme.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(edu[i].degree, style: Theme.of(context).textTheme.titleMedium),
                Text('${edu[i].institution} • ${edu[i].year}${edu[i].grade != null ? " • ${edu[i].grade}" : ""}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ])),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                  onPressed: () => provider.removeEducation(i)),
            ]),
          ))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: GradientButton(label: 'Add Education', icon: Icons.add_rounded,
            onPressed: () => _showSheet(context, provider)),
      ),
    ]);
  }

  void _showSheet(BuildContext context, MasterProfileProvider provider) {
    final degC = TextEditingController();
    final instC = TextEditingController();
    final yearC = TextEditingController();
    final gradeC = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Education', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          _tf(context, degC, 'Degree (e.g. B.Tech Computer Science)'),
          _tf(context, instC, 'Institution'),
          _tf(context, yearC, 'Year (e.g. 2021 – 2025)'),
          _tf(context, gradeC, 'Grade / GPA (Optional)'),
          const SizedBox(height: 16),
          GradientButton(label: 'Add', onPressed: () {
            if (degC.text.trim().isEmpty) return;
            provider.addEducation(EducationEntry(
              degree: degC.text.trim(), institution: instC.text.trim(),
              year: yearC.text.trim(),
              grade: gradeC.text.trim().isEmpty ? null : gradeC.text.trim(),
            ));
            Navigator.pop(ctx);
          }),
        ]),
      ),
    );
  }

  static Widget _tf(BuildContext ctx, TextEditingController c, String label) =>
      Padding(padding: const EdgeInsets.only(bottom: 12),
          child: TextField(controller: c,
              style: TextStyle(color: AppTheme.textPrimaryOf(ctx)),
              decoration: InputDecoration(labelText: label)));
}

// ─── Extras Tab ───────────────────────────────────────────────────────────────
class _ExtrasTab extends StatefulWidget {
  final MasterProfileProvider provider;
  const _ExtrasTab({required this.provider});
  @override State<_ExtrasTab> createState() => _ExtrasTabState();
}

class _ExtrasTabState extends State<_ExtrasTab> {
  final _certC = TextEditingController();
  final _langC = TextEditingController();
  final _softC = TextEditingController();

  @override
  void dispose() { _certC.dispose(); _langC.dispose(); _softC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead('Certifications', Icons.verified_outlined, AppTheme.success),
        const SizedBox(height: 10),
        // Certification cards
        if (p.certifications.isEmpty)
          Text('No certifications added.', style: Theme.of(context).textTheme.bodyMedium)
        else
          ...p.certifications.map((cert) => _CertCard(
            cert: cert,
            onDelete: () => widget.provider.removeCertification(cert.id),
          )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showCertSheet(context, widget.provider),
          icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.success),
          label: Text('Add Certification',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.success, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.success),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        _sectionHead('Languages Known', Icons.translate_rounded, AppTheme.amber),
        const SizedBox(height: 10),
        _addRow(_langC, 'e.g. English, Malayalam, Hindi', () async {
          for (final p in _langC.text.split(',')) widget.provider.addLanguage(p.trim());
          _langC.clear();
        }),
        const SizedBox(height: 10),
        _chipWrap(context, p.languages, AppTheme.amber,
                (l) => widget.provider.removeLanguage(l)),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        _sectionHead('Soft Skills', Icons.psychology_outlined, AppTheme.accentLight),
        const SizedBox(height: 10),
        _addRow(_softC, 'e.g. Leadership, Communication', () async {
          for (final s in _softC.text.split(',')) widget.provider.addSoftSkill(s.trim());
          _softC.clear();
        }),
        const SizedBox(height: 10),
        _chipWrap(context, p.softSkills, AppTheme.accentLight,
                (s) => widget.provider.removeSoftSkill(s)),

        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _sectionHead(String label, IconData icon, Color color) =>
      Row(children: [
        Icon(icon, color: color, size: 20), const SizedBox(width: 8),
        Text(label, style: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryOf(context))),
      ]);

  Widget _addRow(TextEditingController ctrl, String hint, VoidCallback onAdd) =>
      Row(children: [
        Expanded(child: TextField(
          controller: ctrl,
          style: TextStyle(color: AppTheme.textPrimaryOf(context)),
          decoration: InputDecoration(hintText: hint,
              hintStyle: GoogleFonts.dmSans(color: AppTheme.textSecondaryOf(context), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.borderOf(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.borderOf(context)))),
          onSubmitted: (_) => onAdd(),
        )),
        const SizedBox(width: 10),
        GestureDetector(onTap: onAdd,
            child: Container(padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.accent, Color(0xFF9D40FF)]),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20))),
      ]);

  Widget _chipWrap(BuildContext context, List<String> items, Color color, Function(String) onRemove) {
    if (items.isEmpty) return Text('None added', style: Theme.of(context).textTheme.bodyMedium);
    return Wrap(spacing: 8, runSpacing: 8,
      children: items.map((item) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 48),
        child: _RemovableChip(label: item, color: color, onRemove: () => onRemove(item)),
      )).toList(),
    );
  }
}

// ─── Shared: Experience Card ──────────────────────────────────────────────────
class _ExpCard extends StatelessWidget {
  final ExperienceEntry exp;
  final MasterProfileProvider provider;
  final VoidCallback onDelete;
  const _ExpCard({required this.exp, required this.provider, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const typeColors = {
      'internship': AppTheme.success, 'volunteering': AppTheme.amber,
      'freelance': Color(0xFF00C9FF),
    };
    final color = typeColors[exp.type] ?? AppTheme.accent;
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
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(exp.type[0].toUpperCase()+exp.type.substring(1),
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
          const Spacer(),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
              onPressed: onDelete, padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 6),
        Text(exp.title, style: Theme.of(context).textTheme.titleMedium),
        Text('${exp.organization} • ${exp.duration}', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(exp.professionalDescription.isNotEmpty ? exp.professionalDescription : exp.rawDescription,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondaryOf(context), height: 1.5),
            maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        if (exp.professionalDescription.isEmpty)
          SizedBox(width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isTranslating ? null : () => provider.translateExperience(
                    experienceId: exp.id, companyTone: 'corporate'),
                icon: isTranslating
                    ? const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                    : const Icon(Icons.auto_awesome_rounded, size: 15),
                label: Text(isTranslating ? 'Translating...' : 'AI Professional Translate'),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.accent.withOpacity(0.4)),
                    foregroundColor: AppTheme.accentLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
      ]),
    );
  }
}

// ─── Shared: Project Card ─────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final ProjectEntry project;
  final VoidCallback onDelete;
  const _ProjectCard({required this.project, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.code_rounded, color: AppTheme.accent, size: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(project.title, style: Theme.of(context).textTheme.titleMedium)),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
              onPressed: onDelete, padding: EdgeInsets.zero),
        ]),
        if (project.duration.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(project.duration, style: GoogleFonts.spaceGrotesk(
              fontSize: 11, color: AppTheme.textSecondaryOf(context))),
        ],
        const SizedBox(height: 8),
        Text(project.description,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondaryOf(context), height: 1.5),
            maxLines: 3, overflow: TextOverflow.ellipsis),
        if (project.techStack.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 4,
              children: project.techStack.map((t) => SkillChip(label: t, highlighted: true)).toList()),
        ],
        if ((project.githubLink ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.link_rounded, color: AppTheme.accentLight, size: 14),
            const SizedBox(width: 4),
            Text(project.githubLink!, style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.accentLight)),
          ]),
        ],
      ]),
    );
  }
}


// ─── Cert Sheet helper (top-level function used by _ExtrasTabState) ───────────
void _showCertSheet(BuildContext context, MasterProfileProvider provider) {
  final nameC = TextEditingController();
  final orgC = TextEditingController();
  final issueC = TextEditingController();
  final expC = TextEditingController();
  final idC = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceOf(context),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Certification',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _certTf(context, nameC, 'Certification Name *', 'e.g. Basic Life Support (BLS)'),
              _certTf(context, orgC, 'Issuing Organization *', 'e.g. American Heart Association'),
              _certTf(context, issueC, 'Issue Date *', 'e.g. Jan 2025'),
              _certTf(context, expC, 'Expiry Date', 'e.g. Jan 2027 (leave blank if no expiry)'),
              _certTf(context, idC, 'Credential ID', 'e.g. AHA-BLS-99214'),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Add Certification',
                icon: Icons.verified_outlined,
                onPressed: () {
                  if (nameC.text.trim().isEmpty || orgC.text.trim().isEmpty) return;
                  provider.addCertification(provider.buildCertification(
                    name: nameC.text.trim(),
                    organization: orgC.text.trim(),
                    issueDate: issueC.text.trim(),
                    expiryDate: expC.text.trim().isEmpty ? null : expC.text.trim(),
                    credentialId: idC.text.trim().isEmpty ? null : idC.text.trim(),
                  ));
                  Navigator.pop(ctx);
                },
              ),
            ]),
      ),
    ),
  );
}

Widget _certTf(BuildContext ctx, TextEditingController c, String label, String hint) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: TextStyle(color: AppTheme.textPrimaryOf(ctx)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: AppTheme.textSecondaryOf(ctx), fontSize: 12),
        ),
      ),
    );

// ─── Certification Card ───────────────────────────────────────────────────────
class _CertCard extends StatelessWidget {
  final CertificationEntry cert;
  final VoidCallback onDelete;
  const _CertCard({required this.cert, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_outlined, color: AppTheme.success, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(cert.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
          ),
        ]),
        const SizedBox(height: 8),
        _row(context, Icons.business_outlined, cert.organization),
        _row(context, Icons.calendar_today_outlined,
            cert.expiryDate != null && cert.expiryDate!.isNotEmpty
                ? '${cert.issueDate}  →  Expires: ${cert.expiryDate}'
                : cert.issueDate),
        if ((cert.credentialId ?? '').isNotEmpty)
          _row(context, Icons.badge_outlined, 'ID: ${cert.credentialId}'),
      ]),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: AppTheme.textSecondaryOf(context)),
        const SizedBox(width: 6),
        Expanded(child: Text(text,
            style: GoogleFonts.dmSans(fontSize: 12,
                color: AppTheme.textSecondaryOf(context)))),
      ]),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────
class _RemovableChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  const _RemovableChip({required this.label, required this.color, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: color))),
        const SizedBox(width: 4),
        GestureDetector(onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: color.withOpacity(0.7))),
      ]),
    );
  }
}