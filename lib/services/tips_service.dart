import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_up/constants/api_config.dart';

class TipsService {
  static Future<List<Map<String, String>>> getTrainingTips() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tips/training'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tips'] is List) {
          return List<Map<String, String>>.from(
            (data['tips'] as List).map((t) => {
              'id': t['id']?.toString() ?? '',
              'title': t['title']?.toString() ?? 'Conseil',
              'content': t['content']?.toString() ?? '',
              'category': t['category']?.toString() ?? 'général',
            }),
          );
        }
      }
    } catch (e) {
      print('Error fetching training tips: $e');
    }
    return [];
  }

  static Future<List<Map<String, String>>> getNutritionTips() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tips/nutrition'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tips'] is List) {
          return List<Map<String, String>>.from(
            (data['tips'] as List).map((t) => {
              'id': t['id']?.toString() ?? '',
              'title': t['title']?.toString() ?? 'Conseil',
              'content': t['content']?.toString() ?? '',
              'category': t['category']?.toString() ?? 'général',
            }),
          );
        }
      }
    } catch (e) {
      print('Error fetching nutrition tips: $e');
    }
    return [];
  }
}
