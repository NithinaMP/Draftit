import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'lecture_model.g.dart';

@HiveType(typeId: 0)
class LectureModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String rawTranscript;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final List<String> keyPoints;

  @HiveField(5)
  final List<String> extractedSkills;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  bool skillsMastered; // Phase 2 will use this

  LectureModel({
    required this.id,
    required this.title,
    required this.rawTranscript,
    required this.summary,
    required this.keyPoints,
    required this.extractedSkills,
    required this.createdAt,
    this.skillsMastered = false,
  });

  // ── Firestore serialization ────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'title': title,
    'raw_transcript': rawTranscript,
    'summary': summary,
    'key_points': keyPoints,
    'extracted_skills': extractedSkills,
    'created_at': Timestamp.fromDate(createdAt),
    'skills_mastered': skillsMastered,
  };

  factory LectureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LectureModel(
      id: data['id'] as String,
      title: data['title'] as String,
      rawTranscript: data['raw_transcript'] as String,
      summary: data['summary'] as String,
      keyPoints: List<String>.from(data['key_points'] ?? []),
      extractedSkills: List<String>.from(data['extracted_skills'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      skillsMastered: data['skills_mastered'] ?? false,
    );
  }

  LectureModel copyWith({bool? skillsMastered}) => LectureModel(
    id: id,
    title: title,
    rawTranscript: rawTranscript,
    summary: summary,
    keyPoints: keyPoints,
    extractedSkills: extractedSkills,
    createdAt: createdAt,
    skillsMastered: skillsMastered ?? this.skillsMastered,
  );
}