import 'package:hive_flutter/hive_flutter.dart';
import '../models/syllabus_model.dart';

class HiveSyllabusBox {
  static const _boxName = 'syllabus_box';
  Box<SyllabusUnit>? _box;

  Future<Box<SyllabusUnit>> get box async {
    _box ??= await Hive.openBox<SyllabusUnit>(_boxName);
    return _box!;
  }

  Future<void> saveUnit(SyllabusUnit unit) async {
    final b = await box;
    await b.put(unit.id, unit);
  }

  Future<List<SyllabusUnit>> getAllUnits() async {
    final b = await box;
    return b.values.toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
  }

  Future<void> updateCoveredSections(
      String unitId, List<String> coveredSections) async {
    final b = await box;
    final unit = b.get(unitId);
    if (unit != null) {
      unit.coveredSections = coveredSections;
      await unit.save();
    }
  }

  Future<void> deleteUnit(String unitId) async {
    final b = await box;
    await b.delete(unitId);
  }

  Future<void> clearAll() async {
    final b = await box;
    await b.clear();
  }

  Future<double> overallProgress() async {
    final units = await getAllUnits();
    if (units.isEmpty) return 0;
    final total = units.fold(0.0, (sum, u) => sum + u.progressPercent);
    return total / units.length;
  }
}