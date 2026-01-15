import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/models/quiz_question.dart';

class QuestionApiService {
  static const String baseUrl =
      'https://api-post.banjarmasinkota.xyz/api/questions/random';
  static const String submitUrl =
      'https://api-post.banjarmasinkota.xyz/api/quiz/submit';
  static const String apiKey = 'API_vSZqYsBCBXUhuNEuMuiED5tBj4WhGC5I';

  Future<List<QuizQuestion>> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> questionsJson = data['data'];
          return questionsJson.map((questionJson) {
            final List<dynamic> optionsJson = questionJson['options'] as List;

            // Sort agar jawaban benar ada di indeks 0 (untuk pengecekan nanti)
            optionsJson.sort((a, b) {
              if (a['is_correct'] == true) return -1;
              if (b['is_correct'] == true) return 1;
              return 0;
            });

            final List<String> options = optionsJson
                .map((option) => option['option_text'] as String)
                .toList();

            return QuizQuestion(
              id: questionJson['id'] as int,
              text: questionJson['question_text'] as String,
              answers: options, // Sesuaikan dengan nama field di model
            );
          }).toList();
        } else {
          throw Exception(
            'Failed to load questions: API returned unsuccessful response',
          );
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<Map<String, dynamic>> submitAnswers(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(submitUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({'answers': answers}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to submit answers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit answers: $e');
    }
  }
}
