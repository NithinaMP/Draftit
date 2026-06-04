import 'dart:math';
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

  // ── PUBLIC: Visual resume (designed, two-column) ───────────────────────────
  Future<Uint8List> generatePdf({
    required MasterProfile profile,
    required JobApplication job,
  }) async {
    final doc = pw.Document();
    final fonts = await _loadFonts();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        _header(profile, fonts),
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(32, 20, 32, 32),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _summary(profile, job, fonts),
            pw.SizedBox(height: 14),
            _body(profile, job, fonts),
          ]),
        ),
      ],
    ));
    return doc.save();
  }

  // ── PUBLIC: ATS plain-text resume ─────────────────────────────────────────
  Future<Uint8List> generateAtsPdf({
    required MasterProfile profile,
    required JobApplication job,
  }) async {
    final doc = pw.Document();
    final fonts = await _loadFonts();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
      build: (ctx) => [_atsContent(profile, job, fonts)],
    ));
    return doc.save();
  }

  // ══════════════════════════════════════════════════════════════════
  //  VISUAL RESUME SECTIONS
  // ══════════════════════════════════════════════════════════════════

  pw.Widget _header(MasterProfile p, _Fonts f) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(32, 28, 32, 20),
      decoration: const pw.BoxDecoration(color: _dark),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(p.fullName.isNotEmpty ? p.fullName : 'Your Name',
            style: pw.TextStyle(font: f.bold, fontSize: 24, color: _white, letterSpacing: 0.5)),
        pw.SizedBox(height: 7),
        pw.Wrap(spacing: 14, runSpacing: 3, children: [
          if (p.email.isNotEmpty)            _ct(p.email, f),
          if (p.phone.isNotEmpty)            _ct(p.phone, f),
          if (p.location.isNotEmpty)         _ct(p.location, f),
          if ((p.linkedIn ?? '').isNotEmpty) _ct(_url(p.linkedIn!), f),
          if ((p.github ?? '').isNotEmpty)   _ct(_url(p.github!), f),
        ]),
      ]),
    );
  }

  pw.Widget _ct(String t, _Fonts f) => pw.Text(t,
      style: pw.TextStyle(font: f.regular, fontSize: 8.5,
          color: const PdfColor.fromInt(0xFFCCCCEE)));

  // FIX 1: Summary — first person, dynamic, no "Name is a..." pattern
  pw.Widget _summary(MasterProfile p, JobApplication job, _Fonts f) {
    final text = _buildSummary(p, job);
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('PROFESSIONAL SUMMARY', f),
      pw.SizedBox(height: 6),
      pw.Text(text, style: pw.TextStyle(font: f.regular, fontSize: 9.5, color: _text, lineSpacing: 2.2)),
      pw.SizedBox(height: 4),
      _hr(),
    ]);
  }

  pw.Widget _body(MasterProfile p, JobApplication job, _Fonts f) {
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(flex: 62, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (p.experiences.isNotEmpty) ...[_expSection(p, f), pw.SizedBox(height: 12)],
          if (p.projects.isNotEmpty)    ...[_projectSection(p, f), pw.SizedBox(height: 12)],
          if (p.education.isNotEmpty)   _eduSection(p, f),
        ],
      )),
      pw.SizedBox(width: 16),
      pw.Expanded(flex: 38, child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: _sideCol, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if (p.skills.isNotEmpty)         _skillsSection(p, f),
          if (p.certifications.isNotEmpty) ...[pw.SizedBox(height: 12), _certSection(p, f)],
          if (p.languages.isNotEmpty)      ...[pw.SizedBox(height: 12), _langSection(p, f)],
          if (p.softSkills.isNotEmpty)     ...[pw.SizedBox(height: 12), _softSection(p, f)],
        ]),
      )),
    ]);
  }

  pw.Widget _expSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('EXPERIENCE', f),
      pw.SizedBox(height: 7),
      ...p.experiences.map((e) => _expCard(e, f)),
      _hr(),
    ]);
  }

  pw.Widget _projectSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('ACADEMIC PROJECTS', f),
      pw.SizedBox(height: 7),
      ...p.projects.map((proj) {
        // Deduplicated tech stack
        final tech = proj.techStack.toSet().toList();
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(child: pw.Text(proj.title,
                style: pw.TextStyle(font: f.semiBold, fontSize: 10, color: _dark))),
            if (proj.duration.isNotEmpty)
              pw.Text(proj.duration,
                  style: pw.TextStyle(font: f.italic, fontSize: 8, color: _muted)),
          ]),
          pw.SizedBox(height: 3),
          // Description as bullets if multiline, else single paragraph
          ...proj.description.split('\n')
              .map((l) => l.trim()).where((l) => l.isNotEmpty)
              .map((line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('• ', style: pw.TextStyle(font: f.bold, fontSize: 9, color: _accent)),
              pw.Expanded(child: pw.Text(line.replaceAll('•','').trim(),
                  style: pw.TextStyle(font: f.regular, fontSize: 9, color: _text, lineSpacing: 1.4))),
            ]),
          )),
          if (tech.isNotEmpty)
            pw.Padding(padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text('Stack: ${tech.join(", ")}',
                    style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted))),
          if ((proj.githubLink ?? '').isNotEmpty)
            pw.Padding(padding: const pw.EdgeInsets.only(top: 2),
                child: pw.Text('GitHub: ${_url(proj.githubLink!)}',
                    style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _accent))),
          pw.SizedBox(height: 9),
        ]);
      }),
      _hr(),
    ]);
  }

  pw.Widget _expCard(ExperienceEntry exp, _Fonts f) {
    final desc = exp.professionalDescription.isNotEmpty
        ? exp.professionalDescription : exp.rawDescription;
    final bullets = desc.split('\n')
        .map((l) => l.replaceAll(RegExp(r'\*\*?'), '').replaceAll('•','').trim())
        .where((l) => l.isNotEmpty && l.length > 3).toList();
    // Deduplicate tools
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
        pw.Padding(padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Text('Technologies: ${tools.join(", ")}',
                style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted))),
      pw.SizedBox(height: 9),
    ]);
  }

  pw.Widget _eduSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('EDUCATION', f),
      pw.SizedBox(height: 7),
      ...p.education.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(child: pw.Text(e.degree,
                style: pw.TextStyle(font: f.semiBold, fontSize: 10, color: _dark))),
            pw.Text(e.year, style: pw.TextStyle(font: f.italic, fontSize: 8, color: _muted)),
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

  // FIX 2: All skill chips same purple color — no mixed colors
  pw.Widget _skillsSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('TECHNICAL SKILLS', f),
      pw.SizedBox(height: 6),
      pw.Wrap(spacing: 4, runSpacing: 5,
        children: p.skills.take(20).map((s) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(
              color: _accent, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Text(s, style: pw.TextStyle(font: f.semiBold, fontSize: 7.5, color: _white)),
        )).toList(),
      ),
    ]);
  }

  // pw.Widget _certSection(MasterProfile p, _Fonts f) {
  //   return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
  //     _sideTitle('CERTIFICATIONS', f),
  //     pw.SizedBox(height: 5),
  //     ...p.certifications.map((c) => pw.Padding(
  //       padding: const pw.EdgeInsets.only(bottom: 3),
  //       child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
  //         pw.Container(width: 4, height: 4,
  //             margin: const pw.EdgeInsets.only(top: 3, right: 5),
  //             decoration: pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle)),
  //         pw.Expanded(child: pw.Text(c,
  //             style: pw.TextStyle(font: f.regular, fontSize: 8, color: _text))),
  //       ]),
  //     )),
  //   ]);
  // }

  pw.Widget _certSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('CERTIFICATIONS', f),
      pw.SizedBox(height: 5),
      ...p.certifications.map((cert) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(cert.name,
              style: pw.TextStyle(font: f.semiBold, fontSize: 8.5, color: _dark)),
          pw.Text(cert.organization,
              style: pw.TextStyle(font: f.regular, fontSize: 8, color: _accent)),
          pw.Text(
            cert.expiryDate != null && cert.expiryDate!.isNotEmpty
                ? '${cert.issueDate}  |  Exp: ${cert.expiryDate}'
                : cert.issueDate,
            style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted),
          ),
          if ((cert.credentialId ?? '').isNotEmpty)
            pw.Text('ID: ${cert.credentialId}',
                style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted)),
        ]),
      )),
    ]);
  }


  pw.Widget _langSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('LANGUAGES', f),
      pw.SizedBox(height: 5),
      pw.Wrap(spacing: 4, runSpacing: 4,
        children: p.languages.map((l) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(color: _chipBg, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Text(l, style: pw.TextStyle(font: f.regular, fontSize: 8, color: _chipFg)),
        )).toList(),
      ),
    ]);
  }

  // FIX 3: Soft skills as bullet list — no chips, no overflow
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

  // ══════════════════════════════════════════════════════════════════
  //  ATS PLAIN-TEXT RESUME
  // ══════════════════════════════════════════════════════════════════
  pw.Widget _atsContent(MasterProfile p, JobApplication job, _Fonts f) {
    final sections = <pw.Widget>[];

    // Name + contact (plain text header)
    sections.add(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(p.fullName, style: pw.TextStyle(font: f.bold, fontSize: 16, color: _dark)),
      pw.SizedBox(height: 4),
      pw.Text([
        if (p.email.isNotEmpty) p.email,
        if (p.phone.isNotEmpty) p.phone,
        if (p.location.isNotEmpty) p.location,
        if ((p.linkedIn ?? '').isNotEmpty) _url(p.linkedIn!),
        if ((p.github ?? '').isNotEmpty) _url(p.github!),
      ].join('  |  '),
          style: pw.TextStyle(font: f.regular, fontSize: 9, color: _text)),
      pw.SizedBox(height: 8),
      pw.Container(height: 1, color: _dark),
      pw.SizedBox(height: 10),
    ]));

    // Summary
    sections.add(_atsSection('PROFESSIONAL SUMMARY', [_buildSummary(p, job)], f));

    // Skills
    if (p.skills.isNotEmpty) {
      sections.add(_atsSection('TECHNICAL SKILLS', [p.skills.join(' | ')], f));
    }

    // Experience
    if (p.experiences.isNotEmpty) {
      final lines = <String>[];
      for (final e in p.experiences) {
        lines.add('${e.title} | ${e.organization} | ${e.duration}');
        final desc = e.professionalDescription.isNotEmpty ? e.professionalDescription : e.rawDescription;
        for (final b in desc.split('\n').where((l) => l.trim().isNotEmpty)) {
          lines.add('• ${b.replaceAll(RegExp(r'\*\*?'),'').replaceAll('•','').trim()}');
        }
        if (e.toolsUsed.isNotEmpty) lines.add('Technologies: ${e.toolsUsed.toSet().join(", ")}');
        lines.add('');
      }
      sections.add(_atsSection('EXPERIENCE', lines, f));
    }

    // Projects
    if (p.projects.isNotEmpty) {
      final lines = <String>[];
      for (final proj in p.projects) {
        lines.add('${proj.title}${proj.duration.isNotEmpty ? " | ${proj.duration}" : ""}');
        for (final b in proj.description.split('\n').where((l) => l.trim().isNotEmpty)) {
          lines.add('• ${b.replaceAll('•','').trim()}');
        }
        if (proj.techStack.isNotEmpty) lines.add('Stack: ${proj.techStack.toSet().join(", ")}');
        if ((proj.githubLink ?? '').isNotEmpty) lines.add('GitHub: ${proj.githubLink}');
        lines.add('');
      }
      sections.add(_atsSection('ACADEMIC PROJECTS', lines, f));
    }

    // Education
    if (p.education.isNotEmpty) {
      final lines = p.education.map((e) =>
      '${e.degree} | ${e.institution} | ${e.year}${(e.grade ?? '').isNotEmpty ? " | ${e.grade}" : ""}'
      ).toList();
      sections.add(_atsSection('EDUCATION', lines, f));
    }

    // Certifications
    // if (p.certifications.isNotEmpty) {
    //   sections.add(_atsSection('CERTIFICATIONS', p.certifications, f));
    // }
    // Certifications
    if (p.certifications.isNotEmpty) {
      final certLines = p.certifications.map((cert) {
        final parts = [cert.name, cert.organization, cert.issueDate];
        if ((cert.expiryDate ?? '').isNotEmpty) parts.add('Exp: ${cert.expiryDate}');
        if ((cert.credentialId ?? '').isNotEmpty) parts.add('ID: ${cert.credentialId}');
        return parts.join(' | ');
      }).toList();
      sections.add(_atsSection('CERTIFICATIONS', certLines, f));
    }


    // Languages
    if (p.languages.isNotEmpty) {
      sections.add(_atsSection('LANGUAGES', [p.languages.join(', ')], f));
    }

    // Soft skills
    if (p.softSkills.isNotEmpty) {
      sections.add(_atsSection('SOFT SKILLS', [p.softSkills.join(' | ')], f));
    }

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: sections);
  }

  pw.Widget _atsSection(String title, List<String> lines, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(font: f.bold, fontSize: 10, color: _dark, letterSpacing: 1)),
      pw.Container(height: 0.8, color: _dark, margin: const pw.EdgeInsets.symmetric(vertical: 3)),
      ...lines.map((line) => line.isEmpty
          ? pw.SizedBox(height: 4)
          : pw.Text(line, style: pw.TextStyle(font: f.regular, fontSize: 9.5, color: _text, lineSpacing: 1.8))),
      pw.SizedBox(height: 10),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  //  FIX 1: SUMMARY — first person, dynamic, unique every time
  // ══════════════════════════════════════════════════════════════════
  String _buildSummary(MasterProfile p, JobApplication job) {
    final rand = Random();
    final role = job.roleTitle.isNotEmpty ? job.roleTitle : 'this role';
    final company = job.companyName.isNotEmpty ? job.companyName : 'your organization';
    final topSkills = p.skills.take(4).join(', ');
    final yearsExp = p.experiences.length;

    // Dynamic opening phrases — picks one randomly each time
    final openings = [
      'Results-driven professional with proven expertise in $topSkills.',
      'Passionate and detail-oriented developer skilled in $topSkills.',
      'Motivated ${yearsExp > 0 ? "professional" : "fresher"} with hands-on experience in $topSkills.',
      'Driven by a commitment to excellence, bringing strong skills in $topSkills.',
      'Enthusiastic and adaptable professional proficient in $topSkills.',
    ];

    final middles = [
      'Adept at delivering impactful, scalable solutions under tight deadlines.',
      'Known for translating complex requirements into clean, efficient implementations.',
      'Committed to continuous learning and applying best practices in every project.',
      'Experienced in collaborating cross-functionally to achieve measurable outcomes.',
      'Strong track record of building reliable, user-focused applications.',
    ];

    // final closings = [
    //   'Seeking to bring this expertise to $company as $role and make an immediate impact.',
    //   'Eager to leverage these skills at $company to contribute meaningfully as $role.',
    //   'Looking to grow and deliver value as $role at $company.',
    //   'Excited to apply this background at $company and excel as $role.',
    // ];

    final closings = [
      'Committed to continuous learning, professional growth, and delivering meaningful results.',
      'Known for adaptability, strong problem-solving abilities, and a proactive approach to new challenges.',
      'Bringing a combination of academic knowledge, practical experience, and a passion for excellence.',
      'Dedicated to applying skills and knowledge to create positive impact and achieve meaningful outcomes.',
      'Focused on continuous improvement, collaboration, and delivering high-quality work.',
    ];

    // Add experience context if available
    String expContext = '';
    if (p.experiences.isNotEmpty) {
      final latest = p.experiences.first;
      expContext = ' With experience as ${latest.title} at ${latest.organization},';
    } else if (p.projects.isNotEmpty) {
      expContext = ' With ${p.projects.length} academic project${p.projects.length > 1 ? "s" : ""},';
    }

    final opening = openings[rand.nextInt(openings.length)];
    final middle  = middles[rand.nextInt(middles.length)];
    final closing = closings[rand.nextInt(closings.length)];

    return '$opening$expContext $middle $closing';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  pw.Widget _secTitle(String t, _Fonts f) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(t, style: pw.TextStyle(font: f.bold, fontSize: 9, color: _accent, letterSpacing: 1.5)),
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