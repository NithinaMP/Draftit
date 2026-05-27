import 'package:hive_flutter/hive_flutter.dart';

part 'syllabus_model.g.dart';

@HiveType(typeId: 2)
class SyllabusUnit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String unitNumber; // e.g. "Unit 3"

  @HiveField(2)
  String unitTitle; // e.g. "Cardiovascular Pharmacology"

  @HiveField(3)
  List<String> sections; // sub-topics within the unit

  @HiveField(4)
  List<String> coveredSections; // sections covered by recorded lectures

  @HiveField(5)
  final DateTime addedAt;

  SyllabusUnit({
    required this.id,
    required this.unitNumber,
    required this.unitTitle,
    required this.sections,
    required this.coveredSections,
    required this.addedAt,
  });

  double get progressPercent {
    if (sections.isEmpty) return 0;
    return (coveredSections.length / sections.length).clamp(0.0, 1.0);
  }

  bool get isComplete => progressPercent >= 1.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'unit_number': unitNumber,
    'unit_title': unitTitle,
    'sections': sections,
    'covered_sections': coveredSections,
    'added_at': addedAt.toIso8601String(),
  };

  factory SyllabusUnit.fromMap(Map<String, dynamic> m) => SyllabusUnit(
    id: m['id'],
    unitNumber: m['unit_number'],
    unitTitle: m['unit_title'],
    sections: List<String>.from(m['sections'] ?? []),
    coveredSections: List<String>.from(m['covered_sections'] ?? []),
    addedAt: DateTime.parse(m['added_at']),
  );
}