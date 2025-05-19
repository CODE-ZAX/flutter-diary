class PrayerTime {
  final String name;
  final DateTime time;

  PrayerTime({required this.name, required this.time});

  factory PrayerTime.fromMap(Map<String, dynamic> map) {
    return PrayerTime(
      name: map['name'] ?? '',
      time: DateTime.parse(map['time'] ?? DateTime.now().toString()),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time.toIso8601String(),
    };
  }
}
