// models/user_model.dart
class UserModel {
  final String uid;
  final String fullName;
  final String location;
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
    required this.fullName,
    required this.location,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      prayerCount: Map<String, int>.from(map['prayerCount'] ?? {}),
      diaryPageIds: List<String>.from(map['diaryPageIds'] ?? []),
      mood: map['mood'] ?? 'neutral',
      fullName: map['fullName'] ?? '',
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'prayerCount': prayerCount,
      'diaryPageIds': diaryPageIds,
      'mood': mood,
      'fullName': fullName,
      'location': location,
    };
  }
}
