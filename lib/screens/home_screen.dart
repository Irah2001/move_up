import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,

      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'ACCUEIL',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          'Contenu de la page d\'accueil',
          style: TextStyle(color: AppColors.white),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Entraînements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
