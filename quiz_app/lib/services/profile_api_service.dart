import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileData {
  final String nama;
  final String email;
  final String npm;
  final String tempatTglLahir;
  final String alamat;
  final String jenisKelamin;
  final int totalSubmit;
  final double rataRataNilai;

  ProfileData({
    required this.nama,
    required this.email,
    required this.npm,
    required this.tempatTglLahir,
    required this.alamat,
    required this.jenisKelamin,
    required this.totalSubmit,
    required this.rataRataNilai,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Penanganan struktur data yang mungkin bersarang (nested)
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      final user = json['user'] as Map<String, dynamic>;
      final quizStats = json['quiz_statistics'] as Map<String, dynamic>?;

      return ProfileData(
        nama: user['name'] ?? '',
        email: user['email'] ?? '',
        npm: user['npm'] ?? '',
        tempatTglLahir:
            '${user['birth_place'] ?? ''}, ${user['birth_date'] ?? ''}',
        alamat: user['address'] ?? '',
        jenisKelamin: user['gender'] ?? '',
        totalSubmit: quizStats?['total_submissions'] ?? 0,
        rataRataNilai: quizStats?['average_score'] != null
            ? (quizStats!['average_score'] as num).toDouble()
            : 0.0,
      );
    }

    // Fallback untuk struktur flat (jika API berubah)
    return ProfileData(
      nama: json['name'] ?? '',
      email: json['email'] ?? '',
      npm: json['npm'] ?? '',
      tempatTglLahir: json['birth_place_date'] ?? '',
      alamat: json['address'] ?? '',
      jenisKelamin: json['gender'] ?? '',
      totalSubmit: json['total_quiz'] ?? 0,
      rataRataNilai: json['average_score'] != null
          ? (json['average_score'] as num).toDouble()
          : 0.0,
    );
  }
}

class ProfileApiService {
  static const String profileUrl =
      'https://api-post.banjarmasinkota.xyz/api/profile';
  static const String apiKey = 'API_vSZqYsBCBXUhuNEuMuiED5tBj4WhGC5I';

  Future<ProfileData> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            return ProfileData.fromJson(responseData['data']);
          } else if (responseData.containsKey('nama') ||
              responseData.containsKey('user')) {
            return ProfileData.fromJson(responseData);
          }
        }
        throw Exception('Failed to fetch profile: Invalid data format');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }
}
