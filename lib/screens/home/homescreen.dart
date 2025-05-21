import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/screens/home/diary_newpage.dart';
import 'package:everyday_chronicles/screens/home/mood_check.dart';
import 'package:everyday_chronicles/screens/home/prayer_screen.dart';
import 'package:everyday_chronicles/screens/home/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:everyday_chronicles/models/diary_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final check = 0.obs;

    final theme = Theme.of(context);
    Get.put(DiaryController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text([
            'MY DIARY',
            'NAMAZ TIMER',
            'MOOD CHECKER',
            'SETTINGS'
          ][check.value]),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DiaryHomeScreen(),
          NamazPage(),
          MoodCheckerPage(),
          SettingsPage(),
        ],
      ),
      floatingActionButton: Obx(() => check.value == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => DiaryEditorScreen());
              },
              child: Icon(Icons.add),
            )
          : Container()),
      bottomNavigationBar: Material(
        color: Theme.of(context).primaryColor,
        child: TabBar(
          controller: _tabController,
          onTap: (value) {
            check.value = value;
          },
          tabs: [
            Tab(icon: Icon(Icons.book), text: 'Diary'),
            Tab(icon: Icon(Icons.access_time), text: 'Namaz'),
            Tab(icon: Icon(Icons.mood), text: 'Mood Checker'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
    );
  }
}

// screens/diary/diary_home_screen.dart

class DiaryHomeScreen extends StatelessWidget {
  const DiaryHomeScreen({super.key});

  String _getContentPreview(String contentJson) {
    try {
      final List<dynamic> deltaList = jsonDecode(contentJson);
      return deltaList
          .where((op) =>
              op['insert'] != null && op['insert'].toString().trim().isNotEmpty)
          .take(3)
          .map((op) => op['insert'].toString().trim())
          .join(" ")
          .replaceAll('\n', ' ')
          .trim();
    } catch (e) {
      return '';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy – h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final diaryController = DiaryController.instance;

    return Scaffold(
      // warm creamy background
      body: Obx(() {
        final pages = diaryController.userDiaryPages;

        if (pages.isEmpty) {
          return const Center(
            child: Text(
              "No diary pages yet.\nStart writing your first page!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final DiaryModel page = pages[index];
            final preview = _getContentPreview(page.content);

            return GestureDetector(
              onTap: () => Get.to(() => DiaryEditorScreen(existingPage: page)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preview.isNotEmpty ? preview : "No content yet...",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Edited on ${_formatDate(page.lastEdited)}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
