import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://20.174.8.175:5000/chat";

  static const String loginApi = 'http://localhost:5000/get-user-agents';

  static Future<String> sendMessage1({
    required String agentId,
    required String text,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'agentId': agentId,
          'message': text,
        }),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        return (json['reply'] ?? json['message'] ?? 'No reply') as String;
      } else {
        return 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      return 'Network error';
    }
  }

  static Future<String> loginWithPhone({
    required String phone,
  }) async {
    try{
    final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
        }),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        print( json['reply'] ?? json['message'] ?? 'No reply');
        return (json['reply'] ?? json['message'] ?? 'No reply') as String;
      } else {
        return 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      return 'Network error';
    }
    }


  Future<String> sendMessage(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Azure AI Error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['reply'] as String;
  }
}