class Meal {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int protein; // en grammes
  final int carbs; // en grammes
  final int fat; // en grammes
  final int prepTime; // en minutes
  final String imageUrl;
  final List<String> objectives; // ['muscle', 'perte_poids', 'endurance']

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.imageUrl,
    required this.objectives,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      prepTime: json['prepTime'] ?? 0,
      imageUrl: json['imageUrl'] ?? 'assets/images/meal.jpg',
      objectives: json['objectives'] != null
          ? List<String>.from(json['objectives'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'prepTime': prepTime,
      'imageUrl': imageUrl,
      'objectives': objectives,
    };
  }
}

// Données d'exemple
final List<Meal> defaultMeals = [
  Meal(
    id: 'meal_1',
    name: 'Frites et Ribs de porc',
    description: 'Classique gourmand et réconfortant',
    calories: 890,
    protein: 35,
    carbs: 65,
    fat: 45,
    prepTime: 30,
    imageUrl: 'assets/images/ribs.jpg',
    objectives: ['muscle', 'perte_poids'],
  ),
  Meal(
    id: 'meal_2',
    name: 'Poulet Grillé et Riz',
    description: 'Équilibré et riche en protéines',
    calories: 650,
    protein: 50,
    carbs: 55,
    fat: 12,
    prepTime: 25,
    imageUrl: 'assets/images/chicken.jpg',
    objectives: ['muscle'],
  ),
  Meal(
    id: 'meal_3',
    name: 'Salade Protéinée',
    description: 'Légère et nutritive pour récupération',
    calories: 420,
    protein: 30,
    carbs: 35,
    fat: 15,
    prepTime: 15,
    imageUrl: 'assets/images/salad.jpg',
    objectives: ['perte_poids', 'endurance'],
  ),
  Meal(
    id: 'meal_4',
    name: 'Oeufs et Pâtes Complètes',
    description: 'Petit déj ou repas énergétique',
    calories: 580,
    protein: 25,
    carbs: 70,
    fat: 18,
    prepTime: 20,
    imageUrl: 'assets/images/eggs.jpg',
    objectives: ['muscle', 'endurance'],
  ),
  Meal(
    id: 'meal_5',
    name: 'Saumon et Patates Douces',
    description: 'Oméga-3 et glucides complexes',
    calories: 720,
    protein: 45,
    carbs: 60,
    fat: 20,
    prepTime: 28,
    imageUrl: 'assets/images/salmon.jpg',
    objectives: ['muscle', 'perte_poids'],
  ),
  Meal(
    id: 'meal_6',
    name: 'Smoothie Protéiné',
    description: 'Récupération rapide post-entrainement',
    calories: 380,
    protein: 35,
    carbs: 45,
    fat: 8,
    prepTime: 5,
    imageUrl: 'assets/images/smoothie.jpg',
    objectives: ['muscle', 'endurance', 'perte_poids'],
  ),
];
