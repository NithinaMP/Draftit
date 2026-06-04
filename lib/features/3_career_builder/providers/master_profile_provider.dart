import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/local/hive_profile_box.dart';
import '../data/models/master_profile_model.dart';
import '../data/services/resume_builder_service.dart';

enum ProfileStatus { idle, loading, saving, translating, done, error }

class MasterProfileProvider extends ChangeNotifier {
  final HiveProfileBox _box = HiveProfileBox();
  final ResumeBuilderService _resumeService = ResumeBuilderService();

  ProfileStatus _status = ProfileStatus.idle;
  MasterProfile _profile = MasterProfile();
  String? _error;
  String? _translatingId; // which experience is being translated

  ProfileStatus get status => _status;
  MasterProfile get profile => _profile;
  String? get error => _error;
  String? get translatingId => _translatingId;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _status == ProfileStatus.saving;
  bool get isComplete => _profile.isComplete;

  void clearForNewUser() {
    _profile = MasterProfile();
    _status = ProfileStatus.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> load() async {
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      _profile = await _box.getOrCreate();
      _status = ProfileStatus.done;
    } catch (e) {
      _error = 'Failed to load profile';
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  Future<void> saveBasicInfo({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    String? linkedIn,
    String? github,
    String? portfolio,
  }) async {
    _profile.fullName = fullName;
    _profile.email = email;
    _profile.phone = phone;
    _profile.location = location;
    _profile.linkedIn = linkedIn;
    _profile.github = github;
    _profile.portfolio = portfolio;
    await _persist();
  }

  Future<void> addEducation(EducationEntry edu) async {
    _profile.education.add(edu);
    await _persist();
  }

  Future<void> removeEducation(int index) async {
    _profile.education.removeAt(index);
    await _persist();
  }

  Future<void> addSkill(String skill) async {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !_profile.skills.contains(trimmed)) {
      _profile.skills.add(trimmed);
      await _persist();
    }
  }

  Future<void> removeSkill(String skill) async {
    _profile.skills.remove(skill);
    await _persist();
  }

  /// Sync skills extracted from Phase 1 lecture notes
  Future<void> syncLectureSkills(List<String> lectureSkills) async {
    var added = false;
    for (final skill in lectureSkills) {
      if (!_profile.skills.contains(skill)) {
        _profile.skills.add(skill);
        added = true;
      }
    }
    if (added) await _persist();
  }

  Future<void> addExperience(ExperienceEntry exp) async {
    _profile.experiences.add(exp);
    await _persist();
  }

  Future<void> removeExperience(String id) async {
    _profile.experiences.removeWhere((e) => e.id == id);
    await _persist();
  }

  /// AI-translate a raw experience description into corporate bullets
  Future<void> translateExperience({
    required String experienceId,
    required String companyTone,
  }) async {
    final exp = _profile.experiences
        .firstWhere((e) => e.id == experienceId, orElse: () => throw Exception('Not found'));

    _translatingId = experienceId;
    _status = ProfileStatus.translating;
    notifyListeners();

    try {
      final professional = await _resumeService.translateExperience(
        rawDescription: exp.rawDescription,
        role: exp.title,
        companyTone: companyTone,
      );
      exp.professionalDescription = professional;
      await _persist();
      _translatingId = null;
      _status = ProfileStatus.done;
    } catch (e) {
      _error = 'Translation failed: $e';
      _translatingId = null;
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  // Future<void> addCertification(String cert) async {
  //   if (cert.trim().isNotEmpty) {
  //     _profile.certifications.add(cert.trim());
  //     await _persist();
  //   }
  // }

  Future<void> addCertification(CertificationEntry cert) async {
    _profile.certifications.add(cert);
    await _persist();
  }

  // Future<void> removeCertification(int index) async {
  //   _profile.certifications.removeAt(index);
  //   await _persist();
  // }
  Future<void> removeCertification(String id) async {
    _profile.certifications.removeWhere(
          (c) => c.id == id,
    );
    await _persist();
  }
  CertificationEntry buildCertification({
    required String name,
    required String organization,
    required String issueDate,
    String? expiryDate,
    String? credentialId,
  }) {
    return CertificationEntry(
      id: const Uuid().v4(),
      name: name,
      organization: organization,
      issueDate: issueDate,
      expiryDate: expiryDate,
      credentialId: credentialId,
    );
  }

  Future<void> addSoftSkill(String skill) async {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !_profile.softSkills.contains(trimmed)) {
      _profile.softSkills.add(trimmed);
      await _persist();
    }
  }

  Future<void> removeSoftSkill(String skill) async {
    _profile.softSkills.remove(skill);
    await _persist();
  }

  Future<void> addLanguage(String lang) async {
    final trimmed = lang.trim();
    if (trimmed.isNotEmpty && !_profile.languages.contains(trimmed)) {
      _profile.languages.add(trimmed);
      await _persist();
    }
  }

  Future<void> removeLanguage(String lang) async {
    _profile.languages.remove(lang);
    await _persist();
  }

  ExperienceEntry buildExperience({
    required String title,
    required String organization,
    required String duration,
    required String rawDescription,
    required List<String> toolsUsed,
    required String type,
    String? proofLink,
  }) {
    return ExperienceEntry(
      id: const Uuid().v4(),
      title: title,
      organization: organization,
      duration: duration,
      rawDescription: rawDescription,
      toolsUsed: toolsUsed,
      type: type,
      proofLink: proofLink,
    );
  }

  Future<void> addProject(ProjectEntry project) async {
    _profile.projects.add(project);
    await _persist();
  }

  Future<void> removeProject(String id) async {
    _profile.projects.removeWhere((p) => p.id == id);
    await _persist();
  }

  ProjectEntry buildProject({
    required String title,
    required String description,
    required List<String> techStack,
    required String duration,
    String? githubLink,
    String? liveLink,
  }) {
    return ProjectEntry(
      id: const Uuid().v4(),
      title: title,
      description: description,
      techStack: techStack,
      duration: duration,
      githubLink: githubLink,
      liveLink: liveLink,
    );
  }

  Future<void> _persist() async {
    _status = ProfileStatus.saving;
    notifyListeners();
    await _box.save(_profile);
    _status = ProfileStatus.done;
    notifyListeners();
  }
}