import 'package:get/get.dart';
import 'auth_controller.dart';
import 'diary_controller.dart';
import '../services/mood_analyzer_service.dart';

class MoodController extends GetxController {
  var currentMood = 'neutral'.obs;
  var loading = false.obs;

  Future<void> analyzeUserMood() async {
    loading.value = true;
    try {
      await DiaryController.instance.fetchDiaryPages();
      final pages = DiaryController.instance.userDiaryPages;
      if (pages.isEmpty) {
        currentMood.value = 'neutral';
      } else {
        final allText = pages.map((p) => p.content).join("\n");
        final mood = await MoodAnalyzerService.analyzeMood(allText);
        currentMood.value = mood;

        // Update Firestore
        final user = AuthController.instance.currentUser.value;
        if (user != null) {
          await AuthController.instance.firestore
              .collection("users")
              .doc(user.uid)
              .update({'mood': mood});
        }
      }
    } catch (e) {
      Get.snackbar("Mood Analysis Failed", e.toString());
    } finally {
      loading.value = false;
    }
  }
}
