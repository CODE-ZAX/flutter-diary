// models/user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  Location location;
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
      location: map['location'] != null
          ? Location.fromJson(map['location'])
          : Location(0.0, 0.0, ''), // fallback if location is missing
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
      'location': location.toJson(),
    };
  }
}

class Location {
  final String location;
  final double lat;
  final double lng;

  Location(this.lat, this.lng, this.location);

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      (json['lat'] ?? 0.0).toDouble(),
      (json['lng'] ?? 0.0).toDouble(),
      json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'lat': lat,
      'lng': lng,
    };
  }
}
