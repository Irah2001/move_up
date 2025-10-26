import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream pour écouter les changements d'état de l'utilisateur
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Inscription avec email et mot de passe
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Le mot de passe est trop faible';
      } else if (e.code == 'email-already-in-use') {
        throw 'Un compte existe déjà avec cet email';
      }
      throw 'Erreur lors de l\'inscription: ${e.message}';
    } catch (e) {
      throw 'Erreur inattendue: $e';
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        throw 'Mot de passe incorrect';
      } else if (e.code == 'invalid-credential') {
        throw 'Email ou mot de passe incorrect';
      }
      throw 'Erreur lors de la connexion: ${e.message}';
    } catch (e) {
      throw 'Erreur inattendue: $e';
    }
  }

  // Connexion avec Google (v7+ API)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialiser GoogleSignIn
      await GoogleSignIn.instance.initialize();

      // Authentifier avec Google (remplace signIn())
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email']);

      // Obtenir l'authorization pour les scopes (remplace googleAuth.accessToken)
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email']);

      if (authorization == null) {
        // Si pas d'autorisation, la demander
        final newAuth = await googleUser.authorizationClient.authorizeScopes([
          'email',
        ]);

        // Créer credential Firebase avec l'autorisation nouvellement obtenue
        final credential = GoogleAuthProvider.credential(
          accessToken: newAuth.accessToken,
          idToken: googleUser.authentication.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }

      // Créer credential Firebase avec l'autorisation existante
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      // Se connecter avec la credential
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      throw 'Erreur Google Sign-In: ${e.code.name} - ${e.description}';
    } catch (e) {
      throw 'Erreur lors de la connexion Google: $e';
    }
  } // Réinitialisation du mot de passe

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Aucun utilisateur trouvé avec cet email';
      }
      throw 'Erreur: ${e.message}';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    // Déconnexion de Google si connecté
    await GoogleSignIn.instance.signOut();
  }
}
