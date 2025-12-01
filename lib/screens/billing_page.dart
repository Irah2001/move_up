import 'package:flutter/material.dart';
import 'package:move_up/constants/profile_theme.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement & Facturation', style: TextStyle(color: Colors.white)),
        backgroundColor: darkBackgroundColor,
      ),
      backgroundColor: darkBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: Center(child: Text('Abonnement & Facturation — aucune information disponible', style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retour au profil')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Retour au profil')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
