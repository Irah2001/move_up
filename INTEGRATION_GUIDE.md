# Guide d'Intégration API - Move Up

## Structure Créée

### Services API
- **`lib/services/training_service.dart`** - Service pour les entraînements
- **`lib/services/nutrition_service.dart`** - Service pour la nutrition
- **`lib/services/http_helper.dart`** - Helper HTTP réutilisable
- **`lib/constants/api_config.dart`** - Configuration centralisée

### Documentation
- **`API_DOCUMENTATION.md`** - Documentation complète des endpoints

## Étapes de Configuration

### 1. Mettre à jour l'URL de base

Dans `lib/constants/api_config.dart`, remplacer:
```dart
static const Map<String, String> baseUrls = {
  'development': 'http://localhost:3000/api',  // À remplacer
  'production': 'https://api.moveup.com/api',  // À remplacer
};
```

### 2. Configurer l'authentification (optionnel)

Si votre API nécessite une clé API:
```dart
static const String apiKeyHeader = 'X-API-Key';
// Dans http_helper.dart, décommenter:
// headers[ApiConfig.apiKeyHeader] = 'YOUR_API_KEY';
```

### 3. Ajouter les dépendances dans `pubspec.yaml`

Assurez-vous que `http` est dans les dépendances:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5  # ou version plus récente
```

Puis lancer:
```bash
flutter pub get
```

## Utilisation dans l'App

### Importer les services

```dart
import 'package:move_up/services/training_service.dart';
import 'package:move_up/services/nutrition_service.dart';
```

### Récupérer les entraînements

```dart
// Récupérer toutes les catégories
try {
  final categories = await TrainingService.getTrainingCategories();
  setState(() {
    _categories = categories;
  });
} catch (e) {
  print('Erreur: $e');
  // Afficher un message d'erreur à l'utilisateur
}
```

### Récupérer la nutrition

```dart
// Récupérer tous les repas
try {
  final meals = await NutritionService.getAllMeals();
  setState(() {
    _meals = meals;
  });
} catch (e) {
  print('Erreur: $e');
}
```

### Enregistrer un entraînement complété

```dart
try {
  final result = await TrainingService.createTraining(
    userId: 'user_123',
    programId: 'cardio_1',
    duration: 30,
    caloriesBurned: 250,
  );
  print('Entraînement enregistré: $result');
} catch (e) {
  print('Erreur: $e');
}
```

### Ajouter un repas aux favoris

```dart
try {
  await NutritionService.addMealToFavorites(
    userId: 'user_123',
    mealId: 'meal_1',
  );
  print('Repas ajouté aux favoris');
} catch (e) {
  print('Erreur: $e');
}
```

## Gestion des Erreurs

Tous les services gèrent les erreurs de:
- Connexion réseau
- Timeout (10 secondes)
- Erreurs HTTP (4xx, 5xx)
- Erreurs de parsing JSON

Exemple de gestion complète:
```dart
try {
  final meals = await NutritionService.getAllMeals();
  // Utiliser les données
} on Exception catch (e) {
  String errorMessage = 'Une erreur est survenue';
  if (e.toString().contains('Erreur de connexion')) {
    errorMessage = 'Problème de connexion réseau';
  } else if (e.toString().contains('Timeout')) {
    errorMessage = 'La requête a dépassé le délai d\'attente';
  }
  // Afficher errorMessage à l'utilisateur
}
```

## Intégration avec la Page d'Accueil

Exemple pour remplacer les données statiques par l'API:

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TrainingCategory> _categories = [];
  List<Meal> _meals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Charger les entraînements
      final categories = await TrainingService.getTrainingCategories();
      
      // Charger la nutrition
      final meals = await NutritionService.getAllMeals();
      
      setState(() {
        _categories = categories;
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erreur lors du chargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // Utiliser _categories et _meals
  }
}
```

## Testing

Pour tester localement, vous pouvez utiliser:
- **Mock API**: Créer des endpoints de test localement
- **Postman**: Tester les endpoints avant l'intégration
- **Firebase Realtime Database**: Alternative à une API REST

## Prochaines Étapes

1. **Intégrer Firebase Authentication** pour les utilisateurs
2. **Ajouter la persistance locale** avec SQLite ou Hive
3. **Implémenter la synchronisation** entre local et serveur
4. **Ajouter la gestion du cache** pour améliorer les performances
5. **Créer des modèles de réponse API** standardisés

## Ressources

- [Documentation HTTP Dart](https://pub.dev/packages/http)
- [REST API Best Practices](https://restfulapi.net/)
- [Dart JSON Serialization](https://dart.dev/guides/json)

## Support

Pour toute question ou problème:
1. Vérifier les logs de l'API
2. Consulter la documentation API_DOCUMENTATION.md
3. Vérifier la configuration dans api_config.dart
4. Tester l'endpoint avec Postman
