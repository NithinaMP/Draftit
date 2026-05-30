import 'package:hive_flutter/hive_flutter.dart';
import '../models/master_profile_model.dart';

class HiveProfileBox {
  static const _boxName = 'master_profile_box';
  static const _key = 'profile';
  Box<MasterProfile>? _box;

  Future<Box<MasterProfile>> get box async {
    _box ??= await Hive.openBox<MasterProfile>(_boxName);
    return _box!;
  }

  Future<MasterProfile> getOrCreate() async {
    final b = await box;
    return b.get(_key) ?? MasterProfile();
  }

  Future<void> save(MasterProfile profile) async {
    final b = await box;
    await b.put(_key, profile);
  }

  Future<bool> exists() async {
    final b = await box;
    final p = b.get(_key);
    return p != null && p.isComplete;
  }
}