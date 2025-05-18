// models/diary_page_model.dart
class DiaryModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime lastEdited;
  final List<String> imageUrls;

  DiaryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastEdited,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
      'imageUrls': imageUrls,
    };
  }

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      lastEdited: DateTime.parse(map['lastEdited']),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
