import 'dart:convert';
import 'package:http/http.dart' as http;

class MoodAnalyzerService {
  static Future<String> analyzeMood(String diaryContent) async {
    // Replace with your real endpoint or LLM integration
    final response = await http.post(
      Uri.parse('https://your-llm-api.com/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "input": diaryContent,
        "instruction":
            "Categorize the user's mood as 'happy', 'sad', 'angry', or 'neutral'.",
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['mood'] ?? 'neutral';
    } else {
      throw Exception('Mood analysis failed');
    }
  }
}
