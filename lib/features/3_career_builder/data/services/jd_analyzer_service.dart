import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/groq_client.dart';

class JdAnalyzerService {
  final GroqClient _client = GroqClient();

  /// Analyze a job description — extract required skills,
  /// detect company tone, and calculate match score
  Future<Map<String, dynamic>> analyzeJd({
    required String jobDescription,
    required List<String> studentSkills,
    required String roleTitle,
    required String companyName,
  }) async {
    const system =
        'You are an expert ATS (Applicant Tracking System) analyst and corporate recruiter. '
        'You analyze job descriptions with precision. '
        'Always respond with ONLY valid JSON. No explanations, no markdown.';

    final user =
        'Analyze this job description and return a structured analysis.\n\n'
        'COMPANY: $companyName\n'
        'ROLE: $roleTitle\n'
        'JOB DESCRIPTION:\n$jobDescription\n\n'
        'STUDENT\'S CURRENT SKILLS: ${studentSkills.join(", ")}\n\n'
        'Return this EXACT JSON:\n'
        '{\n'
        '  "required_skills": ["skill1", "skill2", "skill3"],\n'
        '  "nice_to_have_skills": ["skill4", "skill5"],\n'
        '  "key_responsibilities": ["responsibility1", "responsibility2"],\n'
        '  "company_tone": "startup",\n'
        '  "tone_explanation": "One sentence why you chose this tone",\n'
        '  "matched_skills": ["skill1"],\n'
        '  "missing_skills": ["skill2", "skill3"],\n'
        '  "match_score": 72,\n'
        '  "ats_keywords": ["keyword1", "keyword2"],\n'
        '  "gap_advice": "Specific 1-2 sentence advice on how to close skill gaps"\n'
        '}\n\n'
        'Company tone options: "startup" (fast-paced, results-driven), '
        '"corporate" (formal, structured), "big4" (professional, procedural), '
        '"tech" (innovative, technical), "healthcare" (precise, compassionate).\n'
        'match_score: integer 0-100 based on how many required_skills the student has.';

    final raw = await _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 1000,
      temperature: 0.1,
    );

    debugPrint('🔍 JD Analysis raw: $raw');
    return _parse(raw);
  }

  /// Recalculate score after student adds a missing skill
  Future<int> recalculateScore({
    required List<String> requiredSkills,
    required List<String> updatedStudentSkills,
  }) async {
    if (requiredSkills.isEmpty) return 100;
    final matched = requiredSkills
        .where((s) => updatedStudentSkills.any(
          (us) => us.toLowerCase().contains(s.toLowerCase()) ||
          s.toLowerCase().contains(us.toLowerCase()),
    ))
        .length;
    return ((matched / requiredSkills.length) * 100).round().clamp(0, 100);
  }

  Map<String, dynamic> _parse(String raw) {
    final cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw Exception('JSON_PARSE_ERROR: Could not parse JD analysis');
    }
    return jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
  }
}