class TrainingCategory {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<TrainingProgram> programs;

  TrainingCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.programs,
  });

  factory TrainingCategory.fromJson(Map<String, dynamic> json) {
    return TrainingCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/cardio.jpg',
      programs: json['programs'] != null
          ? List<TrainingProgram>.from(
              (json['programs'] as List).map(
                (p) => TrainingProgram.fromJson(p as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'programs': programs.map((p) => p.toJson()).toList(),
    };
  }
}

class TrainingProgram {
  final String id;
  final String name;
  final String difficulty;
  final int duration; // en minutes
  final String description;

  TrainingProgram({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.duration,
    required this.description,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      difficulty: json['difficulty'] ?? 'Moyen',
      duration: json['duration'] ?? 30,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'duration': duration,
      'description': description,
    };
  }
}

// Données d'exemple
final List<TrainingCategory> defaultTrainingCategories = [
  TrainingCategory(
    id: 'cardio',
    name: 'CARDIO',
    description: 'Améliorez votre endurance et votre santé cardiaque',
    imageUrl: 'assets/images/cardio.jpg',
    programs: [
      TrainingProgram(
        id: 'cardio_1',
        name: 'Débutant - 20 min',
        difficulty: 'Facile',
        duration: 20,
        description: 'Parfait pour commencer votre journey cardio',
      ),
      TrainingProgram(
        id: 'cardio_2',
        name: 'Intermédiaire - 30 min',
        difficulty: 'Moyen',
        duration: 30,
        description: 'Pour ceux qui ont un peu d\'expérience',
      ),
      TrainingProgram(
        id: 'cardio_3',
        name: 'Avancé - 45 min',
        difficulty: 'Difficile',
        duration: 45,
        description: 'Défiez-vous avec un entraînement intensif',
      ),
    ],
  ),
  TrainingCategory(
    id: 'musculation',
    name: 'MUSCULATION',
    description: 'Développez votre force et votre masse musculaire',
    imageUrl: 'assets/images/musculation.jpg',
    programs: [
      TrainingProgram(
        id: 'muscu_1',
        name: 'Upper Body',
        difficulty: 'Moyen',
        duration: 40,
        description: 'Travaillez poitrine, dos et bras',
      ),
      TrainingProgram(
        id: 'muscu_2',
        name: 'Lower Body',
        difficulty: 'Moyen',
        duration: 40,
        description: 'Jambes et fessiers intensifs',
      ),
      TrainingProgram(
        id: 'muscu_3',
        name: 'Full Body',
        difficulty: 'Difficile',
        duration: 50,
        description: 'Travail complet du corps en une séance',
      ),
    ],
  ),
  TrainingCategory(
    id: 'yoga',
    name: 'YOGA',
    description: 'Détente, flexibilité et bien-être mental',
    imageUrl: 'assets/images/yoga.jpg',
    programs: [
      TrainingProgram(
        id: 'yoga_1',
        name: 'Yoga Débutant',
        difficulty: 'Facile',
        duration: 30,
        description: 'Postures basiques et respiration',
      ),
      TrainingProgram(
        id: 'yoga_2',
        name: 'Vinyasa Flow',
        difficulty: 'Moyen',
        duration: 45,
        description: 'Flux dynamique et fluide',
      ),
      TrainingProgram(
        id: 'yoga_3',
        name: 'Yoga Avancé',
        difficulty: 'Difficile',
        duration: 60,
        description: 'Postures avancées et méditation profonde',
      ),
    ],
  ),
];
