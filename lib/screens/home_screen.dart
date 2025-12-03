import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/screens/workout_screen.dart';
import 'package:move_up/screens/ai_chat_screen.dart';
import 'package:move_up/screens/nutritionist_chat_screen.dart';
import 'package:move_up/models/training_model.dart';
import 'package:move_up/models/nutrition_model.dart';
import 'package:move_up/widgets/tip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String nutritionSearchQuery = '';
  String selectedNutritionObjective = 'all';
  String nutritionTabIndex = 'all';
  Set<String> favoriteMeals = {};
  Map<String, String> mealCategories = {};

  // ===== HELPERS =====
  static const _titles = ['ACCUEIL', 'ENTRAÎNEMENTS', 'NUTRITION', 'PROGRESS', 'PROFIL'];
  
  BoxDecoration _cardDecor({Color? borderColor, double opacity = 0.3}) => BoxDecoration(
    color: AppColors.grey700,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: (borderColor ?? AppColors.accentGreen).withOpacity(opacity), width: 1.5),
  );
  
  BoxDecoration _gradientDecor({Color? color, double op1 = 0.15, double op2 = 0.05}) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [(color ?? AppColors.accentGreen).withOpacity(op1), (color ?? AppColors.accentGreen).withOpacity(op2)],
    ),
  );

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold));
  
  Widget _greyText(String text, {double size = 14}) => Text(text, style: TextStyle(color: Colors.grey[400], fontSize: size));

  Color _difficultyColor(String d) => switch (d.toLowerCase()) {
    'facile' => Colors.green, 'moyen' => Colors.orange, 'difficile' => Colors.red, _ => AppColors.accentGreen
  };

  void _nav(int i) => setState(() => _selectedIndex = i);

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, elevation: 0, centerTitle: true,
        leading: const SizedBox.shrink(),
        title: Text(_titles[_selectedIndex], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: [_buildHome, _buildTrainings, _buildNutrition, _buildProgress, _buildProfile][_selectedIndex](),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _nav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Entraînements'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // ===== HOME =====
  Widget _buildHome() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 16),
      Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(
          color: AppColors.grey700, borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(image: AssetImage('assets/images/welcome_screen_background.jpg'), fit: BoxFit.cover),
        )),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bienvenue', style: TextStyle(color: AppColors.offWhite, fontSize: 12)),
          Text('John Doe', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
      ]),
      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(image: AssetImage('assets/images/welcome_screen_background.jpg'), fit: BoxFit.cover, opacity: 0.4)),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Plus fort à chaque rép.,\nà chaque pas! 💪', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _nav(1),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Commencer l\'entraînement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      _sectionTitle('Régularité'),
      const SizedBox(height: 12),
      SizedBox(height: 60, child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: 7,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(width: 55, decoration: BoxDecoration(
            color: i == 0 ? AppColors.accentGreen : AppColors.grey700, borderRadius: BorderRadius.circular(15)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Jour', style: TextStyle(color: i == 0 ? AppColors.primaryDark : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${i + 1}', style: TextStyle(color: i == 0 ? AppColors.primaryDark : AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      )),
    ]),
  );

  // ===== TRAININGS =====
  Widget _buildTrainings() => SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(decoration: _gradientDecor(), padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Vos Entraînements', style: TextStyle(color: AppColors.accentGreen, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _greyText('Choisissez une catégorie pour commencer'),
        const SizedBox(height: 12),
        Row(children: [const Spacer(), ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
          icon: const Icon(Icons.smart_toy), label: const Text('Coach IA'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.primaryDark),
        )]),
      ])),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Catégories'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.95, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: defaultTrainingCategories.length,
          itemBuilder: (_, i) => _buildCategoryCard(defaultTrainingCategories[i]),
        ),
      ])),
      const SizedBox(height: 24),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
        decoration: _cardDecor(opacity: 0.2), padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.accentGreen, size: 24),
            const SizedBox(width: 12),
            const Text('Conseil du jour', style: TextStyle(color: AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Text('Pour de meilleurs résultats, entraînez-vous régulièrement et hydratez-vous bien!', style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.5)),
        ]),
      )),
      const SizedBox(height: 24),
    ]),
  );

  Widget _buildCategoryCard(TrainingCategory cat) {
    final icon = cat.id == 'cardio' ? Icons.favorite : cat.id == 'musculation' ? Icons.fitness_center : Icons.self_improvement;
    return GestureDetector(
      onTap: () => _showCategoryDetails(cat),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentGreen.withOpacity(0.3), width: 1.5),
          gradient: LinearGradient(colors: [AppColors.grey700, AppColors.primaryDark]),
        ),
        child: Stack(children: [
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.accentGreen, size: 24)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _greyText('${cat.programs.length} programmes', size: 11),
            ]),
          ])),
          Positioned(bottom: 12, right: 12, child: Container(width: 32, height: 32, decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.arrow_forward_ios, color: AppColors.accentGreen, size: 14))),
        ]),
      ),
    );
  }

  void _showCategoryDetails(TrainingCategory cat) => showModalBottomSheet(
    context: context, backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(color: AppColors.grey700, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(decoration: _gradientDecor(op1: 0.2, op2: 0.05).copyWith(borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat.name, style: const TextStyle(color: AppColors.accentGreen, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8), _greyText(cat.description),
          ])),
        Divider(color: AppColors.accentGreen.withOpacity(0.2), height: 1),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(20), itemCount: cat.programs.length,
          itemBuilder: (_, i) => _buildProgramTile(cat.programs[i]))),
      ]),
    ),
  );

  Widget _buildProgramTile(TrainingProgram p) {
    final c = _difficultyColor(p.difficulty);
    return GestureDetector(
      onTap: () { Navigator.pop(context); _showProgramDetails(p); },
      child: Container(
        decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentGreen.withOpacity(0.25), width: 1.5)),
        margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.fitness_center, color: c, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(p.description, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.timer_outlined, color: AppColors.accentGreen, size: 14),
              const SizedBox(width: 4), _greyText('${p.duration} min', size: 11),
              const SizedBox(width: 12),
              Container(decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(p.difficulty, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold))),
            ]),
          ])),
          Icon(Icons.arrow_forward_ios, color: AppColors.accentGreen.withOpacity(0.6), size: 16),
        ]),
      ),
    );
  }

  void _showProgramDetails(TrainingProgram p) {
    final c = _difficultyColor(p.difficulty);
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: AppColors.grey700, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(decoration: _gradientDecor(color: c, op1: 0.2, op2: 0.05).copyWith(borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: TextStyle(color: c, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12), _greyText(p.description),
            ])),
          Divider(color: AppColors.accentGreen.withOpacity(0.1), height: 1),
          Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            Row(children: [
              Expanded(child: _statCard(Icons.timer_outlined, '${p.duration}', 'minutes', AppColors.accentGreen)),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.trending_up, p.difficulty, 'Difficulté', c)),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutScreen(program: p))); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Commencer cet entraînement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            )),
          ])),
        ]),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String sub, Color c) => Container(
    decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.2), width: 1.5)),
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Icon(icon, color: c, size: 28), const SizedBox(height: 10),
      Text(title, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 20)),
      const SizedBox(height: 4), _greyText(sub, size: 12),
    ]),
  );

  // ===== NUTRITION =====
  Widget _buildNutrition() => SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(decoration: _gradientDecor(), padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Votre Nutrition', style: TextStyle(color: AppColors.accentGreen, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), _greyText('Découvrez des repas adaptés à vos objectifs'),
        const SizedBox(height: 12),
        Row(children: [const Spacer(), ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionistChatScreen())),
          icon: const Icon(Icons.restaurant), label: const Text('Nutritionniste'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.primaryDark),
        )]),
      ])),
      const TipCard(title: 'Conseil nutrition', tip: 'Privilégiez les repas riches en fibres et en protéines pour favoriser la satiété.', accentColor: Color(0xFFDAFF3F), icon: Icons.restaurant_menu),
      const SizedBox(height: 16),
      _buildNutritionTabs(),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: nutritionTabIndex == 'all' ? _buildExplore() : _buildMyMeals()),
    ]),
  );

  Widget _buildNutritionTabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(children: ['all', 'favorites'].map((t) {
      final sel = nutritionTabIndex == t;
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => nutritionTabIndex = t),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: sel ? AppColors.accentGreen : Colors.transparent, width: 3))),
          child: Text(t == 'all' ? 'Explorer' : 'Mes repas', textAlign: TextAlign.center,
            style: TextStyle(color: sel ? AppColors.accentGreen : Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ));
    }).toList()),
  );

  Widget _buildExplore() {
    final meals = _filteredMeals;
    final objectives = ['all', 'muscle', 'perte_poids', 'endurance'];
    final labels = ['Tous', 'Prise de muscle', 'Perte de poids', 'Endurance'];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 20),
      Container(decoration: _cardDecor(opacity: 0.2), child: TextField(
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(hintText: 'Rechercher un repas...', hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
        onChanged: (v) => setState(() => nutritionSearchQuery = v),
      )),
      const SizedBox(height: 20),
      const Text('Filtrer par objectif', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      SizedBox(height: 46, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 4, itemBuilder: (_, i) {
        final sel = selectedNutritionObjective == objectives[i];
        return Padding(padding: EdgeInsets.only(right: i == 3 ? 0 : 10), child: GestureDetector(
          onTap: () => setState(() => selectedNutritionObjective = objectives[i]),
          child: Container(
            decoration: BoxDecoration(color: sel ? AppColors.accentGreen : AppColors.grey700, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AppColors.accentGreen : AppColors.accentGreen.withOpacity(0.2), width: 1.5)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Center(child: Text(labels[i], style: TextStyle(color: sel ? AppColors.primaryDark : AppColors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
        ));
      })),
      const SizedBox(height: 24),
      const Text('Repas disponibles', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (meals.isEmpty) _emptyState(Icons.restaurant_menu, 'Aucun repas trouvé')
      else GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 16),
        itemCount: meals.length, itemBuilder: (_, i) => _mealCard(meals[i])),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildMyMeals() {
    const cats = ['petit_dej', 'collation', 'dejeuner', 'diner', 'dessert'];
    const labels = ['Petit-déjeuner', 'Collation', 'Déjeuner', 'Dîner', 'Dessert'];
    const icons = [Icons.sunny, Icons.water_drop, Icons.lunch_dining, Icons.dinner_dining, Icons.cake];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 16),
      if (favoriteMeals.isEmpty) _emptyState(Icons.favorite_border, 'Aucun repas favori', 'Ajoute tes repas préférés')
      else ...List.generate(5, (i) => _mealCategory(cats[i], labels[i], icons[i])),
      const SizedBox(height: 20),
    ]);
  }

  Widget _mealCategory(String catId, String label, IconData icon) {
    final meals = defaultMeals.where((m) {
      final id = m.name.replaceAll(' ', '_').toLowerCase();
      return favoriteMeals.contains(id) && (mealCategories[id] == catId || mealCategories[id] == null);
    }).toList();
    if (meals.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
        Icon(icon, color: AppColors.accentGreen, size: 20), const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.accentGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Text('${meals.length}', style: const TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.bold))),
      ])),
      SizedBox(height: 140, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: meals.length,
        itemBuilder: (_, i) => Padding(padding: EdgeInsets.only(right: i == meals.length - 1 ? 0 : 12), child: _favMealCard(meals[i])))),
      const SizedBox(height: 20),
    ]);
  }

  Widget _favMealCard(Meal m) {
    final id = m.name.replaceAll(' ', '_').toLowerCase();
    return GestureDetector(
      onTap: () => _showMealDetails(m),
      child: Container(width: 120, decoration: _cardDecor(),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(m.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.grey700, child: const Icon(Icons.image_not_supported, color: AppColors.accentGreen)))),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.primaryDark.withOpacity(0.8)]))),
          Positioned(bottom: 8, left: 8, right: 8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            _greyText('${m.calories} kcal', size: 10),
          ])),
          Positioned(top: 8, right: 8, child: GestureDetector(
            onTap: () => setState(() { favoriteMeals.remove(id); mealCategories.remove(id); }),
            child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primaryDark.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.favorite, color: AppColors.accentGreen, size: 18)),
          )),
        ]),
      ),
    );
  }

  List<Meal> get _filteredMeals => defaultMeals.where((m) {
    final q = nutritionSearchQuery.toLowerCase();
    return (m.name.toLowerCase().contains(q) || m.description.toLowerCase().contains(q)) &&
      (selectedNutritionObjective == 'all' || m.objectives.contains(selectedNutritionObjective));
  }).toList();

  Widget _mealCard(Meal m) {
    final id = m.name.replaceAll(' ', '_').toLowerCase();
    final fav = favoriteMeals.contains(id);
    return GestureDetector(
      onTap: () => _showMealDetails(m),
      child: Container(decoration: _cardDecor(),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(m.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.grey700, child: const Center(child: Icon(Icons.restaurant_menu, color: AppColors.accentGreen, size: 30))))),
          Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.primaryDark.withOpacity(0.9)])))),
          Positioned(bottom: 0, left: 0, right: 0, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.timer_outlined, color: AppColors.accentGreen, size: 14), _greyText(' ${m.prepTime} min', size: 11), const Spacer(),
              Text('${m.calories} kcal', style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12))]),
          ]))),
          Positioned(top: 8, right: 8, child: GestureDetector(
            onTap: () => setState(() { fav ? favoriteMeals.remove(id) : favoriteMeals.add(id); if (!fav) mealCategories[id] = 'dejeuner'; else mealCategories.remove(id); }),
            child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryDark.withOpacity(0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accentGreen.withOpacity(0.3))),
              child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: AppColors.accentGreen, size: 18)),
          )),
        ]),
      ),
    );
  }

  void _showMealDetails(Meal m) => showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(color: AppColors.grey700, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(decoration: _gradientDecor(op1: 0.15, op2: 0.02).copyWith(borderRadius: const BorderRadius.vertical(top: Radius.circular(24))), padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: const TextStyle(color: AppColors.accentGreen, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8), Row(children: [Icon(Icons.schedule, size: 16, color: Colors.grey[400]), const SizedBox(width: 6), _greyText('${m.prepTime} min')]),
          ])),
        Divider(color: AppColors.accentGreen.withOpacity(0.1), height: 1),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(children: [
            Expanded(child: _macroCard(Icons.local_fire_department_outlined, '${m.calories}', 'kcal', const Color(0xFFFF6B6B))),
            const SizedBox(width: 12), Expanded(child: _macroCard(Icons.egg_outlined, '${m.protein}g', 'Protéine', AppColors.accentGreen)),
            const SizedBox(width: 12), Expanded(child: _macroCard(Icons.grain, '${m.carbs}g', 'Glucides', const Color(0xFFFFA94D))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _macroCard(Icons.opacity, '${m.fat}g', 'Lipides', const Color(0xFF748DD8))),
            const SizedBox(width: 12), Expanded(child: _statCard(Icons.check_circle_outline, 'Équilibré', 'Repas', AppColors.accentGreen)),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Ajouter à mes repas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          )),
        ])),
      ]),
    ),
  );

  Widget _macroCard(IconData icon, String title, String sub, Color c) => Container(
    decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.2), width: 1.5)),
    padding: const EdgeInsets.all(12),
    child: Column(children: [Icon(icon, color: c, size: 24), const SizedBox(height: 8), Text(title, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 2), _greyText(sub, size: 11)]),
  );

  Widget _emptyState(IconData icon, String title, [String? sub]) => Center(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(children: [Icon(icon, size: 64, color: Colors.grey[600]), const SizedBox(height: 16),
      Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
      if (sub != null) ...[const SizedBox(height: 8), Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 12))]]),
  ));

  // ===== PROGRESS & PROFILE =====
  Widget _buildProgress() => const Center(child: Text('Page Progress - À développer', style: TextStyle(color: AppColors.white)));
  Widget _buildProfile() => const Center(child: Text('Page Profil - À développer', style: TextStyle(color: AppColors.white)));
}
