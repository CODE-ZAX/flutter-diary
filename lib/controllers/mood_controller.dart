import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../models/diary_model.dart';

class MoodController extends GetxController {
  RxBool loading = false.obs;
  final auth = AuthController.instance;
  RxString currentMood = 'Neutral'.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    super.onInit();
    currentMood.value =
        AuthController.instance.currentUser.value?.mood ?? 'Neutral';
  }

  Future<void> updateMood(String mood) async {
    final uid = auth.currentUser.value?.uid;
    if (uid == null) return;

    try {
      await firestore.collection("users").doc(uid).update({'mood': mood});

      await AuthController.instance.loadUser(uid);
      Get.snackbar("Success", "Mood updated.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> analyzeUserMood() async {
    loading.value = true;

    try {
      // Get current user ID
      final userId = AuthController.instance.currentUser.value?.uid;
      if (userId == null) throw Exception('User not logged in');

      final uid = AuthController.instance.auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diaryPages')
          .orderBy('createdAt', descending: true)
          .get();

      final List<DiaryModel> diaryEntries =
          snapshot.docs.map((doc) => DiaryModel.fromMap(doc.data())).toList();

      final combinedText =
          diaryEntries.map((entry) => entry.markdownContent).join('\n');
      final response = await http.post(
        Uri.parse('https://api.mistral.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer JZktT0kjsAAujG8kctik3gaQMSpFiBdw', // Replace with your actual API key
        },
        body: jsonEncode({
          "model": "mistral-medium",
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant that reads a user's diary and analyzes their overall mood. Respond with only one word: Happy, Sad, Angry or Neutral."
            },
            {"role": "user", "content": combinedText}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final mood = decoded['choices'][0]['message']['content'];

        currentMood.value = mood.trim();
        await updateMood(currentMood.value);
      } else {
        currentMood.value = 'Error';
      }
    } catch (e) {
      print('Mood analysis error: $e');
      currentMood.value = 'Error';
    } finally {
      loading.value = false;
    }
  }

  String getMoodAnimation() {
    switch (currentMood.value.toLowerCase()) {
      case 'happy':
        return 'assets/animations/happy.json';
      case 'sad':
        return 'assets/animations/sad.json';
      case 'angry':
        return 'assets/animations/angry.json';
      case 'anxious':
        return 'assets/animations/anxious.json';
      case 'excited':
        return 'assets/animations/excited.json';
      case 'neutral':
      default:
        return 'assets/animations/neutral.json';
    }
  }
}
