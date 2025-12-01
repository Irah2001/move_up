import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/screens/workout_screen.dart';
import 'package:move_up/screens/ai_chat_screen.dart';
import 'package:move_up/screens/nutritionist_chat_screen.dart';
import 'package:move_up/models/training_model.dart';
import 'package:move_up/models/nutrition_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String nutritionSearchQuery = '';
  String selectedNutritionObjective = 'all';
  String nutritionTabIndex = 'all'; // 'all' pour explorer, 'favorites' pour favoris
  Set<String> favoriteMeals = {}; // Stocke les IDs des repas favoris
  Map<String, String> mealCategories = {}; // Stocke la catégorie de chaque repas

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
        leading: const SizedBox.shrink(),
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: _buildBodyContent(),
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

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'ACCUEIL';
      case 1:
        return 'ENTRAÎNEMENTS';
      case 2:
        return 'NUTRITION';
      case 3:
        return 'PROGRESS';
      case 4:
        return 'PROFIL';
      default:
        return 'MOVE UP';
    }
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildTrainingsContent();
      case 2:
        return _buildNutritionContent();
      case 3:
        return _buildProgressContent();
      case 4:
        return _buildProfileContent();
      default:
        return const Center(child: Text('Page non disponible'));
    }
  }

  // ==================== HOME CONTENT ====================
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Profil utilisateur
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.grey700,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/welcome_screen_background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue',
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Conseil motivation
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey700,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/images/welcome_screen_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plus fort à chaque rép.,\nà chaque pas! 💪',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedIndex = 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Commencer l\'entraînement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Régularité
          const Text(
            'Régularité',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                bool isToday = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 55,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.accentGreen : AppColors.grey700,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Jour',
                          style: TextStyle(
                            color: isToday
                                ? AppColors.primaryDark
                                : Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isToday
                                ? AppColors.primaryDark
                                : AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== TRAININGS CONTENT ====================
  Widget _buildTrainingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentGreen.withOpacity(0.15),
                  AppColors.accentGreen.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos Entraînements',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez une catégorie pour commencer',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AIChatScreen()),
                          );
                        },
                        icon: const Icon(Icons.smart_toy),
                        label: const Text('Coach IA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Catégories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégories',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Grille de catégories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: defaultTrainingCategories.length,
              itemBuilder: (context, index) {
                final category = defaultTrainingCategories[index];
                return _buildTrainingCategoryCard(category);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Conseils
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey700,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.accentGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Conseil du jour',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pour de meilleurs résultats, entraînez-vous régulièrement et hydratez-vous bien pendant vos séances!',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrainingCategoryCard(TrainingCategory category) {
    return GestureDetector(
      onTap: () {
        _showTrainingCategoryDetails(category);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.grey700,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            ),
            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryDark.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.id == 'cardio'
                          ? Icons.favorite
                          : category.id == 'musculation'
                              ? Icons.fitness_center
                              : Icons.self_improvement,
                      color: AppColors.accentGreen,
                      size: 24,
                    ),
                  ),
                  // Category info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.programs.length} programmes',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.accentGreen,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingCategoryDetails(TrainingCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentGreen.withOpacity(0.2),
                      AppColors.accentGreen.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(
                color: AppColors.accentGreen.withOpacity(0.2),
                height: 1,
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: category.programs.length,
                    itemBuilder: (context, index) {
                      final program = category.programs[index];
                      return _buildTrainingProgramTile(program);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingProgramTile(TrainingProgram program) {
    Color difficultyColor = _getDifficultyColor(program.difficulty);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showProgramDetails(program);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon avec background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  color: difficultyColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.description,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: AppColors.accentGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${program.duration} min',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Text(
                          program.difficulty,
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accentGreen.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showProgramDetails(TrainingProgram program) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Color difficultyColor = _getDifficultyColor(program.difficulty);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      difficultyColor.withOpacity(0.2),
                      difficultyColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: TextStyle(
                        color: difficultyColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      program.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(
                color: AppColors.accentGreen.withOpacity(0.1),
                height: 1,
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timer_outlined,
                            title: '${program.duration}',
                            subtitle: 'minutes',
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_up,
                            title: program.difficulty,
                            subtitle: 'Difficulté',
                            color: difficultyColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutScreen(program: program),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Commencer cet entraînement',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NUTRITION CONTENT ====================
  Widget _buildNutritionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentGreen.withOpacity(0.15),
                  AppColors.accentGreen.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre Nutrition',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Découvrez des repas adaptés à vos objectifs',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NutritionistChatScreen()),
                        );
                      },
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Nutritionniste'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Onglets: Explorer / Mes repas
          _buildNutritionTabs(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: nutritionTabIndex == 'all'
                ? _buildExploreContent()
                : _buildMyMealsContent(),
          ),
        ],
      ),
    );
  }

  

  Widget _buildNutritionTabs() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => nutritionTabIndex = 'all'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: nutritionTabIndex == 'all'
                          ? AppColors.accentGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  'Explorer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: nutritionTabIndex == 'all'
                        ? AppColors.accentGreen
                        : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => nutritionTabIndex = 'favorites'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: nutritionTabIndex == 'favorites'
                          ? AppColors.accentGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  'Mes repas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: nutritionTabIndex == 'favorites'
                        ? AppColors.accentGreen
                        : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreContent() {
    final filteredMeals = _getFilteredMeals();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        
        // Barre de recherche
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher un repas...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() => nutritionSearchQuery = value);
            },
          ),
        ),
        const SizedBox(height: 20),

        // Titre Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            'Filtrer par objectif',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filtres d'objectif
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final objectives = ['all', 'muscle', 'perte_poids', 'endurance'];
              final labels = ['Tous', 'Prise de muscle', 'Perte de poids', 'Endurance'];
              final objective = objectives[index];
              final isSelected = selectedNutritionObjective == objective;

              return Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedNutritionObjective = objective);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.grey700,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentGreen
                            : AppColors.accentGreen.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accentGreen.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Titre Repas disponibles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            'Repas disponibles',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Grille de repas
        if (filteredMeals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun repas trouvé',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredMeals.length,
            itemBuilder: (context, index) {
              final meal = filteredMeals[index];
              return _buildMealCard(meal);
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMyMealsContent() {
    // Catégories de repas
    const categories = ['petit_dej', 'collation', 'dejeuner', 'diner', 'dessert'];
    const categoryLabels = ['Petit-déjeuner', 'Collation', 'Déjeuner', 'Dîner', 'Dessert'];
    const categoryIcons = [
      Icons.sunny,
      Icons.water_drop,
      Icons.lunch_dining,
      Icons.dinner_dining,
      Icons.cake,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        if (favoriteMeals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun repas favori',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoute tes repas préférés',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Afficher les catégories avec repas
          for (int i = 0; i < categories.length; i++) ...[
            _buildMealCategory(
              categories[i],
              categoryLabels[i],
              categoryIcons[i],
            ),
          ]
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMealCategory(String categoryId, String categoryLabel, IconData icon) {
    final mealsInCategory = defaultMeals.where((meal) {
      final mealId = meal.name.replaceAll(' ', '_').toLowerCase();
      return favoriteMeals.contains(mealId) &&
          (mealCategories[mealId] == categoryId || mealCategories[mealId] == null);
    }).toList();

    if (mealsInCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête de catégorie
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGreen, size: 20),
              const SizedBox(width: 10),
              Text(
                categoryLabel,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${mealsInCategory.length}',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Repas de la catégorie
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mealsInCategory.length,
            itemBuilder: (context, index) {
              final meal = mealsInCategory[index];
              return Padding(
                padding: EdgeInsets.only(right: index == mealsInCategory.length - 1 ? 0 : 12),
                child: _buildFavoriteMealCard(meal),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFavoriteMealCard(Meal meal) {
    return GestureDetector(
      onTap: () {
        _showMealDetails(meal);
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.grey700,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey700,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.accentGreen,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryDark.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Contenu
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Bouton favori
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  final mealId = meal.name.replaceAll(' ', '_').toLowerCase();
                  setState(() {
                    if (favoriteMeals.contains(mealId)) {
                      favoriteMeals.remove(mealId);
                      mealCategories.remove(mealId);
                    } else {
                      favoriteMeals.add(mealId);
                    }
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    favoriteMeals.contains(meal.name.replaceAll(' ', '_').toLowerCase())
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.accentGreen,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Meal> _getFilteredMeals() {
    return defaultMeals.where((meal) {
      final matchesSearch =
          meal.name.toLowerCase().contains(nutritionSearchQuery.toLowerCase()) ||
              meal.description
                  .toLowerCase()
                  .contains(nutritionSearchQuery.toLowerCase());

      final matchesObjective = selectedNutritionObjective == 'all' ||
          meal.objectives.contains(selectedNutritionObjective);

      return matchesSearch && matchesObjective;
    }).toList();
  }

  Widget _buildMealCard(Meal meal) {
    final mealId = meal.name.replaceAll(' ', '_').toLowerCase();
    final isFavorite = favoriteMeals.contains(mealId);

    return GestureDetector(
      onTap: () {
        _showMealDetails(meal);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.grey700,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey700,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          color: AppColors.accentGreen,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primaryDark.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Infos
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.timer_outlined,
                            color: AppColors.accentGreen, size: 14),
                        Text(
                          '${meal.prepTime} min',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bouton favori
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFavorite) {
                      favoriteMeals.remove(mealId);
                      mealCategories.remove(mealId);
                    } else {
                      favoriteMeals.add(mealId);
                      mealCategories[mealId] = 'dejeuner'; // Catégorie par défaut
                    }
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.accentGreen,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentGreen.withOpacity(0.15),
                      AppColors.accentGreen.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Text(
                          '${meal.prepTime} min',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(
                color: AppColors.accentGreen.withOpacity(0.1),
                height: 1,
              ),
              // Macros
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Macros row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            icon: Icons.local_fire_department_outlined,
                            title: '${meal.calories}',
                            subtitle: 'kcal',
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            icon: Icons.egg_outlined,
                            title: '${meal.protein}g',
                            subtitle: 'Protéine',
                            color: AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMacroCard(
                            icon: Icons.grain,
                            title: '${meal.carbs}g',
                            subtitle: 'Glucides',
                            color: const Color(0xFFFFA94D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            icon: Icons.opacity,
                            title: '${meal.fat}g',
                            subtitle: 'Lipides',
                            color: const Color(0xFF748DD8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentGreen.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: AppColors.accentGreen, size: 28),
                                const SizedBox(height: 10),
                                Text(
                                  'Équilibré',
                                  style: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Repas',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Ajouter à mes repas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS CONTENT ====================
  Widget _buildProgressContent() {
    return const Center(
      child: Text(
        'Page Progress - À développer',
        style: TextStyle(color: AppColors.white),
      ),
    );
  }

  // ==================== PROFILE CONTENT ====================
  Widget _buildProfileContent() {
    return const Center(
      child: Text(
        'Page Profil - À développer',
        style: TextStyle(color: AppColors.white),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      default:
        return AppColors.accentGreen;
    }
  }
}
