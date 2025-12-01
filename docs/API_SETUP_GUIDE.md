# Guide de Lancement des APIs - Move Up

Ce guide explique comment configurer et lancer les APIs pour l'application Move Up.

## 📋 Sommaire

1. [Option 1: Firebase (Recommandé)](#option-1-firebase-recommandé)
2. [Option 2: Node.js + Express](#option-2-nodejs--express)
3. [Option 3: Mock API Local](#option-3-mock-api-local)
4. [Configuration de l'App](#configuration-de-lapp)

---

## Option 1: Firebase (Recommandé)

### Avantages
- ✅ Pas de serveur à maintenir
- ✅ Scalable automatiquement
- ✅ Base de données temps réel
- ✅ Authentification intégrée
- ✅ Gratuit jusqu'à certaines limites

### Installation

#### 1. Créer un projet Firebase
```bash
# Aller sur https://firebase.google.com
# Cliquer sur "Commencer" → "Ajouter un projet"
# Remplir le formulaire et activer Firestore
```

#### 2. Installer Firebase CLI
```bash
npm install -g firebase-tools
```

#### 3. Se connecter à Firebase
```bash
firebase login
```

#### 4. Initialiser Firebase pour le projet
```bash
cd /Users/lucnoe/Documents/move_up
firebase init
```

Sélectionner:
- ✅ Firestore
- ✅ Hosting
- ✅ Functions (optionnel pour les APIs)

#### 5. Configurer Firestore Rules

Dans `firestore.rules`:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permettre la lecture/écriture pour les utilisateurs authentifiés
    match /trainings/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /nutrition/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /users/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 6. Déployer
```bash
firebase deploy
```

#### 7. Configurer l'App Flutter
Dans `lib/constants/api_config.dart`:
```dart
// Remplacer par votre URL Firebase
static const Map<String, String> baseUrls = {
  'development': 'https://your-project.firebaseio.com',
  'production': 'https://your-project.firebaseio.com',
};
```

---

## Option 2: Node.js + Express

### Prérequis
- Node.js 14+ installé
- npm ou yarn

### Installation

#### 1. Créer le dossier backend
```bash
cd /Users/lucnoe/Documents/move_up
mkdir backend
cd backend
npm init -y
```

#### 2. Installer les dépendances
```bash
npm install express cors dotenv axios
npm install --save-dev nodemon
```

#### 3. Créer le fichier `.env`
```
PORT=3000
NODE_ENV=development
```

#### 4. Créer `server.js`
```javascript
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Données exemple (remplacer par une vraie DB)
const trainings = [
  {
    id: 'cardio',
    name: 'CARDIO',
    description: 'Améliorez votre endurance',
    imageUrl: 'assets/images/cardio.jpg',
    programs: [
      { id: 'cardio_1', name: 'Débutant - 20 min', difficulty: 'Facile', duration: 20, description: 'Parfait pour commencer' }
    ]
  }
];

const meals = [
  {
    id: 'meal_1',
    name: 'Poulet Grillé et Riz',
    description: 'Équilibré et riche en protéines',
    calories: 650,
    protein: 50,
    carbs: 55,
    fat: 12,
    prepTime: 25,
    imageUrl: 'assets/images/chicken.jpg',
    objectives: ['muscle']
  }
];

// Routes Entraînements
app.get('/api/trainings/categories', (req, res) => {
  res.json(trainings);
});

app.get('/api/trainings/categories/:categoryId', (req, res) => {
  const category = trainings.find(t => t.id === req.params.categoryId);
  if (category) {
    res.json(category);
  } else {
    res.status(404).json({ error: 'Catégorie non trouvée' });
  }
});

app.post('/api/trainings/create', (req, res) => {
  const training = {
    id: Date.now(),
    ...req.body,
    createdAt: new Date()
  };
  res.status(201).json(training);
});

// Routes Nutrition
app.get('/api/nutrition/meals', (req, res) => {
  res.json(meals);
});

app.get('/api/nutrition/meals/:mealId', (req, res) => {
  const meal = meals.find(m => m.id === req.params.mealId);
  if (meal) {
    res.json(meal);
  } else {
    res.status(404).json({ error: 'Repas non trouvé' });
  }
});

app.post('/api/nutrition/favorites/add', (req, res) => {
  const { userId, mealId } = req.body;
  res.status(201).json({ userId, mealId, addedAt: new Date() });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur http://localhost:${PORT}`);
  console.log(`📝 API disponible sur http://localhost:${PORT}/api`);
});
```

#### 5. Ajouter script de démarrage dans `package.json`
```json
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

#### 6. Lancer le serveur
```bash
npm run dev
# Ou pour la production: npm start
```

Le serveur sera disponible sur `http://localhost:3000`

---

## Option 3: Mock API Local

Parfait pour développer sans serveur externe.

### Créer un service Mock

Créer `lib/services/mock_training_service.dart`:

```dart
import 'package:move_up/models/training_model.dart';

class MockTrainingService {
  // Simuler un délai réseau
  static Future<T> _delay<T>(T value, {int milliseconds = 800}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return value;
  }

  static Future<List<TrainingCategory>> getTrainingCategories() async {
    return _delay(defaultTrainingCategories);
  }

  static Future<List<TrainingProgram>> getProgramsByCategory(String categoryId) async {
    final category = defaultTrainingCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => defaultTrainingCategories.first,
    );
    return _delay(category.programs);
  }

  static Future<Map<String, dynamic>> createTraining({
    required String userId,
    required String programId,
    required int duration,
    required int caloriesBurned,
  }) async {
    return _delay({
      'success': true,
      'trainingId': 'training_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'programId': programId,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}
```

Créer `lib/services/mock_nutrition_service.dart`:

```dart
import 'package:move_up/models/nutrition_model.dart';

class MockNutritionService {
  static Future<T> _delay<T>(T value, {int milliseconds = 800}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return value;
  }

  static Future<List<Meal>> getAllMeals() async {
    return _delay(defaultMeals);
  }

  static Future<List<Meal>> getMealsByObjective(String objective) async {
    final filtered = defaultMeals
        .where((meal) => meal.objectives.contains(objective))
        .toList();
    return _delay(filtered);
  }

  static Future<Map<String, dynamic>> addMealToFavorites({
    required String userId,
    required String mealId,
  }) async {
    return _delay({
      'success': true,
      'userId': userId,
      'mealId': mealId,
      'addedAt': DateTime.now().toIso8601String(),
    });
  }
}
```

### Utiliser le Mock Service
```dart
// Dans votre écran
import 'package:move_up/services/mock_training_service.dart';

void loadTrainings() async {
  try {
    final categories = await MockTrainingService.getTrainingCategories();
    setState(() => _categories = categories);
  } catch (e) {
    print('Erreur: $e');
  }
}
```

---

## Configuration de l'App

### 1. Ajouter la dépendance `http` dans `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
```

Puis:
```bash
flutter pub get
```

### 2. Mettre à jour `api_config.dart`

**Pour Node.js local:**
```dart
static const Map<String, String> baseUrls = {
  'development': 'http://localhost:3000/api',
  'production': 'https://your-production-api.com/api',
};
```

**Pour Firebase:**
```dart
static const Map<String, String> baseUrls = {
  'development': 'https://your-project.firebaseio.com',
  'production': 'https://your-project.firebaseio.com',
};
```

### 3. Mettre à jour la page d'accueil

```dart
class _HomeScreenState extends State<HomeScreen> {
  List<TrainingCategory> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Utiliser l'API au lieu des données statiques
      final categories = await TrainingService.getTrainingCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erreur API: $e');
      // Fallback sur les données statiques
      setState(() => _categories = defaultTrainingCategories);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // Utiliser _categories...
  }
}
```

---

## Tester les APIs

### Avec Postman

1. Télécharger [Postman](https://www.postman.com/downloads/)
2. Créer une nouvelle requête GET
3. URL: `http://localhost:3000/api/trainings/categories`
4. Envoyer et vérifier la réponse

### Avec cURL

```bash
# GET Entraînements
curl http://localhost:3000/api/trainings/categories

# POST Créer entraînement
curl -X POST http://localhost:3000/api/trainings/create \
  -H "Content-Type: application/json" \
  -d '{"userId":"user_1","programId":"cardio_1","duration":30,"caloriesBurned":250}'

# GET Repas
curl http://localhost:3000/api/nutrition/meals
```

---

## Dépannage

### Erreur: "Connexion refusée"
```
❌ Vérifier que le serveur est lancé (npm run dev)
❌ Vérifier que le port 3000 est correct
❌ Vérifier l'URL dans api_config.dart
```

### Erreur: "CORS bloqué"
```
✅ Ajouter cors() dans Express
✅ Vérifier les headers CORS
✅ Ajouter l'URL de l'app Flutter en whitelist
```

### Erreur: "Timeout"
```
✅ Augmenter le délai dans ApiConfig
✅ Vérifier la vitesse du réseau
✅ Vérifier les logs du serveur
```

---

## Prochaines Étapes

1. **Ajouter une vraie base de données** (PostgreSQL, MongoDB, Firebase)
2. **Implémenter l'authentification** (JWT, Firebase Auth)
3. **Ajouter la validation** des données côté serveur
4. **Déployer** sur un serveur (Heroku, AWS, Google Cloud)
5. **Ajouter des tests** (Jest, unit tests)

---

## Raccourcis Utiles

```bash
# Vérifier si le serveur répond
curl http://localhost:3000/api/health

# Voir les logs en temps réel
tail -f server.log

# Arrêter le serveur
Ctrl + C

# Redémarrer avec nodemon (rechargement auto)
npm run dev
```

Bonne chance avec vos APIs! 🚀
