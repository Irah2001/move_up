import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/services/training_service.dart';

class MyTrainingsScreen extends StatefulWidget {
  const MyTrainingsScreen({super.key});

  @override
  State<MyTrainingsScreen> createState() => _MyTrainingsScreenState();
}

class _MyTrainingsScreenState extends State<MyTrainingsScreen> {
  List<Map<String, dynamic>> _trainings = [];
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await TrainingService.getUserTrainings('user_1');
      setState(() => _trainings = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      final ok = await TrainingService.deleteUserTraining('user_1', id);
      if (ok) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supprimé')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non trouvé')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes entraînements'), backgroundColor: AppColors.primaryDark),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _trainings.length,
              itemBuilder: (context, i) {
                final t = _trainings[i];
                return ListTile(
                  title: Text(t['program']['name'] ?? t['programName'] ?? 'Programme'),
                  subtitle: Text(t['generatedAt'] ?? ''),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(t['id'] ?? t['trainingId'] ?? '')),
                );
              },
            ),
    );
  }
}
