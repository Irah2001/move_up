import 'package:flutter/material.dart';
import 'package:move_up/screens/signup_screen.dart';
import 'package:move_up/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome_screen_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spacer pour pousser le contenu vers le bas
                const Spacer(),

                // Titre principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOIS FORT, ',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7F8F7),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'SOIS EN BONNE ',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7F8F7),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'SANTE',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7F8F7),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Boutons côte à côte
                Row(
                  children: [
                    // Bouton S'inscrire
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                              0xFFF2FD48,
                            ), // Couleur Figma exacte
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'S\'INSCRIRE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Bouton Se connecter
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                              0xFF3F3E3E,
                            ).withValues(alpha: 0.60), // Opacité moyenne
                            foregroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'SE CONNECTER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
