import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:move_up/constants/api_config.dart';

/// Classe utilitaire pour les requêtes HTTP
class HttpHelper {
  // Client HTTP réutilisable
  static final http.Client _client = http.Client();

  /// Effectuer une requête GET
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _buildHeaders(headers),
          )
          .timeout(timeout ?? ApiConfig.connectionTimeout);

      _logRequest('GET', url, response.statusCode);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Effectuer une requête POST
  static Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(timeout ?? ApiConfig.connectionTimeout);

      _logRequest('POST', url, response.statusCode);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Effectuer une requête PUT
  static Future<Map<String, dynamic>> put(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(timeout ?? ApiConfig.connectionTimeout);

      _logRequest('PUT', url, response.statusCode);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Effectuer une requête DELETE
  static Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(headers),
          )
          .timeout(timeout ?? ApiConfig.connectionTimeout);

      _logRequest('DELETE', url, response.statusCode);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: $e');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Construire les headers avec les valeurs par défaut
  static Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Ajouter l'API key si configurée
    // headers[ApiConfig.apiKeyHeader] = 'YOUR_API_KEY';

    // Fusionner les headers personnalisés
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Gérer la réponse HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Succès
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {'success': true, 'statusCode': response.statusCode};
      }
    } else if (response.statusCode == 400) {
      throw Exception('Requête invalide');
    } else if (response.statusCode == 401) {
      throw Exception('Non authentifié');
    } else if (response.statusCode == 403) {
      throw Exception('Accès refusé');
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else if (response.statusCode == 500) {
      throw Exception('Erreur serveur interne');
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  /// Logger les requêtes en mode debug
  static void _logRequest(String method, String url, int statusCode) {
    if (ApiConfig.enableLogging) {
      print('[$method] $url - Status: $statusCode');
    }
  }
}
