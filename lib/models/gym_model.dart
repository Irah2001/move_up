// lib/models/gym_model.dart

class Gym {
  final String name;
  final double latitude;
  final double longitude;

  Gym({required this.name, required this.latitude, required this.longitude});

  factory Gym.fromJson(Map<String, dynamic> json) {
    // 1. Récupération du nom (privilégiez inst_nom)
    final String name =
        json['inst_nom'] as String? ??
        json['equip_nom'] as String? ??
        'Nom de la salle inconnu';

    // 2. Récupération de l'objet de coordonnées exact : 'equip_coordonnees'
    final Map<String, dynamic>? coords =
        json['equip_coordonnees'] as Map<String, dynamic>?;

    if (coords == null) {
      // Le record n'a pas de coordonnées, on jette une exception pour l'ignorer
      throw const FormatException("Coordonnées manquantes.");
    }

    // 3. Extraction sécurisée : 'lat' et 'lon' sont lus comme 'num' puis convertis en 'double'.
    // Ceci est essentiel pour éviter les erreurs de type au runtime.
    final double latitude = (coords['lat'] as num?)?.toDouble() ?? 0.0;
    final double longitude = (coords['lon'] as num?)?.toDouble() ?? 0.0;

    // 4. Si les coordonnées sont invalides, on jette une exception pour ne pas marquer ce point
    if (latitude == 0.0 && longitude == 0.0) {
      throw const FormatException("Latitude ou Longitude nulle.");
    }

    return Gym(name: name, latitude: latitude, longitude: longitude);
  }
}
