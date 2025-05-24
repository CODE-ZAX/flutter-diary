import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/mood_controller.dart';

class MoodCheckerPage extends StatelessWidget {
  final MoodController moodController = Get.put(MoodController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Checker"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Obx(() {
          if (moodController.loading.value) {
            return Lottie.asset(
              'assets/animations/loading.json',
              width: 150,
              height: 150,
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                moodController.getMoodAnimation(),
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 12),
              Text(
                "Your Mood:",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.deepPurple.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                moodController.currentMood.value.toUpperCase(),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.mood),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  moodController.analyzeUserMood();
                },
                label: const Text(
                  "Analyze Now",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
