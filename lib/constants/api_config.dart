/// Configuration centralisée de l'API
class ApiConfig {
  // Mode de développement/production
  static const String environment = 'development'; // 'development' ou 'production'

  // URLs de base par environnement
  static const Map<String, String> baseUrls = {
    'development': 'http://localhost:3000/api',
    'production': 'https://api.moveup.com/api',
  };

  // URL actuelle basée sur l'environnement
  static String get baseUrl => baseUrls[environment] ?? baseUrls['development']!;

  // Configuration des timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Endpoints d'entraînement
  static const String trainingsEndpoint = '/trainings';
  static const String categoriesEndpoint = '/trainings/categories';
  static const String programsEndpoint = '/trainings/programs';
  static const String historyEndpoint = '/trainings/history';
  static const String statsEndpoint = '/trainings/stats';

  // Endpoints de nutrition
  static const String mealsEndpoint = '/nutrition/meals';
  static const String mealPlansEndpoint = '/nutrition/meal-plans';
  static const String favoritesEndpoint = '/nutrition/favorites';
  static const String searchEndpoint = '/nutrition/meals/search';

  // Constructeurs d'URLs complets
  static String get trainingsUrl => '$baseUrl$trainingsEndpoint';
  static String get categoriesUrl => '$baseUrl$categoriesEndpoint';
  static String get programsUrl => '$baseUrl$programsEndpoint';
  static String get mealsUrl => '$baseUrl$mealsEndpoint';
  static String get mealPlansUrl => '$baseUrl$mealPlansEndpoint';

  // Authentification (si nécessaire)
  static const String apiKeyHeader = 'X-API-Key';
  static const String authorizationHeader = 'Authorization';

  // Version de l'API
  static const String apiVersion = '1.0.0';

  // Mode debug
  static const bool enableLogging = true;

  // Méthodologie de construction d'URL avec paramètres
  static String buildUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    String url = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      List<String> params = [];
      queryParams.forEach((key, value) {
        params.add('$key=$value');
      });
      url += '?${params.join('&')}';
    }
    return url;
  }

  // Méthodologie de construction d'URLs avec ID
  static String buildUrlWithId(String endpoint, String id) {
    return '$baseUrl$endpoint/$id';
  }
}
