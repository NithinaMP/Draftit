import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../models/master_profile_model.dart';
import '../models/job_application_model.dart';

class ResumePdfService {
  static const _accent  = PdfColor.fromInt(0xFF6C63FF);
  static const _dark    = PdfColor.fromInt(0xFF1A1A2E);
  static const _text    = PdfColor.fromInt(0xFF2D2D3A);
  static const _muted   = PdfColor.fromInt(0xFF6B6B80);
  static const _sideCol = PdfColor.fromInt(0xFFF0EFFF);
  static const _divCol  = PdfColor.fromInt(0xFFE0E0F0);
  static const _white   = PdfColors.white;
  static const _chipBg  = PdfColor.fromInt(0xFFEDECFF);
  static const _chipFg  = PdfColor.fromInt(0xFF4A4580);

  Future<Uint8List> generatePdf({
    required MasterProfile profile,
    required JobApplication job,
  }) async {
    final doc = pw.Document();
    final fonts = await _loadFonts();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => [
          _header(profile, fonts),
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(32, 20, 32, 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _summary(profile, job, fonts),
                pw.SizedBox(height: 16),
                _body(profile, job, fonts),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  pw.Widget _header(MasterProfile p, _Fonts f) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(32, 30, 32, 22),
      decoration: const pw.BoxDecoration(color: _dark),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            p.fullName.isNotEmpty ? p.fullName : 'Your Name',
            style: pw.TextStyle(font: f.bold, fontSize: 26, color: _white, letterSpacing: 0.5),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(spacing: 14, runSpacing: 3, children: [
            if (p.email.isNotEmpty)            _contactText(p.email, f),
            if (p.phone.isNotEmpty)            _contactText(p.phone, f),
            if (p.location.isNotEmpty)         _contactText(p.location, f),
            if ((p.linkedIn ?? '').isNotEmpty) _contactText(_url(p.linkedIn!), f),
            if ((p.github ?? '').isNotEmpty)   _contactText(_url(p.github!), f),
          ]),
        ],
      ),
    );
  }

  pw.Widget _contactText(String t, _Fonts f) => pw.Text(t,
      style: pw.TextStyle(font: f.regular, fontSize: 8.5,
          color: const PdfColor.fromInt(0xFFCCCCEE)));

  // ── FIX 1: Summary — write it directly from profile data, NOT from AI JSON ──
  pw.Widget _summary(MasterProfile p, JobApplication job, _Fonts f) {
    // Build a clean professional summary from actual profile fields
    // instead of parsing the messy AI-generated resume text
    final namePart = p.fullName.isNotEmpty ? p.fullName : 'A motivated professional';
    final skillsTop = p.skills.take(5).join(', ');
    final expCount = p.experiences.length;
    final targetRole = job.roleTitle;
    final company = job.companyName;

    String summaryText;
    if (expCount > 0) {
      final latestExp = p.experiences.first;
      summaryText =
      '$namePart is a results-driven professional with hands-on experience as ${latestExp.title} '
          'at ${latestExp.organization}. Proficient in $skillsTop, with a strong foundation in '
          'delivering impactful solutions. Seeking to contribute as $targetRole at $company '
          'by leveraging technical expertise and collaborative mindset.';
    } else {
      summaryText =
      '$namePart is an enthusiastic and detail-oriented professional skilled in $skillsTop. '
          'Driven by a passion for continuous learning and practical problem-solving. '
          'Eager to contribute as $targetRole at $company through dedication and technical acumen.';
    }

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('PROFESSIONAL SUMMARY', f),
      pw.SizedBox(height: 7),
      pw.Text(summaryText,
          style: pw.TextStyle(font: f.regular, fontSize: 9.5, color: _text, lineSpacing: 2.2)),
      pw.SizedBox(height: 4),
      _hr(),
    ]);
  }

  // ── Two-column body ────────────────────────────────────────────────────────
  pw.Widget _body(MasterProfile p, JobApplication job, _Fonts f) {
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      // Left — 62%
      pw.Expanded(flex: 62, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _experienceSection(p, f),
          if (p.experiences.any((e) => e.type == 'project')) ...[],
          pw.SizedBox(height: 14),
          _projectsSection(p, f),
          pw.SizedBox(height: 14),
          _educationSection(p, f),
        ],
      )),
      pw.SizedBox(width: 18),
      // Right — 38%
      pw.Expanded(flex: 38, child: pw.Container(
        padding: const pw.EdgeInsets.all(13),
        decoration: pw.BoxDecoration(
          color: _sideCol,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          _skillsSection(p, f),
          if (p.certifications.isNotEmpty) ...[pw.SizedBox(height: 12), _certSection(p, f)],
          if (p.languages.isNotEmpty)      ...[pw.SizedBox(height: 12), _langSection(p, f)],
          if (p.softSkills.isNotEmpty)     ...[pw.SizedBox(height: 12), _softSection(p, f)],
        ]),
      )),
    ]);
  }

  // ── Experience (internships/jobs only — not projects) ──────────────────────
  pw.Widget _experienceSection(MasterProfile p, _Fonts f) {
    final exps = p.experiences
        .where((e) => e.type != 'project')
        .toList();
    if (exps.isEmpty) return pw.SizedBox();

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('EXPERIENCE', f),
      pw.SizedBox(height: 8),
      ...exps.map((exp) => _expCard(exp, f)),
      _hr(),
    ]);
  }

  // ── FIX 3: Projects section (academic/freelance projects) ──────────────────
  pw.Widget _projectsSection(MasterProfile p, _Fonts f) {
    final projects = p.experiences
        .where((e) => e.type == 'project' || e.type == 'freelance')
        .toList();
    if (projects.isEmpty) return pw.SizedBox();

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('ACADEMIC PROJECTS', f),
      pw.SizedBox(height: 8),
      ...projects.map((proj) => _expCard(proj, f)),
      _hr(),
    ]);
  }

  // ── FIX 4: Experience/Project card — deduplicate tools ────────────────────
  pw.Widget _expCard(ExperienceEntry exp, _Fonts f) {
    final desc = exp.professionalDescription.isNotEmpty
        ? exp.professionalDescription
        : exp.rawDescription;

    // Clean bullets: strip markdown, remove empty lines
    final bullets = desc
        .split('\n')
        .map((l) => l
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll('**', '').replaceAll('*', '')
        .replaceAll('•', '').trim())
        .where((l) => l.isNotEmpty && l.length > 3)
        .toList();

    // FIX: Deduplicate tools — use Set to remove duplicates, then sort
    final tools = exp.toolsUsed.toSet().toList()..sort();

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(child: pw.Text(exp.title,
            style: pw.TextStyle(font: f.semiBold, fontSize: 10, color: _dark))),
        pw.Text(exp.duration,
            style: pw.TextStyle(font: f.italic, fontSize: 8, color: _muted)),
      ]),
      pw.Text(exp.organization,
          style: pw.TextStyle(font: f.regular, fontSize: 9, color: _accent)),
      pw.SizedBox(height: 4),
      ...bullets.map((b) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('• ', style: pw.TextStyle(font: f.bold, fontSize: 9, color: _accent)),
          pw.Expanded(child: pw.Text(b,
              style: pw.TextStyle(font: f.regular, fontSize: 9, color: _text, lineSpacing: 1.4))),
        ]),
      )),
      if (tools.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text('Technologies: ${tools.join(', ')}',
              style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted)),
        ),
      pw.SizedBox(height: 10),
    ]);
  }

  // ── Education ──────────────────────────────────────────────────────────────
  pw.Widget _educationSection(MasterProfile p, _Fonts f) {
    if (p.education.isEmpty) return pw.SizedBox();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('EDUCATION', f),
      pw.SizedBox(height: 8),
      ...p.education.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(child: pw.Text(e.degree,
                style: pw.TextStyle(font: f.semiBold, fontSize: 10, color: _dark))),
            pw.Text(e.year,
                style: pw.TextStyle(font: f.italic, fontSize: 8, color: _muted)),
          ]),
          pw.Text(e.institution,
              style: pw.TextStyle(font: f.regular, fontSize: 9, color: _accent)),
          if ((e.grade ?? '').isNotEmpty)
            pw.Text('Grade: ${e.grade}',
                style: pw.TextStyle(font: f.italic, fontSize: 8, color: _muted)),
        ]),
      )),
    ]);
  }

  // ── FIX 2: Skills — ALL same uniform color (no blue/grey split) ────────────
  pw.Widget _skillsSection(MasterProfile p, _Fonts f) {
    if (p.skills.isEmpty) return pw.SizedBox();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('TECHNICAL SKILLS', f),
      pw.SizedBox(height: 6),
      pw.Wrap(spacing: 4, runSpacing: 5,
        // ALL chips same color — uniform professional look
        children: p.skills.take(20).map((s) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(
            color: _accent,  // ALL purple — clean and professional
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Text(s,
              style: pw.TextStyle(font: f.semiBold, fontSize: 7.5, color: _white)),
        )).toList(),
      ),
    ]);
  }

  // ── Certifications ─────────────────────────────────────────────────────────
  pw.Widget _certSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('CERTIFICATIONS', f),
      pw.SizedBox(height: 5),
      ...p.certifications.map((c) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: 4, height: 4,
              margin: const pw.EdgeInsets.only(top: 3, right: 5),
              decoration: pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle)),
          pw.Expanded(child: pw.Text(c,
              style: pw.TextStyle(font: f.regular, fontSize: 8, color: _text))),
        ]),
      )),
    ]);
  }

  // ── Languages ──────────────────────────────────────────────────────────────
  pw.Widget _langSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('LANGUAGES', f),
      pw.SizedBox(height: 5),
      pw.Wrap(spacing: 4, runSpacing: 4,
        children: p.languages.map((l) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(color: _chipBg, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Text(l,
              style: pw.TextStyle(font: f.regular, fontSize: 8, color: _chipFg)),
        )).toList(),
      ),
    ]);
  }

  // ── Soft Skills ────────────────────────────────────────────────────────────
  pw.Widget _softSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('SOFT SKILLS', f),
      pw.SizedBox(height: 5),
      ...p.softSkills.map((s) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: 4, height: 4,
              margin: const pw.EdgeInsets.only(top: 3, right: 6),
              decoration: pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle)),
          pw.Expanded(child: pw.Text(s,
              style: pw.TextStyle(font: f.regular, fontSize: 8.5, color: _text))),
        ]),
      )),
    ]);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  pw.Widget _secTitle(String t, _Fonts f) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(t, style: pw.TextStyle(
          font: f.bold, fontSize: 9, color: _accent, letterSpacing: 1.5)),
      pw.SizedBox(height: 3),
      pw.Container(height: 1.5, color: _accent),
    ],
  );

  pw.Widget _sideTitle(String t, _Fonts f) => pw.Text(t,
      style: pw.TextStyle(font: f.bold, fontSize: 8, color: _dark, letterSpacing: 1.2));

  pw.Widget _hr() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    child: pw.Container(height: 0.5, color: _divCol),
  );

  String _url(String u) => u
      .replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '');

  Future<_Fonts> _loadFonts() async => _Fonts(
    regular:  await PdfGoogleFonts.nunitoRegular(),
    bold:     await PdfGoogleFonts.nunitoBold(),
    semiBold: await PdfGoogleFonts.nunitoSemiBold(),
    italic:   await PdfGoogleFonts.nunitoItalic(),
  );
}

class _Fonts {
  final pw.Font regular, bold, semiBold, italic;
  _Fonts({required this.regular, required this.bold,
    required this.semiBold, required this.italic});
}