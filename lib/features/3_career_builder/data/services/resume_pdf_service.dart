import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../models/master_profile_model.dart';
import '../models/job_application_model.dart';

class ResumePdfService {
  // Brand colors
  static const _accent = PdfColor.fromInt(0xFF6C63FF);
  static const _dark = PdfColor.fromInt(0xFF1A1A2E);
  static const _text = PdfColor.fromInt(0xFF2D2D3A);
  static const _muted = PdfColor.fromInt(0xFF6B6B80);
  static const _light = PdfColor.fromInt(0xFFF5F5FF);
  static const _divider = PdfColor.fromInt(0xFFE0E0F0);
  static const _white = PdfColors.white;

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
          _buildHeader(profile, fonts),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                _buildSummary(job, fonts),
                pw.SizedBox(height: 18),
                _buildTwoColumnBody(profile, job, fonts),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  pw.Widget _buildHeader(MasterProfile profile, _Fonts f) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(32, 32, 32, 24),
      decoration: const pw.BoxDecoration(color: _dark),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            profile.fullName.isNotEmpty ? profile.fullName : 'Your Name',
            style: pw.TextStyle(
              font: f.bold,
              fontSize: 28,
              color: _white,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 10),
          // Contact row
          pw.Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (profile.email.isNotEmpty)
                _contactChip(profile.email, f),
              if (profile.phone.isNotEmpty)
                _contactChip(profile.phone, f),
              if (profile.location.isNotEmpty)
                _contactChip(profile.location, f),
              if (profile.linkedIn != null && profile.linkedIn!.isNotEmpty)
                _contactChip(_cleanUrl(profile.linkedIn!), f),
              if (profile.github != null && profile.github!.isNotEmpty)
                _contactChip(_cleanUrl(profile.github!), f),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _contactChip(String text, _Fonts f) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        font: f.regular,
        fontSize: 9,
        color: const PdfColor.fromInt(0xFFCCCCEE),
      ),
    );
  }

  // ── Summary ────────────────────────────────────────────────────────────────
  pw.Widget _buildSummary(JobApplication job, _Fonts f) {
    // Extract first paragraph from generated resume as summary
    final lines = job.generatedResume
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String summary = '';
    for (final line in lines) {
      if (!line.startsWith('•') &&
          !line.toUpperCase().contains('SUMMARY') &&
          !line.toUpperCase().contains('SKILLS') &&
          !line.toUpperCase().contains('EXPERIENCE') &&
          !line.toUpperCase().contains('EDUCATION') &&
          line.length > 40) {
        summary = line;
        break;
      }
    }

    if (summary.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('PROFESSIONAL SUMMARY', f),
        pw.SizedBox(height: 6),
        pw.Text(
          summary,
          style: pw.TextStyle(
            font: f.regular,
            fontSize: 9.5,
            color: _text,
            lineSpacing: 2,
          ),
        ),
        pw.SizedBox(height: 4),
        _dividerLine(),
      ],
    );
  }

  // ── Two-column body ────────────────────────────────────────────────────────
  pw.Widget _buildTwoColumnBody(
      MasterProfile profile, JobApplication job, _Fonts f) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left column — 62%
        pw.Expanded(
          flex: 62,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildExperienceSection(profile, job, f),
              pw.SizedBox(height: 16),
              _buildEducationSection(profile, f),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        // Right column — 38%
        pw.Expanded(
          flex: 38,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: _light,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSkillsSection(profile, job, f),
                if (profile.certifications.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  _buildCertSection(profile, f),
                ],
                if (profile.languages.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  _buildLanguagesSection(profile, f),
                ],
                if (profile.softSkills.isNotEmpty) ...[
                  pw.SizedBox(height: 14),
                  _buildSoftSkillsSection(profile, f),
                ],
                // if (job.matchedSkills.isNotEmpty) ...[
                //   pw.SizedBox(height: 14),
                //   _buildMatchedSection(job, f),
                // ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Experience ─────────────────────────────────────────────────────────────
  pw.Widget _buildExperienceSection(
      MasterProfile profile, JobApplication job, _Fonts f) {
    // Extract experience bullets from AI resume text
    final expBullets = _extractSection(job.generatedResume, 'EXPERIENCE');

    if (profile.experiences.isEmpty && expBullets.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('EXPERIENCE', f),
        pw.SizedBox(height: 8),
        if (expBullets.isNotEmpty)
        // Use AI-generated bullets (better language)
          ...profile.experiences.asMap().entries.map((entry) {
            final exp = entry.value;
            final desc = exp.professionalDescription.isNotEmpty
                ? exp.professionalDescription
                : exp.rawDescription;
            final bullets = desc
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        exp.title,
                        style: pw.TextStyle(
                          font: f.semiBold,
                          fontSize: 10,
                          color: _dark,
                        ),
                      ),
                    ),
                    pw.Text(
                      exp.duration,
                      style: pw.TextStyle(
                        font: f.italic,
                        fontSize: 8.5,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  exp.organization,
                  style: pw.TextStyle(
                    font: f.regular,
                    fontSize: 9,
                    color: _accent,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...bullets.map((b) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(
                              font: f.bold, fontSize: 9, color: _accent)),
                      pw.Expanded(
                        child: pw.Text(
                          b.replaceAll('•', '').trim(),
                          style: pw.TextStyle(
                              font: f.regular,
                              fontSize: 9,
                              color: _text,
                              lineSpacing: 1.5),
                        ),
                      ),
                    ],
                  ),
                )),
                if (exp.toolsUsed.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: pw.Text(
                      'Tools: ${exp.toolsUsed.join(" • ")}',
                      style: pw.TextStyle(
                          font: f.italic, fontSize: 8, color: _muted),
                    ),
                  ),
                pw.SizedBox(height: 10),
              ],
            );
          })
        else
          pw.Text(
            'Experience details in profile',
            style: pw.TextStyle(font: f.regular, fontSize: 9, color: _muted),
          ),
        _dividerLine(),
      ],
    );
  }

  // ── Education ──────────────────────────────────────────────────────────────
  pw.Widget _buildEducationSection(MasterProfile profile, _Fonts f) {
    if (profile.education.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('EDUCATION', f),
        pw.SizedBox(height: 8),
        ...profile.education.map((edu) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      edu.degree,
                      style: pw.TextStyle(
                          font: f.semiBold, fontSize: 10, color: _dark),
                    ),
                  ),
                  pw.Text(
                    edu.year,
                    style: pw.TextStyle(
                        font: f.italic, fontSize: 8.5, color: _muted),
                  ),
                ],
              ),
              pw.Text(
                edu.institution,
                style: pw.TextStyle(
                    font: f.regular, fontSize: 9, color: _accent),
              ),
              if (edu.grade != null && edu.grade!.isNotEmpty)
                pw.Text(
                  'Grade: ${edu.grade}',
                  style: pw.TextStyle(
                      font: f.italic, fontSize: 8.5, color: _muted),
                ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Skills (right column) ──────────────────────────────────────────────────
  pw.Widget _buildSkillsSection(
      MasterProfile profile, JobApplication job, _Fonts f) {
    if (profile.skills.isEmpty) return pw.SizedBox();

    // Prioritize matched skills first
    final matched = job.matchedSkills.toSet();
    final sorted = [
      ...profile.skills.where((s) => matched.contains(s)),
      ...profile.skills.where((s) => !matched.contains(s)),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sideTitle('TECHNICAL SKILLS', f),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 4,
          runSpacing: 4,
          children: sorted.take(16).map((s) {
            final isMatch = matched.contains(s);
            return pw.Container(
              padding:
              const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: pw.BoxDecoration(
                color: isMatch
                    ? const PdfColor.fromInt(0xFF6C63FF)
                    : const PdfColor.fromInt(0xFFE8E8F8),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                s,
                style: pw.TextStyle(
                  font: f.semiBold,
                  fontSize: 7.5,
                  color: isMatch ? _white : _text,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Certifications ─────────────────────────────────────────────────────────
  pw.Widget _buildCertSection(MasterProfile profile, _Fonts f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sideTitle('CERTIFICATIONS', f),
        pw.SizedBox(height: 6),
        ...profile.certifications.map((c) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 3, right: 5),
                decoration: pw.BoxDecoration(
                  color: _accent,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  c,
                  style: pw.TextStyle(
                      font: f.regular, fontSize: 8.5, color: _text),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Languages ──────────────────────────────────────────────────────────────
  pw.Widget _buildLanguagesSection(MasterProfile profile, _Fonts f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sideTitle('LANGUAGES', f),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 4,
          runSpacing: 4,
          children: profile.languages.map((l) => pw.Container(
            padding:
            const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE8E8F8),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              l,
              style: pw.TextStyle(
                  font: f.regular, fontSize: 8, color: _text),
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ── Soft Skills ────────────────────────────────────────────────────────────
  pw.Widget _buildSoftSkillsSection(MasterProfile profile, _Fonts f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sideTitle('SOFT SKILLS', f),
        pw.SizedBox(height: 6),
        ...profile.softSkills.map((s) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            children: [
              pw.Container(
                width: 4, height: 4,
                margin: const pw.EdgeInsets.only(top: 2, right: 5),
                decoration: pw.BoxDecoration(
                    color: _accent, shape: pw.BoxShape.circle),
              ),
              pw.Text(s,
                  style: pw.TextStyle(
                      font: f.regular, fontSize: 8.5, color: _text)),
            ],
          ),
        )),
      ],
    );
  }

  // ── Matched keywords ───────────────────────────────────────────────────────
  // pw.Widget _buildMatchedSection(JobApplication job, _Fonts f) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       _sideTitle('ATS MATCH', f),
  //       pw.SizedBox(height: 4),
  //       pw.Text(
  //         '${job.matchScore}% match for ${job.roleTitle}',
  //         style: pw.TextStyle(
  //           font: f.semiBold,
  //           fontSize: 8,
  //           color: job.matchScore >= 70
  //               ? const PdfColor.fromInt(0xFF4CAF82)
  //               : const PdfColor.fromInt(0xFFFFB830),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ── Helpers ────────────────────────────────────────────────────────────────
  pw.Widget _sectionTitle(String title, _Fonts f) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: f.bold,
            fontSize: 9,
            color: _accent,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 1.5, color: _accent),
      ],
    );
  }

  pw.Widget _sideTitle(String title, _Fonts f) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: f.bold,
        fontSize: 8,
        color: _dark,
        letterSpacing: 1.2,
      ),
    );
  }

  pw.Widget _dividerLine() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Container(height: 0.5, color: _divider),
    );
  }

  List<String> _extractSection(String resume, String section) {
    final lines = resume.split('\n');
    final bullets = <String>[];
    bool inSection = false;
    for (final line in lines) {
      if (line.toUpperCase().contains(section)) {
        inSection = true;
        continue;
      }
      if (inSection) {
        if (line.trim().isEmpty) continue;
        if (RegExp(r'^[A-Z\s]{4,}$').hasMatch(line.trim()) &&
            !line.trim().startsWith('•')) {
          break;
        }
        if (line.trim().startsWith('•') || line.trim().isNotEmpty) {
          bullets.add(line.trim());
        }
      }
    }
    return bullets;
  }

  String _cleanUrl(String url) {
    return url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
  }

  Future<_Fonts> _loadFonts() async {
    return _Fonts(
      regular: await PdfGoogleFonts.nunitoRegular(),
      bold: await PdfGoogleFonts.nunitoBold(),
      semiBold: await PdfGoogleFonts.nunitoSemiBold(),
      italic: await PdfGoogleFonts.nunitoItalic(),
    );
  }
}

class _Fonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font semiBold;
  final pw.Font italic;

  _Fonts({
    required this.regular,
    required this.bold,
    required this.semiBold,
    required this.italic,
  });
}