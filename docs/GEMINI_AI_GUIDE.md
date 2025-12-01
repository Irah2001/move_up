# Intégration Gemini AI - Move Up

Cette documentation explique comment configurer et utiliser l'intégration Google Gemini AI dans Move Up.

## Configuration

### 1. Obtenir une clé API Gemini

1. Allez sur [Google AI Studio](https://aistudio.google.com/apikey)
2. Cliquez sur "Create API Key"
3. Sélectionnez votre projet Google Cloud ou créez-en un
4. Copiez la clé API

### 2. Ajouter la clé au fichier `.env`

Modifiez `/backend/.env`:

```env
PORT=3000
NODE_ENV=development
GEMINI_API_KEY=your_gemini_api_key_here
```

**Remplacez `your_gemini_api_key_here` par votre vraie clé API.**

### 3. Démarrer le serveur

```bash
cd backend
npm install  # si non fait
npm run dev
```

Le serveur démarre sur `http://localhost:3000`.

## Endpoints IA

### 1. Générer un programme d'entraînement personnalisé

**POST** `/api/ai/generate-training`

Request body:
```json
{
  "objectives": ["muscle", "force"],
  "level": "intermédiaire",
  "durationPerWeek": 4,
  "availableEquipment": ["haltères", "barre", "tapis"],
  "constraints": "Pas de blessures au genou"
}
```

**Paramètres:**
- `objectives` (requis): array de string - Vos objectifs (ex: "muscle", "cardio", "perte poids")
- `level` (requis): string - Niveau ("débutant", "intermédiaire", "avancé")
- `durationPerWeek` (requis): number - Nombre de séances par semaine
- `availableEquipment` (optionnel): array - Équipement disponible
- `constraints` (optionnel): string - Contraintes ou limitations

Response:
```json
{
  "success": true,
  "training": {
    "name": "Programme Prise de Masse Intermédiaire",
    "description": "...",
    "duration": 45,
    "difficulty": "intermédiaire",
    "objectives": ["muscle", "force"],
    "exercises": [
      {
        "name": "Développé couché",
        "sets": 4,
        "reps": "6-8",
        "rest": "120s",
        "description": "..."
      }
    ],
    "schedule": {
      "monday": ["exercise1", "exercise2"],
      "wednesday": ["exercise3"],
      "friday": ["exercise4", "exercise5"]
    }
  },
  "generatedAt": "2025-12-01T..."
}
```

### 2. Générer un plan nutrition personnalisé

**POST** `/api/ai/generate-nutrition`

Request body:
```json
{
  "objectives": ["perte poids", "santé"],
  "dietType": "équilibré",
  "calorieGoal": 2000,
  "restrictions": ["sans gluten"],
  "mealsPerDay": 3
}
```

**Paramètres:**
- `objectives` (requis): array - Objectifs nutrition
- `dietType` (requis): string - Type de régime
- `calorieGoal` (requis): number - Objectif calorique par jour
- `restrictions` (optionnel): array - Restrictions alimentaires
- `mealsPerDay` (optionnel): number - Nombre de repas par jour

Response:
```json
{
  "success": true,
  "nutrition": {
    "plan": {
      "name": "Plan Nutrition Perte Poids",
      "description": "...",
      "totalCalories": 2000,
      "macros": {
        "protein": 30,
        "carbs": 40,
        "fat": 30
      }
    },
    "meals": [
      {
        "name": "Poulet grillé avec riz complet",
        "timing": "petit-déjeuner",
        "calories": 500,
        "protein": 35,
        "carbs": 50,
        "fat": 15,
        "ingredients": ["poulet", "riz complet", "épices"],
        "instructions": "..."
      }
    ],
    "tips": ["conseil 1", "conseil 2"]
  },
  "generatedAt": "2025-12-01T..."
}
```

### 3. Chat IA pour conseils

**POST** `/api/ai/chat`

Request body:
```json
{
  "message": "Comment améliorer ma cardio?",
  "context": "training"
}
```

**Paramètres:**
- `message` (requis): string - Votre question
- `context` (requis): string - Contexte ("training" ou "nutrition")

Response:
```json
{
  "success": true,
  "response": "Pour améliorer votre cardio...",
  "context": "training",
  "timestamp": "2025-12-01T..."
}
```

## Utilisation dans Flutter

### 1. Service IA

Utilisez le service `AIService` dans `/lib/services/ai_service.dart`:

```dart
import 'package:move_up/services/ai_service.dart';

// Générer un programme d'entraînement
final result = await AIService.generateTraining(
  objectives: ['muscle', 'force'],
  level: 'intermédiaire',
  durationPerWeek: 4,
);

// Générer un plan nutrition
final nutrition = await AIService.generateNutrition(
  objectives: ['perte poids'],
  dietType: 'équilibré',
  calorieGoal: 2000,
);

// Chat simple
final response = await AIService.chat(
  message: 'Comment je dois m\'entraîner?',
  context: 'training',
);
```

### 2. Écrans Intégrés

- **AI Chat Screen** (`/lib/screens/ai_chat_screen.dart`): Chat avec l'IA pour conseils d'entraînement
- **Nutritionist Chat Screen** (`/lib/screens/nutritionist_chat_screen.dart`): Chat avec l'IA pour conseils nutrition

Les deux écrans utilisent automatiquement `AIService` pour communiquer avec Gemini.

## Exemple cURL

### Générer un programme:
```bash
curl -X POST http://localhost:3000/api/ai/generate-training \
  -H "Content-Type: application/json" \
  -d '{
    "objectives": ["muscle", "cardio"],
    "level": "intermédiaire",
    "durationPerWeek": 4
  }'
```

### Chat simple:
```bash
curl -X POST http://localhost:3000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Comment améliorer ma cardio?",
    "context": "training"
  }'
```

## Dépannage

### Erreur: "Gemini API key not provided"
- Vérifiez que `GEMINI_API_KEY` est défini dans `.env`
- Redémarrez le serveur après modification de `.env`

### Erreur: "Invalid API key"
- Vérifiez que la clé API est correcte sur [Google AI Studio](https://aistudio.google.com/apikey)
- Assurez-vous que l'API est activée pour votre projet

### Réponse vide ou malformée
- L'IA peut occasionnellement retourner du code JSON mal formaté
- Le système essaie de nettoyer les réponses (suppression des markdown code blocks)
- Si ça persiste, vérifiez les logs du serveur

## Limites et Considérations

- **Rate Limiting**: Google Generative AI a des limites de requêtes. Vérifiez les quotas.
- **Qualité de réponse**: Les réponses dépendent de la qualité du prompt et du contexte fourni.
- **Confidentialité**: Les prompts sont envoyés à Google. N'incluez pas de données sensibles.
- **Coût**: Vérifiez les tarifs de Google AI Studio.

## Next Steps

- [ ] Implémenter JWT pour protéger les endpoints IA
- [ ] Ajouter de la mise en cache pour optimiser les performances
- [ ] Implémenter un système de feedback utilisateur
- [ ] Ajouter des tests unitaires pour les endpoints IA
- [ ] Déployer en production avec authentification
