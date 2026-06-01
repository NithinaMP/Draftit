import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/job_application_model.dart';

class HiveJobBox {
  static const _boxName = 'job_applications_box';
  String get _prefix => 'job_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}_';
  Box<JobApplication>? _box;

  Future<Box<JobApplication>> get box async {
    _box ??= await Hive.openBox<JobApplication>(_boxName);
    return _box!;
  }

  Future<void> save(JobApplication app) async {
    final b = await box;
    await b.put('$_prefix${app.id}', app);
  }

  Future<List<JobApplication>> getAll() async {
    final b = await box;
    return b.keys
        .where((k) => k.toString().startsWith(_prefix))
        .map((k) => b.get(k)!)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<JobApplication?> get(String id) async {
    final b = await box;
    return b.get('$_prefix$id');
  }

  Future<void> updateStatus(String id, String status) async {
    final b = await box;
    final app = b.get('$_prefix$id');
    if (app != null) {
      app.status = status;
      await app.save();
    }
  }

  Future<void> delete(String id) async {
    final b = await box;
    await b.delete('$_prefix$id');
  }

  void reset() => _box = null;
}