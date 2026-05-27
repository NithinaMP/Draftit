import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/local/hive_syllabus_box.dart';
import '../data/models/syllabus_model.dart';
import '../data/services/exam_ai_service.dart';
import '../data/services/pdf_text_extractor.dart';
import '../../1_voice_to_notes/data/models/lecture_model.dart';

enum SyllabusStatus { idle, loading, importing, aligning, done, error }

class SyllabusProvider extends ChangeNotifier {
  final HiveSyllabusBox _box = HiveSyllabusBox();
  final ExamAiService _examService = ExamAiService();
  final PdfTextExtractor _pdfExtractor = PdfTextExtractor();

  SyllabusStatus _status = SyllabusStatus.idle;
  List<SyllabusUnit> _units = [];
  String? _error;
  double _overallProgress = 0;

  // Last alignment result
  String? _lastAlignmentNote;
  String? _lastMatchedUnitId;

  SyllabusStatus get status => _status;
  List<SyllabusUnit> get units => _units;
  String? get error => _error;
  double get overallProgress => _overallProgress;
  String? get lastAlignmentNote => _lastAlignmentNote;
  String? get lastMatchedUnitId => _lastMatchedUnitId;
  bool get hasUnits => _units.isNotEmpty;
  bool get isLoading => _status == SyllabusStatus.loading ||
      _status == SyllabusStatus.importing ||
      _status == SyllabusStatus.aligning;

  /// Load all units from Hive on startup
  Future<void> loadUnits() async {
    _status = SyllabusStatus.loading;
    notifyListeners();
    try {
      _units = await _box.getAllUnits();
      _overallProgress = await _box.overallProgress();
      _status = SyllabusStatus.done;
    } catch (e) {
      _error = 'Failed to load syllabus';
      _status = SyllabusStatus.error;
    }
    notifyListeners();
  }

  /// Import syllabus from a PDF file (local only — no upload)
  Future<void> importFromPdf(String filePath) async {
    _status = SyllabusStatus.importing;
    _error = null;
    notifyListeners();

    try {
      final text = await _pdfExtractor.extractText(filePath);
      if (text.isEmpty) {
        throw Exception('Could not extract text from this PDF. '
            'Please type your syllabus manually.');
      }
      await _parseAndSaveSyllabusText(text);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = SyllabusStatus.error;
      notifyListeners();
    }
  }

  /// Import syllabus from manually typed text
  Future<void> importFromText(String rawText) async {
    _status = SyllabusStatus.importing;
    _error = null;
    notifyListeners();
    await _parseAndSaveSyllabusText(rawText);
  }

  Future<void> _parseAndSaveSyllabusText(String text) async {
    try {
      // Use Groq to parse the syllabus into structured units
      // (We handle this locally with a simple heuristic first, then AI if needed)
      final units = _heuristicParse(text);
      await _box.clearAll();
      for (final u in units) {
        await _box.saveUnit(u);
      }
      _units = units;
      _overallProgress = 0;
      _status = SyllabusStatus.done;
    } catch (e) {
      _error = 'Failed to parse syllabus: $e';
      _status = SyllabusStatus.error;
    }
    notifyListeners();
  }

  /// Add a unit manually (when user types it in)
  Future<void> addUnitManually({
    required String unitNumber,
    required String unitTitle,
    required List<String> sections,
  }) async {
    const uuid = Uuid();
    final unit = SyllabusUnit(
      id: uuid.v4(),
      unitNumber: unitNumber,
      unitTitle: unitTitle,
      sections: sections,
      coveredSections: [],
      addedAt: DateTime.now(),
    );
    await _box.saveUnit(unit);
    _units.add(unit);
    _overallProgress = await _box.overallProgress();
    notifyListeners();
  }

  /// Align a lecture to the syllabus and update progress
  Future<void> alignLecture(LectureModel lecture) async {
    if (_units.isEmpty) return;

    _status = SyllabusStatus.aligning;
    _error = null;
    notifyListeners();

    try {
      final result = await _examService.alignLectureToSyllabus(
        lectureTitle: lecture.title,
        summary: lecture.summary,
        extractedSkills: lecture.extractedSkills,
        syllabusUnits: _units,
      );

      final unitId = result['unit_id'] as String?;
      final matchedSections = List<String>.from(result['matched_sections'] ?? []);
      _lastAlignmentNote = result['coverage_note'] as String? ?? '';
      _lastMatchedUnitId = unitId;

      if (unitId != null && matchedSections.isNotEmpty) {
        final unit = _units.firstWhere(
              (u) => u.id == unitId,
          orElse: () => _units.first,
        );
        // Merge new covered sections
        final merged = {...unit.coveredSections, ...matchedSections}.toList();
        await _box.updateCoveredSections(unitId, merged);
        unit.coveredSections = merged;
      }

      _overallProgress = await _box.overallProgress();
      _status = SyllabusStatus.done;
    } catch (e) {
      debugPrint('❌ Alignment error: $e');
      _status = SyllabusStatus.done; // Non-fatal — just skip alignment
    }
    notifyListeners();
  }

  Future<void> deleteUnit(String unitId) async {
    await _box.deleteUnit(unitId);
    _units.removeWhere((u) => u.id == unitId);
    _overallProgress = await _box.overallProgress();
    notifyListeners();
  }

  /// Simple heuristic parser for common syllabus formats
  List<SyllabusUnit> _heuristicParse(String text) {
    const uuid = Uuid();
    final units = <SyllabusUnit>[];
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    SyllabusUnit? current;
    int unitIndex = 1;

    for (final line in lines) {
      // Detect unit headers: "Unit 1", "UNIT I", "Module 1", etc.
      final unitMatch = RegExp(
        r'^(unit|module|chapter|section)\s*[:\-]?\s*(\d+|[ivxlIVXL]+)\s*[:\-]?\s*(.*)',
        caseSensitive: false,
      ).firstMatch(line);

      if (unitMatch != null) {
        if (current != null) units.add(current);
        final title = unitMatch.group(3)?.trim() ?? 'Unit $unitIndex';
        current = SyllabusUnit(
          id: uuid.v4(),
          unitNumber: 'Unit $unitIndex',
          unitTitle: title.isEmpty ? 'Unit $unitIndex' : title,
          sections: [],
          coveredSections: [],
          addedAt: DateTime.now(),
        );
        unitIndex++;
      } else if (current != null && line.length > 5 && line.length < 150) {
        // Lines under a unit header are sections
        current.sections.add(line);
      }
    }

    if (current != null) units.add(current);

    // If no units detected, create one big unit with all lines as sections
    if (units.isEmpty && lines.isNotEmpty) {
      units.add(SyllabusUnit(
        id: uuid.v4(),
        unitNumber: 'Unit 1',
        unitTitle: 'Full Syllabus',
        sections: lines.take(30).toList(),
        coveredSections: [],
        addedAt: DateTime.now(),
      ));
    }

    return units;
  }
}