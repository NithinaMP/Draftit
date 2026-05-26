import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/lecture_model.dart';
import '../../../../core/constants/app_constants.dart';

class LectureRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _lecturesRef =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .collection(AppConstants.lecturesCollection);

  Box<LectureModel>? _box;

  Future<Box<LectureModel>> get _hiveBox async {
    _box ??= await Hive.openBox<LectureModel>(AppConstants.lecturesBoxName);
    return _box!;
  }

  /// Save lecture to both Firestore and Hive cache
  Future<void> saveLecture(LectureModel lecture) async {
    await _lecturesRef.doc(lecture.id).set(lecture.toFirestore());
    final box = await _hiveBox;
    await box.put(lecture.id, lecture);
  }

  /// Stream all lectures — real-time from Firestore
  Stream<List<LectureModel>> watchLectures() {
    return _lecturesRef
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => LectureModel.fromFirestore(doc)).toList());
  }

  /// Get single lecture — Hive first, Firestore fallback
  Future<LectureModel?> getLecture(String id) async {
    final box = await _hiveBox;
    final cached = box.get(id);
    if (cached != null) return cached;

    final doc = await _lecturesRef.doc(id).get();
    if (!doc.exists) return null;

    final lecture = LectureModel.fromFirestore(doc);
    await box.put(id, lecture);
    return lecture;
  }

  /// Delete lecture from both Firestore and Hive
  Future<void> deleteLecture(String id) async {
    await _lecturesRef.doc(id).delete();
    final box = await _hiveBox;
    await box.delete(id);
  }
}