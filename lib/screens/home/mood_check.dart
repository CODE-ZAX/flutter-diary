import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/mood_controller.dart';

class MoodCheckerPage extends StatelessWidget {
  final MoodController moodController = Get.put(MoodController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Checker")),
      body: Center(
        child: Obx(() {
          if (moodController.loading.value) {
            return CircularProgressIndicator();
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Mood:",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                moodController.currentMood.value.toUpperCase(),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  moodController.analyzeUserMood();
                },
                child: Text("Analyze Now"),
              ),
            ],
          );
        }),
      ),
    );
  }
}
