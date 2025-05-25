import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/controllers/exercises_controller.dart';
import 'package:everyday_chronicles/controllers/prayer_controller.dart';
import 'package:everyday_chronicles/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final exercisesController = Get.put(ExercisesController());
  final authController = Get.find<AuthController>();
  final namazController = Get.put(NamazController());
  final settingController = Get.put(SettingsController());
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DiaryController()).fetchDiaryPages();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildCarousel(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final name =
                        authController.currentUser.value?.fullName ?? "User";
                    return Text(
                      "Welcome, $name 👋",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text(
                    "Here are some quick tips to get started:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _tipCard("✍️ Start writing in your diary to track your day."),
                  _tipCard("🙏 Log your prayers and stay consistent."),
                  _tipCard("🧘‍♂️ Try out a short workout from the carousel."),
                  const SizedBox(height: 20),
                  const Text(
                    "Today's Prayers",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (namazController.prayerTimes.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: namazController.prayerTimes.map((prayer) {
                        final isChecked =
                            namazController.checkedPrayers[prayer.name] ??
                                false;
                        return _prayerStatusCard(prayer.name, isChecked);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Obx(() =>
                Text(authController.currentUser.value?.fullName ?? 'User')),
            accountEmail:
                Obx(() => Text(authController.currentUser.value?.email ?? '')),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            decoration: const BoxDecoration(color: Colors.deepPurple),
          ),
          _drawerTile(Icons.book, 'Diary', () => Get.toNamed('/diary')),
          _drawerTile(
              Icons.access_time, 'Namaz Timer', () => Get.toNamed('/namaz')),
          _drawerTile(
              Icons.timer, 'Stopwatch', () => Get.toNamed('/stopwatch')),
          _drawerTile(
              Icons.extension, 'Exercises', () => Get.toNamed('/exercises')),
          _drawerTile(Icons.cloud_sync_rounded, 'Weather & Steps',
              () => Get.toNamed('/weathersteps')),
          _drawerTile(Icons.mood, 'Mood Checker', () => Get.toNamed('/mood')),
          _drawerTile(
              Icons.settings, 'Settings', () => Get.toNamed('/settings')),
          const Divider(),
          _drawerTile(Icons.logout, 'Sign Out', () {
            Get.find<DiaryController>().userDiaryPages.clear();
            authController.signOut();
          }),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _tipCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _prayerStatusCard(String name, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? Colors.green : Colors.redAccent,
          width: 1.2,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isChecked ? Icons.check : Icons.close,
          color: isChecked ? Colors.green : Colors.red,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          isChecked ? "Offered" : "Pending",
          style: TextStyle(
            color: isChecked ? Colors.green : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Obx(() {
      final videos = exercisesController.videoUrls;

      return Container(
        height: 160,
        padding: const EdgeInsets.only(left: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final url = videos[index];
            final videoId = YoutubePlayer.convertUrlToId(url);
            final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

            return Container(
              margin: const EdgeInsets.only(right: 12),
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: const Text(
                  'Exercise',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
