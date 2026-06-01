import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/syllabus_model.dart';

class HiveSyllabusBox {
  static const _boxName = 'syllabus_box';
  String get _prefix => 'sy_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}_';
  Box<SyllabusUnit>? _box;

  Future<Box<SyllabusUnit>> get box async {
    _box ??= await Hive.openBox<SyllabusUnit>(_boxName);
    return _box!;
  }

  Future<void> saveUnit(SyllabusUnit unit) async {
    final b = await box;
    await b.put('$_prefix${unit.id}', unit);
  }

  Future<List<SyllabusUnit>> getAllUnits() async {
    final b = await box;
    return b.keys
        .where((k) => k.toString().startsWith(_prefix))
        .map((k) => b.get(k)!)
        .toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
  }

  Future<void> updateCoveredSections(String unitId, List<String> covered) async {
    final b = await box;
    final unit = b.get('$_prefix$unitId');
    if (unit != null) {
      unit.coveredSections = covered;
      await unit.save();
    }
  }

  Future<void> deleteUnit(String unitId) async {
    final b = await box;
    await b.delete('$_prefix$unitId');
  }

  Future<void> clearAll() async {
    final b = await box;
    final keys = b.keys.where((k) => k.toString().startsWith(_prefix)).toList();
    await b.deleteAll(keys);
  }

  Future<double> overallProgress() async {
    final units = await getAllUnits();
    if (units.isEmpty) return 0;
    return units.fold(0.0, (sum, u) => sum + u.progressPercent) / units.length;
  }

  void reset() => _box = null;
}