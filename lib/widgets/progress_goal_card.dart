import 'package:flutter/material.dart';
import 'package:move_up/constants/profile_theme.dart';

class ProgressGoalCard extends StatelessWidget {
  final String goal;
  final double progress; // Valeur attendue entre 0.0 et 1.0
  final void Function(String newGoal, double newProgress)? onChanged;

  const ProgressGoalCard({
    super.key,
    required this.goal,
    required this.progress,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mon Objectif Actuel",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            goal,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 15),
          // Pour arrondir la progress bar on l'enveloppe dans un ClipRRect
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(clampedProgress * 100).toStringAsFixed(0)}% Atteint",
                style: const TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () async {
                  // Ouvre un dialogue pour changer l'objectif et la progression
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) {
                      final TextEditingController goalController = TextEditingController(text: goal);
                      final TextEditingController progressController = TextEditingController(text: (clampedProgress * 100).toStringAsFixed(0));
                      return AlertDialog(
                        backgroundColor: cardColor,
                        title: const Text('Modifier l\'objectif', style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: goalController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Objectif', hintText: 'Ex: Atteindre 78 kg', labelStyle: TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: progressController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Progression (%)', hintText: '0-100', labelStyle: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                              final String newGoal = goalController.text.trim();
                              final double? newProgress = double.tryParse(progressController.text.trim());
                              Navigator.of(context).pop({
                                'goal': newGoal.isEmpty ? goal : newGoal,
                                'progress': (newProgress == null) ? clampedProgress : (newProgress.clamp(0.0, 100.0) / 100.0),
                              });
                            },
                            child: const Text('Enregistrer', style: TextStyle(color: accentColor)),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null && context.mounted) {
                    final String updatedGoal = result['goal'] as String;
                    final double updatedProgress = result['progress'] as double;
                    // Propager la mise à jour au parent si callback fourni
                    if (onChanged != null) {
                      onChanged!(updatedGoal, updatedProgress);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Objectif mis à jour: $updatedGoal — ${(updatedProgress * 100).toStringAsFixed(0)}%')),
                    );
                    // Note: ici on notifie le parent; le parent doit persister la valeur si besoin.
                  }
                },
                child: const Text(
                  "Changer",
                  style: TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
