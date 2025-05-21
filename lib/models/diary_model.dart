import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;
  final String title;
  final String content; // Stored as JSON
  final String markdownContent;
  final DateTime createdAt;
  final DateTime lastEdited;

  DiaryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.markdownContent,
    required this.createdAt,
    required this.lastEdited,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      markdownContent: map['markdownContent'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastEdited: (map['lastEdited'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'markdownContent': markdownContent,
      'createdAt': createdAt,
      'lastEdited': lastEdited,
    };
  }
}
