import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/models/prayer_model.dart';
import 'package:everyday_chronicles/screens/home/diary_newpage.dart';
import 'package:everyday_chronicles/screens/home/mood_check.dart';
import 'package:everyday_chronicles/screens/home/prayer_screen.dart';
import 'package:everyday_chronicles/screens/home/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    Get.put(DiaryController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Everyday Chronicles'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Diary'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Namaz'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.mood),
              title: Text('Mood Checker'),
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                _tabController.animateTo(3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Obx(() {
            final pages = DiaryController.instance.userDiaryPages;
            return ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return ListTile(
                  title: Text(page.title),
                  subtitle: Text(page.lastEdited.toString()),
                  onTap: () =>
                      Get.to(() => DiaryEditorScreen(existingPage: page)),
                );
              },
            );
          }),
        ),
      ],
    ));
  }
}
