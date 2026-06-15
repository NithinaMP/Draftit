
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/lecture_model.dart';
import '../../../../core/constants/app_constants.dart';

class LectureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Box<LectureModel>? _box;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _lecturesRef {
    if (_uid.isEmpty) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(_uid)
        .collection(AppConstants.lecturesCollection);
  }

  // Future<void> initialize() async {
  //   if (!Hive.isAdapterRegistered(AppConstants.lectureTypeId)) {
  //     Hive.registerAdapter(LectureModelAdapter());
  //   }
  //   _box ??= await Hive.openBox<LectureModel>(AppConstants.lecturesBoxName);
  // }
  // ==================== THIS IS THE initialize() METHOD ====================
  Future<void> initialize() async {
    // Register Hive Adapter (VERY IMPORTANT)
    if (!Hive.isAdapterRegistered(AppConstants.lectureTypeId)) {
      Hive.registerAdapter(LectureModelAdapter());
    }

    // Open the Hive box
    _box ??= await Hive.openBox<LectureModel>(AppConstants.lecturesBoxName);
  }

  Future<void> saveLecture(LectureModel lecture) async {
    await initialize();
    await _lecturesRef.doc(lecture.id).set(lecture.toFirestore());
    await _box!.put(lecture.id, lecture);
  }


  Stream<List<LectureModel>> watchLectures() {
    if (_uid.isEmpty) return Stream.value([]);

    return _lecturesRef
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => LectureModel.fromFirestore(doc)).toList());
  }

  Future<LectureModel?> getLecture(String id) async {
    await initialize();

    final cached = _box!.get(id);
    if (cached != null) return cached;

    final doc = await _lecturesRef.doc(id).get();
    if (!doc.exists) return null;

    final lecture = LectureModel.fromFirestore(doc);
    await _box!.put(id, lecture);
    return lecture;
  }

  Future<void> deleteLecture(String id) async {
    await initialize();
    await _lecturesRef.doc(id).delete();
    await _box!.delete(id);
  }
}