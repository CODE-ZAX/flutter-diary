import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerApiService {
  static Future<Map<String, String>> fetchPrayerTimes(
      double lat, double lng) async {
    final url = Uri.parse(
        'http://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=2');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, String>.from(data['data']['timings']);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
