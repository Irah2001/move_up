import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_up/constants/api_config.dart';

class AIService {
  static final String baseUrl = ApiConfig.baseUrl;

  static Future<String> chat({required String message, required String context}) async {
    final resp = await http.post(Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'context': context}));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['response'] ?? '';
    }
    throw Exception('Erreur AI chat: ${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> generateTraining(Map<String, dynamic> params) async {
    final resp = await http.post(Uri.parse('$baseUrl/ai/generate-training'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(params));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur generateTraining: ${resp.statusCode} ${resp.body}');
  }

  static Future<Map<String, dynamic>> generateNutrition(Map<String, dynamic> params) async {
    final resp = await http.post(Uri.parse('$baseUrl/ai/generate-nutrition'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(params));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur generateNutrition: ${resp.statusCode} ${resp.body}');
  }
}
