// controllers/diary_controller.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/diary_model.dart';
import 'auth_controller.dart';

class DiaryController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchDiaryPages();
  }

  static DiaryController instance = Get.put(DiaryController());

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<DiaryModel> userDiaryPages = <DiaryModel>[].obs;

  Future<void> fetchDiaryPages() async {
    final uid = AuthController.instance.auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('diaryPages')
        .orderBy('createdAt', descending: true)
        .get();

    userDiaryPages.value = snapshot.docs.map((doc) {
      return DiaryModel.fromMap(doc.data());
    }).toList();
  }

  Future<void> addDiaryPage(DiaryModel page) async {
    final uid = AuthController.instance.auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('diaryPages')
          .doc(page.id)
          .set(page.toMap());
    } catch (err) {
      log("+++++++++++++++++++I AM HERE  2222+++++++++++++++${err.toString()}");
    }

    userDiaryPages.insert(0, page); // Add to top
  }

  Future<void> updateDiaryPage(DiaryModel page) async {
    final uid = AuthController.instance.auth.currentUser?.uid;
    if (uid == null) return;

    await firestore
        .collection('users')
        .doc(uid)
        .collection('diaryPages')
        .doc(page.id)
        .update(page.toMap());

    int index = userDiaryPages.indexWhere((p) => p.id == page.id);
    if (index != -1) {
      userDiaryPages[index] = page;
    }
  }
}
