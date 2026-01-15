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
    print('Parsing ProfileData from: $json');

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
        rataRataNilai: quizStats?['average_score'] == null
            ? (quizStats!['average_score'] as num).toDouble()
            : 0.0,
      );
    }
    // Handle flat structure (fallback)
    return ProfileData(
      nama: json['nama'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      npm: json['npm'] ?? json['npm_id'] ?? json['student_id'] ?? '',
      tempatTglLahir:
          json['tempat_tg_lahir'] ??
          json['tempat_lahir'] ??
          json['birth_place_date'] ??
          '',
      alamat: json['alamat'] ?? json['address'] ?? '',
      jenisKelamin:
          json['jenis_kelamin'] ?? json['gender'] ?? json['sex'] ?? '',
      totalSubmit:
          json['total_submit'] ?? json['total_quiz'] ?? json['quiz_count'] ?? 0,
      rataRataNilai: json['rata_rata_nilai'] != null
          ? (json['rata_rata_nilai'] as num).toDouble()
          : json['average_score'] != null
          ? (json['average_score'] as num).toDouble()
          : 0.0,
    );
  }
}

// Windsurf: Refactor | Explain
class ProfileApiService {
  static const String profileUrl =
      'https://api-post.banjarmasinkota.xyz/api/profile';
  static const String apiKey = 'API_vSZqYsBCBXUhuNEuMuiED5tBj4WhGC5I';

  // Windsurf: Refactor | Explain | Generate Function Comment | X
  Future<ProfileData> fetchProfile() async {
    try {
      print('Fetching profile from: $profileUrl');

      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Parsed data: $responseData');

        // Try different response formats
        if (responseData is Map<String, dynamic>) {
          final Map<String, dynamic> data = responseData;

          // Format 1: {success: true, data: {...}}
          if (data['success'] == true && data['data'] != null) {
            print('Parsing with format 1: success + data');
            return ProfileData.fromJson(data['data']);
          }

          // Format 2: {success: false/missing, data: {...}}
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            print('Parsing with format 2: data without success check');
            return ProfileData.fromJson(data['data']);
          }

          // Format 3: Direct profile data without wrapper
          if (data.containsKey('nama') ||
              data.containsKey('email') ||
              data.containsKey('npm')) {
            print('Parsing with format 3: direct profile data');
            return ProfileData.fromJson(data);
          }

          throw Exception(
            'Failed to fetch profile: API returned unsuccessful response – ${data['message'] ?? 'Unknown error'}',
          );
        } else {
          throw Exception(
            'Failed to fetch profile: Unexpected response format',
          );
        }
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('API Error: $e');
    }
  }
}
