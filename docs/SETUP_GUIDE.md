# Guide de Configuration - Move Up

## Vue d'ensemble

Ce guide décrit les étapes de configuration de l'application Move Up avec Firebase Authentication.

## Étape 1 : Assets et Dépendances

1. **Image de fond** : Placez votre image dans `assets/images/welcome_screen_background.jpg`
2. **Installer les dépendances** : `flutter pub get`

## Étape 2 : Configuration Firebase

### 2.1 Créer un projet Firebase

1. [Firebase Console](https://console.firebase.google.com/) → Ajouter un projet
2. Nom du projet : "move-up" (ou votre choix)
3. Suivez les étapes de configuration

### 2.2 Dépendances Firebase

Ajoutez dans `pubspec.yaml` :

```yaml
firebase_core: ^4.2.0
firebase_auth: ^6.1.1
cloud_firestore: ^6.0.3
google_sign_in: ^7.2.0
```

### 2.3 Firebase CLI

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

### 2.4 Configuration FlutterFire

```bash
flutterfire configure
```

Cette commande génère `lib/firebase_options.dart` et configure les plateformes.

### 2.5 Activer l'authentification

Firebase Console → Authentication → Sign-in method → Activer **Email/Password**

### 2.6 Fichiers implémentés

Les fichiers suivants sont déjà créés dans le projet :

- `lib/main.dart` — Initialisation Firebase
- `lib/services/auth_service.dart` — Service d'authentification complet
- `lib/screens/welcome_screen.dart` — Écran de bienvenue
- `lib/screens/signup_screen.dart` — Écran d'inscription
- `lib/screens/login_screen.dart` — Écran de connexion

**Note** : Consultez directement ces fichiers pour voir l'implémentation. Ne dupliquez pas le code ici.

## Résumé des étapes

1. ✅ Ajoutez votre image dans `assets/images/welcome_screen_background.jpg`
2. ✅ Exécutez `flutter pub get`
3. ✅ Installez Firebase CLI et FlutterFire CLI
4. ✅ Exécutez `flutterfire configure`
5. ✅ Activez l'authentification dans Firebase Console
6. ✅ Copiez les fichiers de services et écrans fournis
7. ⬜ Testez l'application !

## Structure finale du projet

```
lib/
├── main.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── signup_screen.dart
│   ├── login_screen.dart
│   └── home_screen.dart (à créer)
├── services/
│   └── auth_service.dart
└── firebase_options.dart (généré par flutterfire)

assets/
└── images/
    └── welcome_screen_background.jpg
```