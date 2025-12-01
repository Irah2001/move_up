import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/models/gym_model.dart';

class GymDetailsModal extends StatelessWidget {
  final Gym gym;

  const GymDetailsModal({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    // Lecture de la clé API depuis l'environnement
    final String apiKey = dotenv.env['GOOGLE_API_KEY']!;
    final String streetViewUrl =
        "https://maps.googleapis.com/maps/api/streetview?size=600x300&location=${gym.latitude},${gym.longitude}&key=$apiKey";

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              gym.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                streetViewUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentGreen,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Aucune image Street View disponible',
                        style: TextStyle(color: AppColors.grey700),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Activités : Musculation & Cardiotraining',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.primaryDark,
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
