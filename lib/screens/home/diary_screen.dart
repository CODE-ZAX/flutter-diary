import 'dart:convert';

import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/models/diary_model.dart';
import 'package:everyday_chronicles/screens/home/diary_newpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
      // warm creamy background\
      appBar: AppBar(
        title: const Text("My Diary"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => DiaryEditorScreen());
        },
        child: const Icon(Icons.add),
      ),
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
