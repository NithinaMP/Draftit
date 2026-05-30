import 'package:hive_flutter/hive_flutter.dart';

part 'master_profile_model.g.dart';

@HiveType(typeId: 3)
class MasterProfile extends HiveObject {
  @HiveField(0)
  String fullName;
  @HiveField(1)
  String email;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String location;
  @HiveField(4)
  String summary;
  @HiveField(5)
  List<EducationEntry> education;
  @HiveField(6)
  List<ExperienceEntry> experiences;
  @HiveField(7)
  List<String> skills; // technical skills
  @HiveField(8)
  List<String> certifications;
  @HiveField(9)
  List<String> languages;
  @HiveField(10)
  String? linkedIn;
  @HiveField(11)
  String? github;
  @HiveField(12)
  String? portfolio;
  @HiveField(13)
  List<String> softSkills; // NEW

  MasterProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.summary = '',
    List<EducationEntry>? education,
    List<ExperienceEntry>? experiences,
    List<String>? skills,
    List<String>? certifications,
    List<String>? languages,
    this.linkedIn,
    this.github,
    this.portfolio,
    List<String>? softSkills,
  })  : education = education ?? [],
        experiences = experiences ?? [],
        skills = skills ?? [],
        certifications = certifications ?? [],
        languages = languages ?? [],
        softSkills = softSkills ?? [];

  bool get isComplete =>
      fullName.isNotEmpty && email.isNotEmpty && skills.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'location': location,
    'summary': summary,
    'education': education.map((e) => e.toMap()).toList(),
    'experiences': experiences.map((e) => e.toMap()).toList(),
    'skills': skills,
    'certifications': certifications,
    'languages': languages,
    'linked_in': linkedIn,
    'github': github,
    'portfolio': portfolio,
    'soft_skills': softSkills,
  };
}

@HiveType(typeId: 4)
class EducationEntry extends HiveObject {
  @HiveField(0)
  String degree;
  @HiveField(1)
  String institution;
  @HiveField(2)
  String year;
  @HiveField(3)
  String? grade;

  EducationEntry({
    required this.degree,
    required this.institution,
    required this.year,
    this.grade,
  });

  Map<String, dynamic> toMap() => {
    'degree': degree,
    'institution': institution,
    'year': year,
    'grade': grade,
  };
}

@HiveType(typeId: 5)
class ExperienceEntry extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String organization;
  @HiveField(3)
  String duration;
  @HiveField(4)
  String rawDescription;
  @HiveField(5)
  String professionalDescription;
  @HiveField(6)
  List<String> toolsUsed;
  @HiveField(7)
  String type;
  @HiveField(8)
  String? proofLink;

  ExperienceEntry({
    required this.id,
    required this.title,
    required this.organization,
    required this.duration,
    required this.rawDescription,
    this.professionalDescription = '',
    List<String>? toolsUsed,
    this.type = 'project',
    this.proofLink,
  }) : toolsUsed = toolsUsed ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'organization': organization,
    'duration': duration,
    'raw_description': rawDescription,
    'professional_description': professionalDescription,
    'tools_used': toolsUsed,
    'type': type,
    'proof_link': proofLink,
  };
}