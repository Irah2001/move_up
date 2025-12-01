// lib/services/user_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'users';

  /// Récupère une snapshot du document user (une fois)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(collection).doc(uid).get();
    if (doc.exists) return doc.data();
    return null;
  }

  /// Écoute en temps réel le document user
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _firestore.collection(collection).doc(uid).snapshots();
  }

  /// Met à jour (ou créer) le document user avec les champs fournis
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(uid).set(data, SetOptions(merge: true));
  }

  /// Ouvre le sélecteur d'image, upload sur Firebase Storage et sauvegarde l'URL dans Firestore
  /// Retourne l'URL de l'image uploadée, ou null si annulé/erreur.
  Future<String?> pickAndUploadAvatar(String uid) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return null;
      // Use a stable object name so each user has a single avatar file
      final objectPath = 'avatars/$uid/avatar.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(objectPath);

      // Attach owner metadata to help with audits/rules if needed
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'owner': uid},
      );

      final uploadTask = storageRef.putFile(File(file.path), metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // Persister l'URL dans Firestore
      await updateUserProfile(uid, {'photoUrl': url});

      return url;
    } catch (e) {
      // Remonter l'erreur au caller pour affichage
      rethrow;
    }
  }
}
