// models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final Map<String, int> prayerCount;
  final List<String> diaryPageIds;
  final String mood;

  UserModel({
    required this.uid,
    required this.email,
    required this.prayerCount,
    required this.diaryPageIds,
    required this.mood,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      prayerCount: Map<String, int>.from(map['prayerCount'] ?? {}),
      diaryPageIds: List<String>.from(map['diaryPageIds'] ?? []),
      mood: map['mood'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'prayerCount': prayerCount,
      'diaryPageIds': diaryPageIds,
      'mood': mood,
    };
  }
}
