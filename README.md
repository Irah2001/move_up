# Move Up 💪

Application mobile de fitness.

## 📋 Prérequis

- **Flutter** 3.x ou supérieur
- **Node.js** 18.x ou supérieur
- **npm** ou **yarn**

## 🚀 Lancer le projet

### 1. Backend (API)

```bash
# Aller dans le dossier backend
cd backend

# Installer les dépendances
npm install

# Configurer les variables d'environnement
# Créer/modifier le fichier .env avec :
# PORT=3000
# GEMINI_API_KEY=votre_clé_api_gemini
# GEMINI_MODEL=gemini-2.0-flash
# GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta

# Lancer le serveur
npm run dev
```

Le serveur démarre sur `http://localhost:3000`

📚 Documentation Swagger : `http://localhost:3000/api-docs`

### 2. Application Flutter

```bash
# Revenir à la racine du projet
cd ..

# Installer les dépendances Flutter
flutter pub get

# Lancer l'application
flutter run
```

## 📱 Fonctionnalités

- **Entraînements** : Catégories (Cardio, Musculation, Bien-être) avec programmes personnalisés
- **Nutrition** : Catalogue de repas avec filtres par objectif, gestion des favoris
- **Coach IA** : Chat intelligent pour conseils d'entraînement (Gemini)
- **Nutritionniste IA** : Chat intelligent pour conseils nutritionnels (Gemini)

## 🛠️ Structure du projet

```
move_up/
├── backend/           # API Node.js/Express
│   ├── server.js      # Point d'entrée
│   ├── .env           # Configuration (à créer)
│   └── data/          # Données (tips, exercices)
├── lib/               # Code Flutter
│   ├── screens/       # Écrans de l'app
│   ├── services/      # Services API
│   ├── models/        # Modèles de données
│   ├── widgets/       # Composants réutilisables
│   └── constants/     # Couleurs, config
└── assets/            # Images, fonts
```

## 🔑 Configuration Gemini (IA)

Pour activer les réponses IA dynamiques :

1. Obtenir une clé API sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Ajouter dans `backend/.env` :
   ```
   GEMINI_API_KEY=votre_clé_ici
   ```

Sans clé API, l'application utilise des réponses statiques.

## 📝 Commandes utiles

```bash
# Lancer le backend en mode développement
cd backend && npm run dev

# Lancer Flutter sur un appareil spécifique
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS Simulator

# Build de production
flutter build apk        # Android
flutter build ios        # iOS
```
