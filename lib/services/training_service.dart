import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_up/models/training_model.dart';
import 'package:move_up/constants/api_config.dart';

class TrainingService {
  static final String baseUrl = ApiConfig.baseUrl;
  
  // Récupérer toutes les catégories d'entraînement
  static Future<List<TrainingCategory>> getTrainingCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/categories'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((category) => TrainingCategory.fromJson(category))
            .toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer une catégorie spécifique
  static Future<TrainingCategory> getTrainingCategory(String categoryId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/categories/$categoryId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return TrainingCategory.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Catégorie non trouvée');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer tous les programmes d'entraînement
  static Future<List<TrainingProgram>> getTrainingPrograms() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/programs'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((program) => TrainingProgram.fromJson(program))
            .toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer les programmes d'une catégorie spécifique
  static Future<List<TrainingProgram>> getProgramsByCategory(
      String categoryId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/categories/$categoryId/programs'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((program) => TrainingProgram.fromJson(program))
            .toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer un programme spécifique
  static Future<TrainingProgram> getTrainingProgram(String programId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/programs/$programId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return TrainingProgram.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Programme non trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Créer un nouvel entraînement
  static Future<Map<String, dynamic>> createTraining({
    required String userId,
    required String programId,
    required int duration,
    required int caloriesBurned,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trainings/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'programId': programId,
          'duration': duration,
          'caloriesBurned': caloriesBurned,
          'completedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la création: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Sauvegarder un programme généré pour un utilisateur
  static Future<Map<String, dynamic>> saveGeneratedProgram({
    required String userId,
    required Map<String, dynamic> program,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trainings/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 'userId': userId, 'program': program }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la sauvegarde: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur sauvegarde programme: $e');
    }
  }

  // Récupérer les programmes sauvegardés d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserTrainings(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trainings/user/$userId')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur récupération: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un entraînement sauvegardé
  static Future<bool> deleteUserTraining(String userId, String trainingId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/trainings/user/$userId/$trainingId')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return true;
      if (response.statusCode == 404) return false;
      throw Exception('Erreur suppression: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur suppression: $e');
    }
  }

  // Récupérer l'historique d'entraînement de l'utilisateur
  static Future<List<Map<String, dynamic>>> getTrainingHistory(
      String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/history/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Historique non trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer les statistiques d'entraînement
  static Future<Map<String, dynamic>> getTrainingStats(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/trainings/stats/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Statistiques non trouvées');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
