import 'package:flutter/material.dart';
import 'package:move_up/constants/profile_theme.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  Widget _sectionCard({required String title, required Widget child, EdgeInsetsGeometry? padding}) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: accentColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _placeholderChart(BuildContext context, List<int> values, {bool bars = true}) {
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final h = (v / (max == 0 ? 1 : max)) * 100 + 10;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (bars)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: h,
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(6)),
                    )
                  else
                    Container(
                      height: 6,
                      color: Colors.white10,
                    ),
                  const SizedBox(height: 8),
                  Text('M', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Example small datasets - in real app we'd load from Firestore
    final steps = [4000, 5000, 2000, 4500, 11000, 3000, 5200];
    final sleep = <int>[]; // empty -> show 'Aucune donnée'
    final weightHistory = [83, 83, 83];

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Statistiques', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                title: 'Entraînements',
                child: sleep.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Aucune donnée', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('7 derniers jours', style: TextStyle(color: Colors.white70)),
                        ],
                      )
                    : _placeholderChart(context, sleep),
              ),

              _sectionCard(
                title: 'Pas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Moyenne', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text('${steps.reduce((a, b) => a + b) ~/ steps.length}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _placeholderChart(context, steps),
                  ],
                ),
              ),

              _sectionCard(
                title: 'Poids',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${weightHistory.last} kg', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Simple horizontal timeline placeholder
                    Container(height: 60, color: Colors.white10, child: Center(child: Text('Graphique poids', style: TextStyle(color: Colors.white70)))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Mettre à jour mon poids', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              ),

              _sectionCard(
                title: 'Temps au lit',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aucune donnée', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    _placeholderChart(context, []),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
