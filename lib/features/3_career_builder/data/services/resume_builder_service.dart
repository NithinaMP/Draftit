import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/groq_client.dart';
import '../models/master_profile_model.dart';
import '../models/job_application_model.dart';

class ResumeBuilderService {
  final GroqClient _client = GroqClient();

  /// Translate a raw experience description into corporate language
  Future<String> translateExperience({
    required String rawDescription,
    required String role,
    required String companyTone,
  }) async {
    const system =
        'You are a professional resume writer who specializes in corporate language. '
        'Transform raw student descriptions into powerful, ATS-optimized resume bullets. '
        'Use strong action verbs and quantify impact wherever possible.';

    final toneGuide = _toneGuide(companyTone);

    final user =
        'Transform this raw experience description into 2-3 professional resume bullet points.\n\n'
        'ROLE: $role\n'
        'TONE: $toneGuide\n'
        'RAW DESCRIPTION: $rawDescription\n\n'
        'Rules:\n'
        '- Start each bullet with a strong action verb\n'
        '- Quantify results where possible (e.g., "increased by 30%")\n'
        '- Use corporate/professional language\n'
        '- Each bullet max 20 words\n'
        '- Return ONLY the bullets, one per line, starting with "•"';

    return _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 300,
      temperature: 0.3,
    );
  }

  /// Generate a complete ATS-optimized targeted resume
  Future<String> generateTargetedResume({
    required MasterProfile profile,
    required JobApplication job,
  }) async {
    final toneGuide = _toneGuide(job.companyTone);

    const system =
        'You are a world-class resume writer and ATS optimization specialist. '
        'You craft targeted, high-impact resumes that pass ATS filters and impress recruiters. '
        'Return ONLY the formatted resume text, no commentary.';

    // Build experience section from profile
    final expSection = profile.experiences.map((e) {
      final desc = e.professionalDescription.isNotEmpty
          ? e.professionalDescription
          : e.rawDescription;
      return '${e.title} at ${e.organization} (${e.duration})\n$desc';
    }).join('\n\n');

    // Build education section
    final eduSection = profile.education.map((e) {
      final grade = e.grade != null ? ' — ${e.grade}' : '';
      return '${e.degree}, ${e.institution}, ${e.year}$grade';
    }).join('\n');

    final user =
        'Create a targeted resume for this candidate applying to this specific job.\n\n'
        '=== CANDIDATE PROFILE ===\n'
        'Name: ${profile.fullName}\n'
        'Email: ${profile.email} | Phone: ${profile.phone}\n'
        'Location: ${profile.location}\n'
        '${profile.linkedIn != null ? "LinkedIn: ${profile.linkedIn}" : ""}\n'
        '${profile.github != null ? "GitHub: ${profile.github}" : ""}\n\n'
        'SKILLS: ${profile.skills.join(", ")}\n\n'
        'EDUCATION:\n$eduSection\n\n'
        'EXPERIENCE:\n$expSection\n\n'
        '${profile.certifications.isNotEmpty ? "CERTIFICATIONS:\n${profile.certifications.join(", ")}" : ""}\n\n'
        '=== TARGET JOB ===\n'
        'Company: ${job.companyName}\n'
        'Role: ${job.roleTitle}\n'
        'Tone: $toneGuide\n'
        'Required Skills: ${job.requiredSkills.join(", ")}\n'
        'ATS Keywords to include: ${job.requiredSkills.take(8).join(", ")}\n\n'
        'JOB DESCRIPTION (for context):\n${job.jobDescription.substring(0, job.jobDescription.length.clamp(0, 800))}\n\n'
        'INSTRUCTIONS:\n'
        '1. Write a 2-3 line professional summary targeting THIS specific role\n'
        '2. Reorder and rephrase experience bullets to emphasize relevant skills\n'
        '3. Naturally weave in the ATS keywords\n'
        '4. Use the appropriate tone ($toneGuide)\n'
        '5. Format cleanly with clear sections: SUMMARY | SKILLS | EXPERIENCE | EDUCATION\n'
        '6. Keep it to one page worth of content\n'
        '7. Use "•" for bullet points';

    return _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 1500,
      temperature: 0.25,
    );
  }

  /// Generate the match score improvement suggestion
  Future<String> generateImprovementPlan({
    required List<String> missingSkills,
    required String roleTitle,
    required List<String> lectureSkills,
  }) async {
    if (missingSkills.isEmpty) return 'Your profile is a strong match for this role!';

    const system =
        'You are a career counselor giving concise, actionable advice. '
        'Be direct and practical.';

    final user =
        'A student is applying for: $roleTitle\n'
        'They are missing these skills from the JD: ${missingSkills.join(", ")}\n'
        'Skills they already have from lectures: ${lectureSkills.join(", ")}\n\n'
        'Give a 3-point action plan (numbered list) to close these gaps. '
        'Be specific — suggest free resources, projects, or quick certifications. '
        'Keep each point under 25 words.';

    return _client.generateText(
      systemPrompt: system,
      userMessage: user,
      maxTokens: 300,
      temperature: 0.4,
    );
  }

  String _toneGuide(String tone) {
    switch (tone) {
      case 'startup':
        return 'Aggressive, fast-paced, results-driven. Use words like "scaled", "launched", "drove growth"';
      case 'big4':
        return 'Highly formal, procedural, client-focused. Use words like "facilitated", "coordinated", "delivered"';
      case 'tech':
        return 'Technical, innovative, precise. Use specific tech terms and quantified performance metrics';
      case 'healthcare':
        return 'Compassionate, precise, compliance-aware. Use clinical terminology where appropriate';
      default: // corporate
        return 'Professional, structured, outcome-focused. Use words like "achieved", "managed", "optimized"';
    }
  }
}