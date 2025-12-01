import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_up/models/nutrition_model.dart';

class NutritionService {
  // À remplacer par votre URL d'API réelle
  static const String baseUrl = 'https://api.example.com/api';

  // Récupérer tous les repas
  static Future<List<Meal>> getAllMeals() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/meals'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer les repas par objectif
  static Future<List<Meal>> getMealsByObjective(String objective) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/meals/objective/$objective'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        throw Exception('Aucun repas trouvé pour cet objectif');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer un repas spécifique
  static Future<Meal> getMealById(String mealId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/meals/$mealId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Meal.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Repas non trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Rechercher des repas
  static Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/meals/search?q=$query'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        throw Exception('Aucun résultat trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Créer un plan de repas
  static Future<Map<String, dynamic>> createMealPlan({
    required String userId,
    required List<String> mealIds,
    required String objective,
    required int durationDays,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/meal-plans/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'mealIds': mealIds,
          'objective': objective,
          'durationDays': durationDays,
          'createdAt': DateTime.now().toIso8601String(),
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

  // Récupérer les plans de repas de l'utilisateur
  static Future<List<Map<String, dynamic>>> getUserMealPlans(
      String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/meal-plans/user/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Aucun plan de repas trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Ajouter un repas aux favoris
  static Future<Map<String, dynamic>> addMealToFavorites({
    required String userId,
    required String mealId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/favorites/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'mealId': mealId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de l\'ajout: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Retirer un repas des favoris
  static Future<void> removeMealFromFavorites({
    required String userId,
    required String mealId,
  }) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/nutrition/favorites/$userId/$mealId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Récupérer les repas favoris de l'utilisateur
  static Future<List<Meal>> getFavoriteMeals(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/favorites/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        throw Exception('Aucun favori trouvé');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir les statistiques nutritionnelles
  static Future<Map<String, dynamic>> getNutritionStats(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/nutrition/stats/$userId'))
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

  // Enregistrer la consommation d'un repas
  static Future<Map<String, dynamic>> logMealConsumption({
    required String userId,
    required String mealId,
    required DateTime consumedAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition/log-consumption'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'mealId': mealId,
          'consumedAt': consumedAt.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de l\'enregistrement: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
