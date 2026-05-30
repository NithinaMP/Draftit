import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/local/hive_job_box.dart';
import '../data/models/job_application_model.dart';
import '../data/models/master_profile_model.dart';
import '../data/services/jd_analyzer_service.dart';
import '../data/services/resume_builder_service.dart';

enum JobStatus { idle, analyzing, generating, done, error }

class JobApplicationProvider extends ChangeNotifier {
  final HiveJobBox _jobBox = HiveJobBox();
  final JdAnalyzerService _jdService = JdAnalyzerService();
  final ResumeBuilderService _resumeService = ResumeBuilderService();

  JobStatus _status = JobStatus.idle;
  List<JobApplication> _applications = [];
  JobApplication? _currentJob;
  String? _error;
  String _statusLabel = '';
  String _improvementPlan = '';

  JobStatus get status => _status;
  List<JobApplication> get applications => _applications;
  JobApplication? get currentJob => _currentJob;
  String? get error => _error;
  String get statusLabel => _statusLabel;
  String get improvementPlan => _improvementPlan;
  bool get isProcessing =>
      _status == JobStatus.analyzing || _status == JobStatus.generating;

  Future<void> loadApplications() async {
    _applications = await _jobBox.getAll();
    notifyListeners();
  }

  /// Full pipeline: analyze JD → calculate score → generate targeted resume
  Future<void> analyzeAndGenerate({
    required String companyName,
    required String roleTitle,
    required String jobDescription,
    required MasterProfile profile,
  }) async {
    _error = null;
    _currentJob = null;
    _improvementPlan = '';

    try {
      // Step 1: Analyze JD
      _setStatus(JobStatus.analyzing, 'Analyzing job description...');
      final analysis = await _jdService.analyzeJd(
        jobDescription: jobDescription,
        studentSkills: profile.skills,
        roleTitle: roleTitle,
        companyName: companyName,
      );

      final job = JobApplication(
        id: const Uuid().v4(),
        companyName: companyName,
        roleTitle: roleTitle,
        jobDescription: jobDescription,
        requiredSkills: List<String>.from(analysis['required_skills'] ?? []),
        missingSkills: List<String>.from(analysis['missing_skills'] ?? []),
        matchedSkills: List<String>.from(analysis['matched_skills'] ?? []),
        matchScore: (analysis['match_score'] as num?)?.toInt() ?? 0,
        companyTone: analysis['company_tone'] as String? ?? 'corporate',
        createdAt: DateTime.now(),
      );

      // Step 2: Generate improvement plan for missing skills
      if (job.missingSkills.isNotEmpty) {
        _setStatus(JobStatus.analyzing, 'Building improvement plan...');
        _improvementPlan = await _resumeService.generateImprovementPlan(
          missingSkills: job.missingSkills,
          roleTitle: roleTitle,
          lectureSkills: profile.skills,
        );
      }

      // Step 3: Generate targeted resume
      _setStatus(JobStatus.generating, 'Writing your targeted resume...');
      final resume = await _resumeService.generateTargetedResume(
        profile: profile,
        job: job,
      );
      job.generatedResume = resume;

      // Save
      await _jobBox.save(job);
      _applications.insert(0, job);
      _currentJob = job;
      _setStatus(JobStatus.done, 'Resume ready!');
    } catch (e) {
      debugPrint('❌ Job analysis failed: $e');
      _error = _friendlyError(e.toString());
      _setStatus(JobStatus.error, 'Failed');
    }
  }

  /// Regenerate resume with updated profile after adding missing skills
  Future<void> regenerateResume({
    required MasterProfile profile,
  }) async {
    if (_currentJob == null) return;
    _error = null;
    _setStatus(JobStatus.generating, 'Rewriting targeted resume...');

    try {
      // Recalculate score
      final newScore = await _jdService.recalculateScore(
        requiredSkills: _currentJob!.requiredSkills,
        updatedStudentSkills: profile.skills,
      );
      _currentJob!.matchScore = newScore;

      // Update missing/matched
      _currentJob!.matchedSkills = profile.skills
          .where((s) => _currentJob!.requiredSkills.any(
            (r) => r.toLowerCase().contains(s.toLowerCase()) ||
            s.toLowerCase().contains(r.toLowerCase()),
      ))
          .toList();
      _currentJob!.missingSkills = _currentJob!.requiredSkills
          .where((r) => !profile.skills.any(
            (s) => r.toLowerCase().contains(s.toLowerCase()) ||
            s.toLowerCase().contains(r.toLowerCase()),
      ))
          .toList();

      final resume = await _resumeService.generateTargetedResume(
        profile: profile,
        job: _currentJob!,
      );
      _currentJob!.generatedResume = resume;
      await _jobBox.save(_currentJob!);

      // Update in list
      final idx = _applications.indexWhere((a) => a.id == _currentJob!.id);
      if (idx != -1) _applications[idx] = _currentJob!;

      _setStatus(JobStatus.done, 'Resume updated!');
    } catch (e) {
      _error = _friendlyError(e.toString());
      _setStatus(JobStatus.error, 'Failed');
    }
  }

  Future<void> updateStatus(String jobId, String status) async {
    await _jobBox.updateStatus(jobId, status);
    final idx = _applications.indexWhere((a) => a.id == jobId);
    if (idx != -1) {
      _applications[idx].status = status;
      notifyListeners();
    }
  }

  Future<void> deleteApplication(String id) async {
    await _jobBox.delete(id);
    _applications.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void setCurrentJob(JobApplication job) {
    _currentJob = job;
    notifyListeners();
  }

  void reset() {
    _status = JobStatus.idle;
    _currentJob = null;
    _error = null;
    _statusLabel = '';
    _improvementPlan = '';
    notifyListeners();
  }

  void _setStatus(JobStatus s, String label) {
    _status = s;
    _statusLabel = label;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('AUTH_ERROR')) return '❌ API key error. Check your .env file.';
    if (raw.contains('RATE_LIMIT')) return '⏱ Too many requests. Wait 1 minute.';
    if (raw.contains('TIMEOUT')) return '⏰ Request timed out. Try again.';
    if (raw.contains('NETWORK_ERROR')) return '🌐 No internet connection.';
    return '❌ $raw';
  }
}