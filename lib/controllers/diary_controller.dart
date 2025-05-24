// controllers/diary_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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

  Future<String?> summarizeDiary(String content) async {
    if (content.trim().split(RegExp(r'\s+')).length <= 20) {
      return null; // not enough content
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.mistral.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer FqqFEmSXm7HMKAupUOXRvvpxIjlfdAot', // secure this
        },
        body: jsonEncode({
          "model": "mistral-medium",
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "Summarize the user's diary content into a single concise paragraph. Do not include mood judgment."
            },
            {
              "role": "user",
              "content": content,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["choices"][0]["message"]["content"]?.trim();
      } else {
        print("API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Mistral exception: $e");
      return null;
    }
  }
}
