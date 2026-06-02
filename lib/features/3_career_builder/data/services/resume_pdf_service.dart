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
  static const _sideCol = PdfColor.fromInt(0xFFF0EFFF); // right column bg
  static const _divCol  = PdfColor.fromInt(0xFFE0E0F0);
  static const _white   = PdfColors.white;
  static const _chipBg  = PdfColor.fromInt(0xFFEDECFF); // unmatched chip bg
  static const _chipFg  = PdfColor.fromInt(0xFF4A4580); // unmatched chip text

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
                _summary(job, profile, fonts),
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
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(
          p.fullName.isNotEmpty ? p.fullName : 'Your Name',
          style: pw.TextStyle(font: f.bold, fontSize: 26, color: _white, letterSpacing: 0.5),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 14,
          runSpacing: 3,
          children: [
            if (p.email.isNotEmpty)    _chip(p.email, f),
            if (p.phone.isNotEmpty)    _chip(p.phone, f),
            if (p.location.isNotEmpty) _chip(p.location, f),
            if ((p.linkedIn ?? '').isNotEmpty) _chip(_url(p.linkedIn!), f),
            if ((p.github ?? '').isNotEmpty)   _chip(_url(p.github!), f),
          ],
        ),
      ]),
    );
  }

  pw.Widget _chip(String t, _Fonts f) => pw.Text(t,
      style: pw.TextStyle(font: f.regular, fontSize: 8.5,
          color: const PdfColor.fromInt(0xFFCCCCEE)));

  // ── FIX 1: Summary — pull it cleanly from AI text, strip markdown ──────────
  pw.Widget _summary(JobApplication job, MasterProfile profile, _Fonts f) {
    final text = _extractSummaryText(job.generatedResume, profile);
    if (text.isEmpty) return pw.SizedBox();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('PROFESSIONAL SUMMARY', f),
      pw.SizedBox(height: 6),
      pw.Text(text,
          style: pw.TextStyle(font: f.regular, fontSize: 9.5, color: _text, lineSpacing: 2)),
      pw.SizedBox(height: 4),
      _hr(),
    ]);
  }

  // Extract summary: find the SUMMARY section, strip ** markdown, clean it up
  String _extractSummaryText(String resume, MasterProfile profile) {
    final lines = resume.split('\n').map((l) => l.trim()).toList();
    final summaryIdx = lines.indexWhere(
            (l) => l.toUpperCase().contains('SUMMARY'));

    if (summaryIdx != -1 && summaryIdx + 1 < lines.length) {
      // Collect lines after SUMMARY header until next ALL-CAPS section
      final buffer = StringBuffer();
      for (int i = summaryIdx + 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.isEmpty) continue;
        // Stop at next section header (all caps, short)
        if (RegExp(r'^[A-Z\s&|/]{4,}$').hasMatch(line) && line.length < 30) break;
        // Strip markdown bold/italic
        final clean = line
            .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
            .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
            .replaceAll('**', '')
            .replaceAll('*', '')
            .trim();
        if (clean.isNotEmpty) buffer.write('$clean ');
      }
      final result = buffer.toString().trim();
      if (result.length > 20) return result;
    }

    // Fallback: use first long non-bullet line
    for (final line in lines) {
      final clean = line
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
          .replaceAll('**', '').replaceAll('*', '').trim();
      if (!clean.startsWith('•') && clean.length > 50 &&
          !RegExp(r'^[A-Z\s&|/]{4,}$').hasMatch(clean)) {
        return clean;
      }
    }
    return '';
  }

  // ── Two-column body ────────────────────────────────────────────────────────
  pw.Widget _body(MasterProfile p, JobApplication job, _Fonts f) {
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(flex: 62, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _experienceSection(p, job, f),
          pw.SizedBox(height: 14),
          _educationSection(p, f),
        ],
      )),
      pw.SizedBox(width: 18),
      pw.Expanded(flex: 38, child: pw.Container(
        padding: const pw.EdgeInsets.all(13),
        decoration: pw.BoxDecoration(
          color: _sideCol,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          _skillsSection(p, job, f),
          if (p.certifications.isNotEmpty) ...[pw.SizedBox(height: 12), _certSection(p, f)],
          if (p.languages.isNotEmpty)      ...[pw.SizedBox(height: 12), _langSection(p, f)],
          if (p.softSkills.isNotEmpty)     ...[pw.SizedBox(height: 12), _softSkillsSection(p, f)],
        ]),
      )),
    ]);
  }

  // ── Experience ─────────────────────────────────────────────────────────────
  pw.Widget _experienceSection(MasterProfile p, JobApplication job, _Fonts f) {
    if (p.experiences.isEmpty) return pw.SizedBox();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _secTitle('EXPERIENCE', f),
      pw.SizedBox(height: 8),
      ...p.experiences.map((exp) {
        final raw = exp.professionalDescription.isNotEmpty
            ? exp.professionalDescription : exp.rawDescription;
        final bullets = raw.split('\n')
            .map((l) => l.replaceAll('•', '').replaceAll('**', '').replaceAll('*', '').trim())
            .where((l) => l.isNotEmpty).toList();
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
          if (exp.toolsUsed.isNotEmpty)
            pw.Padding(padding: const pw.EdgeInsets.only(top: 2),
                child: pw.Text('Tools: ${exp.toolsUsed.join(" • ")}',
                    style: pw.TextStyle(font: f.italic, fontSize: 7.5, color: _muted))),
          pw.SizedBox(height: 10),
        ]);
      }),
      _hr(),
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

  // ── FIX 2: Skills — consistent chip colors (purple=matched, grey=others) ──
  pw.Widget _skillsSection(MasterProfile p, JobApplication job, _Fonts f) {
    if (p.skills.isEmpty) return pw.SizedBox();
    final matched = job.matchedSkills.map((s) => s.toLowerCase()).toSet();
    final sorted = [
      ...p.skills.where((s) => matched.contains(s.toLowerCase())),
      ...p.skills.where((s) => !matched.contains(s.toLowerCase())),
    ];
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('TECHNICAL SKILLS', f),
      pw.SizedBox(height: 6),
      pw.Wrap(spacing: 4, runSpacing: 5,
        children: sorted.take(18).map((s) {
          final isMatch = matched.contains(s.toLowerCase());
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
              // FIX: matched=accent purple, unmatched=light grey — no mixed colors
              color: isMatch ? _accent : _chipBg,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(s,
                style: pw.TextStyle(
                  font: f.semiBold, fontSize: 7.5,
                  color: isMatch ? _white : _chipFg,
                )),
          );
        }).toList(),
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
          decoration: pw.BoxDecoration(
              color: _chipBg, borderRadius: pw.BorderRadius.circular(3)),
          child: pw.Text(l,
              style: pw.TextStyle(font: f.regular, fontSize: 8, color: _chipFg)),
        )).toList(),
      ),
    ]);
  }

  // ── FIX 3: Soft Skills — use bullet list, NOT chips (avoids overflow) ──────
  pw.Widget _softSkillsSection(MasterProfile p, _Fonts f) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sideTitle('SOFT SKILLS', f),
      pw.SizedBox(height: 5),
      // Use simple bullet rows — no containers, no wrapping, no overflow
      ...p.softSkills.map((s) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: 4, height: 4,
            margin: const pw.EdgeInsets.only(top: 3, right: 6),
            decoration: pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle),
          ),
          pw.Expanded(
            // pw.Expanded inside right column ensures text wraps, never overflows
            child: pw.Text(s,
                style: pw.TextStyle(font: f.regular, fontSize: 8.5, color: _text)),
          ),
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