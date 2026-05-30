import 'package:hive_flutter/hive_flutter.dart';

part 'job_application_model.g.dart';

@HiveType(typeId: 6)
class JobApplication extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String companyName;

  @HiveField(2)
  String roleTitle;

  @HiveField(3)
  String jobDescription; // raw JD pasted by user

  @HiveField(4)
  List<String> requiredSkills; // AI-extracted from JD

  @HiveField(5)
  List<String> missingSkills; // skills in JD but not in student's profile

  @HiveField(6)
  List<String> matchedSkills; // skills in JD that student has

  @HiveField(7)
  int matchScore; // 0-100

  @HiveField(8)
  String companyTone; // 'startup' | 'corporate' | 'big4' | 'tech'

  @HiveField(9)
  String generatedResume; // the AI-tailored resume text

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  String status; // 'draft' | 'applied' | 'interview' | 'rejected' | 'offer'

  JobApplication({
    required this.id,
    required this.companyName,
    required this.roleTitle,
    required this.jobDescription,
    List<String>? requiredSkills,
    List<String>? missingSkills,
    List<String>? matchedSkills,
    this.matchScore = 0,
    this.companyTone = 'corporate',
    this.generatedResume = '',
    required this.createdAt,
    this.status = 'draft',
  })  : requiredSkills = requiredSkills ?? [],
        missingSkills = missingSkills ?? [],
        matchedSkills = matchedSkills ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'company_name': companyName,
    'role_title': roleTitle,
    'job_description': jobDescription,
    'required_skills': requiredSkills,
    'missing_skills': missingSkills,
    'matched_skills': matchedSkills,
    'match_score': matchScore,
    'company_tone': companyTone,
    'generated_resume': generatedResume,
    'created_at': createdAt.toIso8601String(),
    'status': status,
  };
}