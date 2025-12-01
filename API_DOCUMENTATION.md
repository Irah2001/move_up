# API Documentation - Move Up

Ce document décrit les services d'API pour les entraînements et la nutrition dans l'application Move Up.

## Configuration

### URL de Base
```
https://api.example.com/api
```

À remplacer par votre URL d'API réelle dans les fichiers services.

## Services d'Entraînement (TrainingService)

### 1. Récupérer toutes les catégories d'entraînement
```
GET /trainings/categories
```
**Réponse:** Liste des catégories d'entraînement

### 2. Récupérer une catégorie spécifique
```
GET /trainings/categories/{categoryId}
```
**Paramètres:** 
- `categoryId`: ID de la catégorie

**Réponse:** Détails de la catégorie avec ses programmes

### 3. Récupérer tous les programmes d'entraînement
```
GET /trainings/programs
```
**Réponse:** Liste de tous les programmes disponibles

### 4. Récupérer les programmes d'une catégorie
```
GET /trainings/categories/{categoryId}/programs
```
**Paramètres:**
- `categoryId`: ID de la catégorie

**Réponse:** Liste des programmes pour la catégorie

### 5. Récupérer un programme spécifique
```
GET /trainings/programs/{programId}
```
**Paramètres:**
- `programId`: ID du programme

**Réponse:** Détails du programme

### 6. Créer un nouvel entraînement
```
POST /trainings/create
```
**Body:**
```json
{
  "userId": "string",
  "programId": "string",
  "duration": "integer",
  "caloriesBurned": "integer",
  "completedAt": "ISO8601 datetime"
}
```
**Réponse:** Objet créé avec ID

### 7. Récupérer l'historique d'entraînement
```
GET /trainings/history/{userId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur

**Réponse:** Liste des entraînements effectués

### 8. Récupérer les statistiques d'entraînement
```
GET /trainings/stats/{userId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur

**Réponse:** Statistiques consolidées (calories brûlées, sessions, etc.)

## Services de Nutrition (NutritionService)

### 1. Récupérer tous les repas
```
GET /nutrition/meals
```
**Réponse:** Liste de tous les repas disponibles

### 2. Récupérer les repas par objectif
```
GET /nutrition/meals/objective/{objective}
```
**Paramètres:**
- `objective`: 'muscle', 'perte_poids', ou 'endurance'

**Réponse:** Liste des repas correspondant à l'objectif

### 3. Récupérer un repas spécifique
```
GET /nutrition/meals/{mealId}
```
**Paramètres:**
- `mealId`: ID du repas

**Réponse:** Détails du repas

### 4. Rechercher des repas
```
GET /nutrition/meals/search?q={query}
```
**Paramètres:**
- `q`: Terme de recherche

**Réponse:** Liste des repas correspondant à la recherche

### 5. Créer un plan de repas
```
POST /nutrition/meal-plans/create
```
**Body:**
```json
{
  "userId": "string",
  "mealIds": ["string"],
  "objective": "string",
  "durationDays": "integer",
  "createdAt": "ISO8601 datetime"
}
```
**Réponse:** Objet plan de repas créé

### 6. Récupérer les plans de repas de l'utilisateur
```
GET /nutrition/meal-plans/user/{userId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur

**Réponse:** Liste des plans de repas

### 7. Ajouter un repas aux favoris
```
POST /nutrition/favorites/add
```
**Body:**
```json
{
  "userId": "string",
  "mealId": "string"
}
```
**Réponse:** Confirmation d'ajout

### 8. Retirer un repas des favoris
```
DELETE /nutrition/favorites/{userId}/{mealId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur
- `mealId`: ID du repas

**Réponse:** Confirmation de suppression

### 9. Récupérer les repas favoris
```
GET /nutrition/favorites/{userId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur

**Réponse:** Liste des repas favoris

### 10. Obtenir les statistiques nutritionnelles
```
GET /nutrition/stats/{userId}
```
**Paramètres:**
- `userId`: ID de l'utilisateur

**Réponse:** Statistiques nutritionnelles (calories moyennes, macros, etc.)

### 11. Enregistrer la consommation d'un repas
```
POST /nutrition/log-consumption
```
**Body:**
```json
{
  "userId": "string",
  "mealId": "string",
  "consumedAt": "ISO8601 datetime"
}
```
**Réponse:** Confirmation d'enregistrement

## Modèles de Données

### TrainingCategory
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "imageUrl": "string",
  "programs": [TrainingProgram]
}
```

### TrainingProgram
```json
{
  "id": "string",
  "name": "string",
  "difficulty": "string",
  "duration": "integer",
  "description": "string"
}
```

### Meal
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "calories": "integer",
  "protein": "integer",
  "carbs": "integer",
  "fat": "integer",
  "prepTime": "integer",
  "imageUrl": "string",
  "objectives": ["string"]
}
```

## Gestion des Erreurs

Tous les services gèrent les erreurs suivantes:
- **Erreur de connexion**: Problème d'accès réseau
- **Erreur 4xx**: Requête invalide (404 non trouvé, 400 mauvaise requête, etc.)
- **Erreur 5xx**: Erreur serveur
- **Timeout**: Requête dépasse 10 secondes

## Utilisation dans l'App

### Récupérer les entraînements
```dart
try {
  final categories = await TrainingService.getTrainingCategories();
  // Traiter les catégories
} catch (e) {
  print('Erreur: $e');
}
```

### Récupérer les repas
```dart
try {
  final meals = await NutritionService.getAllMeals();
  // Traiter les repas
} catch (e) {
  print('Erreur: $e');
}
```

### Ajouter un entraînement complété
```dart
try {
  final result = await TrainingService.createTraining(
    userId: 'user_123',
    programId: 'cardio_1',
    duration: 30,
    caloriesBurned: 250,
  );
  // Traiter le résultat
} catch (e) {
  print('Erreur: $e');
}
```

## Notes

- Tous les services incluent des timeouts de 10 secondes
- Les réponses sont converties automatiquement depuis JSON
- Les modèles incluent les méthodes `fromJson()` et `toJson()` pour la sérialisation
- À venir: Implémentation avec Firebase Realtime Database ou Firestore
