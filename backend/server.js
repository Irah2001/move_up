const express = require('express');
const cors = require('cors');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

// ===== Gemini (Google Generative AI) INITIALIZATION =====
let GoogleGenAI = null;
let genaiClient = null;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3-pro-preview';
// Schema validation & exercise normalization
const Ajv = require('ajv');
const addFormats = require('ajv-formats');
const path = require('path');
const fs = require('fs');
const axios = require('axios');

const ajv = new Ajv({ allErrors: true, allowUnionTypes: true, strict: false });
addFormats(ajv);
const schemaPath = path.join(__dirname, 'schemas', 'training_program.schema.json');
let trainingSchema = null;
try {
  trainingSchema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
  ajv.addSchema(trainingSchema, 'trainingProgram');
  console.log('✅ TrainingProgram schema loaded for validation.');
} catch (e) {
  console.warn('⚠️ Could not load training schema:', e.message || e);
}

// Load canonical exercises map
let canonicalExercises = {};
try {
  const exercisesPath = path.join(__dirname, 'data', 'exercises.json');
  canonicalExercises = JSON.parse(fs.readFileSync(exercisesPath, 'utf8'));
  console.log('✅ Canonical exercises loaded.');
} catch (e) {
  console.warn('⚠️ Could not load canonical exercises:', e.message || e);
}

const normalizeExerciseName = (name) => {
  if (!name) return name;
  const key = name.toLowerCase().replace(/[^a-z0-9]+/g, '_');
  if (canonicalExercises[key]) return canonicalExercises[key].name;
  // fallback: title case
  return name.split(' ').map(w => w[0].toUpperCase() + w.slice(1)).join(' ');
}

// Use REST via axios when GEMINI_API_KEY is present. We do not require an SDK.
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || null;
const GEMINI_BASE = process.env.GEMINI_BASE_URL || 'https://generativelanguage.googleapis.com/v1beta';
const geminiEnabled = Boolean(GEMINI_API_KEY);
if (geminiEnabled) {
  console.log('✅ GEMINI_API_KEY present — using Gemini REST API via axios.');
} else {
  console.log('ℹ️ GEMINI_API_KEY not set; using mock AI endpoints.');
}

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// ===== SWAGGER CONFIGURATION =====
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Move Up API',
      version: '1.0.0',
      description: 'API pour l\'application Move Up - Entraînement et Nutrition',
      contact: {
        name: 'Move Up Team',
        email: 'support@moveup.com'
      },
      license: {
        name: 'MIT'
      }
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Serveur de développement'
      },
      {
        url: 'https://api.moveup.com',
        description: 'Serveur de production'
      }
    ],
    components: {
      schemas: {
        TrainingCategory: {
          type: 'object',
          required: ['id', 'name', 'description', 'programs'],
          properties: {
            id: {
              type: 'string',
              example: 'cardio',
              description: 'Identifiant unique de la catégorie'
            },
            name: {
              type: 'string',
              example: 'CARDIO',
              description: 'Nom de la catégorie'
            },
            description: {
              type: 'string',
              example: 'Améliorez votre endurance',
              description: 'Description détaillée'
            },
            imageUrl: {
              type: 'string',
              example: 'assets/images/cardio.jpg',
              description: 'URL de l\'image'
            },
            icon: {
              type: 'string',
              example: 'directions_run',
              description: 'Icône Material Design'
            },
            programs: {
              type: 'array',
              items: {
                $ref: '#/components/schemas/TrainingProgram'
              }
            }
          }
        },
        TrainingProgram: {
          type: 'object',
          required: ['id', 'name', 'difficulty', 'duration', 'description'],
          properties: {
            id: {
              type: 'string',
              example: 'cardio_1',
              description: 'Identifiant unique du programme'
            },
            name: {
              type: 'string',
              example: 'Débutant - 20 min',
              description: 'Nom du programme'
            },
            difficulty: {
              type: 'string',
              enum: ['Facile', 'Moyen', 'Difficile'],
              example: 'Facile',
              description: 'Niveau de difficulté'
            },
            duration: {
              type: 'integer',
              example: 20,
              description: 'Durée en minutes'
            },
            description: {
              type: 'string',
              example: 'Parfait pour commencer',
              description: 'Description du programme'
            },
            imageUrl: {
              type: 'string',
              example: 'assets/images/cardio_beginner.jpg',
              description: 'URL de l\'image'
            },
            objective: {
              type: 'string',
              enum: ['muscle', 'perte_poids', 'endurance', 'sante'],
              example: 'endurance',
              description: 'Objectif du programme'
            },
            exercises: {
              type: 'array',
              items: {
                $ref: '#/components/schemas/Exercise'
              }
            }
          }
        },
        Exercise: {
          type: 'object',
          required: ['name', 'duration'],
          properties: {
            name: {
              type: 'string',
              example: 'Échauffement',
              description: 'Nom de l\'exercice'
            },
            duration: {
              type: 'integer',
              example: 3,
              description: 'Durée en minutes'
            },
            rest: {
              type: 'integer',
              example: 0,
              description: 'Temps de repos en minutes'
            },
            imageUrl: {
              type: 'string',
              example: 'assets/images/warm_up.jpg',
              description: 'URL de la démonstration'
            }
          }
        },
        Meal: {
          type: 'object',
          required: ['id', 'name', 'description', 'calories', 'protein', 'carbs', 'fat'],
          properties: {
            id: {
              type: 'string',
              example: 'meal_1',
              description: 'Identifiant unique du repas'
            },
            name: {
              type: 'string',
              example: 'Poulet Grillé et Riz',
              description: 'Nom du repas'
            },
            description: {
              type: 'string',
              example: 'Équilibré et riche en protéines',
              description: 'Description du repas'
            },
            calories: {
              type: 'integer',
              example: 650,
              description: 'Calories totales'
            },
            protein: {
              type: 'integer',
              example: 50,
              description: 'Protéines en grammes'
            },
            carbs: {
              type: 'integer',
              example: 55,
              description: 'Glucides en grammes'
            },
            fat: {
              type: 'integer',
              example: 12,
              description: 'Lipides en grammes'
            },
            prepTime: {
              type: 'integer',
              example: 25,
              description: 'Temps de préparation en minutes'
            },
            imageUrl: {
              type: 'string',
              example: 'assets/images/chicken.jpg',
              description: 'URL de l\'image'
            },
            objectives: {
              type: 'array',
              items: {
                type: 'string',
                enum: ['muscle', 'perte_poids', 'endurance', 'sante']
              },
              example: ['muscle'],
              description: 'Objectifs correspondants'
            }
          }
        },
        Training: {
          type: 'object',
          required: ['userId', 'programId', 'duration'],
          properties: {
            id: {
              type: 'string',
              example: 'training_1701388800000',
              description: 'Identifiant unique de l\'entraînement'
            },
            userId: {
              type: 'string',
              example: 'user_123',
              description: 'ID de l\'utilisateur'
            },
            programId: {
              type: 'string',
              example: 'cardio_1',
              description: 'ID du programme'
            },
            duration: {
              type: 'integer',
              example: 20,
              description: 'Durée réelle en minutes'
            },
            caloriesBurned: {
              type: 'integer',
              example: 250,
              description: 'Calories brûlées'
            },
            completedAt: {
              type: 'string',
              format: 'date-time',
              example: '2025-12-01T15:30:00Z',
              description: 'Date/heure de fin'
            },
            status: {
              type: 'string',
              enum: ['completed', 'paused', 'abandoned'],
              example: 'completed',
              description: 'Statut de l\'entraînement'
            }
          }
        },
        TrainingStats: {
          type: 'object',
          properties: {
            userId: {
              type: 'string',
              example: 'user_123'
            },
            totalWorkouts: {
              type: 'integer',
              example: 42
            },
            totalCaloriesBurned: {
              type: 'integer',
              example: 12500
            },
            totalMinutes: {
              type: 'integer',
              example: 1240
            },
            averagePerWeek: {
              type: 'number',
              example: 6
            },
            currentStreak: {
              type: 'integer',
              example: 5,
              description: 'Nombre de jours consécutifs'
            }
          }
        },
        
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              example: 'Description de l\'erreur'
            },
            statusCode: {
              type: 'integer',
              example: 400
            }
          }
        }
      },
      responses: {
        NotFound: {
          description: 'Ressource non trouvée',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              }
            }
          }
        },
        BadRequest: {
          description: 'Mauvaise requête',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              }
            }
          }
        },
        ServerError: {
          description: 'Erreur serveur',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              }
            }
          }
        }
      }
      ,
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'JWT Authorization header using the Bearer scheme. Example: "Authorization: Bearer {token}"'
        }
      }
    },
    tags: [
      {
        name: 'Trainings',
        description: 'Gestion des entraînements et catégories'
      },
      {
        name: 'Nutrition',
        description: 'Gestion des repas et plans nutritionnels'
      }
    ]
  },
  apis: ['./server.js']
};

const specs = swaggerJsdoc(swaggerOptions);

// Route pour la documentation Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, { 
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Move Up API Documentation'
}));

// ===== DONNÉES EXEMPLE =====
const trainings = [
  {
    id: 'cardio',
    name: 'CARDIO',
    description: 'Améliorez votre endurance',
    imageUrl: 'assets/images/cardio.jpg',
    icon: 'directions_run',
    programs: [
      {
        id: 'cardio_1',
        name: 'Débutant - 20 min',
        difficulty: 'Facile',
        duration: 20,
        description: 'Parfait pour commencer',
        imageUrl: 'assets/images/cardio_beginner.jpg',
        objective: 'endurance',
        exercises: [
          { name: 'Échauffement', duration: 3, rest: 0, imageUrl: 'assets/images/warm_up.jpg' },
          { name: 'Course légère', duration: 15, rest: 2, imageUrl: 'assets/images/running.jpg' },
          { name: 'Retour au calme', duration: 2, rest: 0, imageUrl: 'assets/images/cool_down.jpg' }
        ]
      },
      {
        id: 'cardio_2',
        name: 'Intermédiaire - 40 min',
        difficulty: 'Moyen',
        duration: 40,
        description: 'Pour progresser',
        imageUrl: 'assets/images/cardio_intermediate.jpg',
        objective: 'endurance',
        exercises: []
      }
    ]
  },
  {
    id: 'muscle',
    name: 'MUSCLE',
    description: 'Développez vos muscles',
    imageUrl: 'assets/images/muscle.jpg',
    icon: 'fitness_center',
    programs: [
      {
        id: 'muscle_1',
        name: 'Haut du corps - 30 min',
        difficulty: 'Facile',
        duration: 30,
        description: 'Bras, épaules, poitrine',
        imageUrl: 'assets/images/upper_body.jpg',
        objective: 'muscle',
        exercises: []
      }
    ]
  }
];

const meals = [
  {
    id: 'meal_1',
    name: 'Poulet Grillé et Riz',
    description: 'Équilibré et riche en protéines',
    calories: 650,
    protein: 50,
    carbs: 55,
    fat: 12,
    prepTime: 25,
    imageUrl: 'assets/images/chicken.jpg',
    objectives: ['muscle']
  },
  {
    id: 'meal_2',
    name: 'Salade Protéinée',
    description: 'Léger et nutritif',
    calories: 380,
    protein: 35,
    carbs: 25,
    fat: 8,
    prepTime: 10,
    imageUrl: 'assets/images/salad.jpg',
    objectives: ['perte_poids', 'sante']
  },
  {
    id: 'meal_3',
    name: 'Smoothie Protéiné',
    description: 'Parfait après le workout',
    calories: 320,
    protein: 30,
    carbs: 35,
    fat: 5,
    prepTime: 5,
    imageUrl: 'assets/images/smoothie.jpg',
    objectives: ['muscle', 'endurance']
  }
];

// ===== STOCKAGE UTILISATEUR (en mémoire pour dev) =====
const userTrainings = []; // { id, userId, program, savedAt }

// ===== STOCKAGE EXERCICES (en mémoire pour dev) =====
let exercises = [
  { id: 1, name: 'Squat', difficulty: 'Medium' },
  { id: 2, name: 'Push Up', difficulty: 'Easy' }
];

// ===== ROUTES EXERCICES =====
// GET tous les exercices
app.get('/api/exercises', (req, res) => {
  res.json(exercises);
});

// POST un nouvel exercice
app.post('/api/exercises', (req, res) => {
  const { name, difficulty } = req.body;
  if (!name || !difficulty) {
    return res.status(400).json({ error: 'name et difficulty requis' });
  }
  const newExercise = {
    id: exercises.length ? exercises[exercises.length - 1].id + 1 : 1,
    name,
    difficulty
  };
  exercises.push(newExercise);
  res.status(201).json(newExercise);
});

// PUT (modifier un exercice)
app.put('/api/exercises/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { name, difficulty } = req.body;
  const exercise = exercises.find(e => e.id === id);
  if (!exercise) {
    return res.status(404).json({ error: 'Exercice non trouvé' });
  }
  if (name) exercise.name = name;
  if (difficulty) exercise.difficulty = difficulty;
  res.json(exercise);
});

// DELETE (supprimer un exercice)
app.delete('/api/exercises/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = exercises.findIndex(e => e.id === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Exercice non trouvé' });
  }
  exercises.splice(index, 1);
  res.json({ success: true });
});

// ===== ROUTES HEALTH CHECK =====

// ===== ROUTES ENTRAÎNEMENTS =====

// GET toutes les catégories d'entraînement
app.get('/api/trainings/categories', (req, res) => {
  try {
    res.json(trainings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET une catégorie spécifique
app.get('/api/trainings/categories/:categoryId', (req, res) => {
  try {
    const category = trainings.find(t => t.id === req.params.categoryId);
    if (category) {
      res.json(category);
    } else {
      res.status(404).json({ error: 'Catégorie non trouvée' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET tous les programmes
app.get('/api/trainings/programs', (req, res) => {
  try {
    const programs = trainings.flatMap(category => category.programs);
    res.json(programs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET programmes par catégorie
app.get('/api/trainings/programs/category/:categoryId', (req, res) => {
  try {
    const category = trainings.find(t => t.id === req.params.categoryId);
    if (category) {
      res.json(category.programs);
    } else {
      res.status(404).json({ error: 'Catégorie non trouvée' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET un programme spécifique
app.get('/api/trainings/programs/:programId', (req, res) => {
  try {
    const program = trainings
      .flatMap(t => t.programs)
      .find(p => p.id === req.params.programId);
    if (program) {
      res.json(program);
    } else {
      res.status(404).json({ error: 'Programme non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST créer un nouvel entraînement (logger un workout)
app.post('/api/trainings/create', (req, res) => {
  try {
    const { userId, programId, duration, caloriesBurned } = req.body;
    
    if (!userId || !programId) {
      return res.status(400).json({ error: 'userId et programId requis' });
    }

    const training = {
      id: `training_${Date.now()}`,
      userId,
      programId,
      duration,
      caloriesBurned,
      completedAt: new Date().toISOString(),
      status: 'completed'
    };

    res.status(201).json(training);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/save:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Sauvegarder un programme généré pour un utilisateur
 *     tags: [Trainings]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [userId, program]
 *             properties:
 *               userId:
 *                 type: string
 *                 example: user_123
 *               program:
 *                 type: object
 *     responses:
 *       201:
 *         description: Programme sauvegardé
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 userId:
 *                   type: string
 *                 program:
 *                   type: object
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 */
app.post('/api/trainings/save', (req, res) => {
  try {
    const { userId, program } = req.body;
    if (!userId || !program) return res.status(400).json({ error: 'userId et program requis' });
    const saved = {
      id: `user_training_${Date.now()}`,
      userId,
      program,
      savedAt: new Date().toISOString()
    };
    userTrainings.push(saved);
    res.status(201).json(saved);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/user/{userId}:
 *   get:
 *     summary: Récupérer les programmes sauvegardés d'un utilisateur
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Liste des programmes sauvegardés
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 */
app.get('/api/trainings/user/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const list = userTrainings.filter(t => t.userId === userId);
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/user/{userId}/{trainingId}:
 *   delete:
 *     security:
 *       - bearerAuth: []
 *     summary: Supprimer un entraînement sauvegardé pour un utilisateur
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: trainingId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Suppression réussie
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.delete('/api/trainings/user/:userId/:trainingId', (req, res) => {
  try {
    const { userId, trainingId } = req.params;
    const idx = userTrainings.findIndex(t => t.userId === userId && t.id === trainingId);
    if (idx === -1) return res.status(404).json({ error: 'Entraînement non trouvé' });
    userTrainings.splice(idx, 1);
    res.json({ success: true, trainingId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


// GET historique d'entraînement (utilisateur)
app.get('/api/trainings/history/:userId', (req, res) => {
  try {
    // Simuler un historique
    const history = [
      {
        id: 'training_1',
        userId: req.params.userId,
        programId: 'cardio_1',
        duration: 20,
        caloriesBurned: 250,
        completedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'training_2',
        userId: req.params.userId,
        programId: 'muscle_1',
        duration: 30,
        caloriesBurned: 350,
        completedAt: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
      }
    ];
    res.json(history);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET statistiques d'entraînement
app.get('/api/trainings/stats/:userId', (req, res) => {
  try {
    const stats = {
      userId: req.params.userId,
      totalWorkouts: 42,
      totalCaloriesBurned: 12500,
      totalMinutes: 1240,
      averagePerWeek: 6,
      currentStreak: 5
    };
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== CRUD Entraînements (categories & programs) =====

/**
 * @swagger
 * /api/trainings/categories:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Créer une nouvelle catégorie d'entraînement
 *     tags: [Trainings]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name]
 *             properties:
 *               id:
 *                 type: string
 *                 example: cardio_new
 *               name:
 *                 type: string
 *                 example: CARDIO
 *               description:
 *                 type: string
 *                 example: Améliorez votre endurance
 *               imageUrl:
 *                 type: string
 *                 example: assets/images/cardio.jpg
 *     responses:
 *       201:
 *         description: Catégorie créée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TrainingCategory'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 */
app.post('/api/trainings/categories', (req, res) => {
  try {
    const { id, name, description, imageUrl, icon } = req.body;
    if (!name) return res.status(400).json({ error: 'name requis' });
    const newCategory = {
      id: id || `cat_${Date.now()}`,
      name,
      description: description || '',
      imageUrl: imageUrl || '',
      icon: icon || 'fitness_center',
      programs: []
    };
    trainings.push(newCategory);
    res.status(201).json(newCategory);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/categories/{categoryId}:
 *   put:
 *     security:
 *       - bearerAuth: []
 *     summary: Mettre à jour une catégorie d'entraînement
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: categoryId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               imageUrl:
 *                 type: string
 *     responses:
 *       200:
 *         description: Catégorie mise à jour
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TrainingCategory'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.put('/api/trainings/categories/:categoryId', (req, res) => {
  try {
    const { categoryId } = req.params;
    const cat = trainings.find(c => c.id === categoryId);
    if (!cat) return res.status(404).json({ error: 'Catégorie non trouvée' });
    const { name, description, imageUrl, icon } = req.body;
    if (name) cat.name = name;
    if (description) cat.description = description;
    if (imageUrl) cat.imageUrl = imageUrl;
    if (icon) cat.icon = icon;
    res.json(cat);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/categories/{categoryId}:
 *   delete:
 *     security:
 *       - bearerAuth: []
 *     summary: Supprimer une catégorie d'entraînement
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: categoryId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Catégorie supprimée
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.delete('/api/trainings/categories/:categoryId', (req, res) => {
  try {
    const { categoryId } = req.params;
    const idx = trainings.findIndex(c => c.id === categoryId);
    if (idx === -1) return res.status(404).json({ error: 'Catégorie non trouvée' });
    trainings.splice(idx, 1);
    res.json({ success: true, categoryId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/programs:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Créer un nouveau programme d'entraînement (dans une catégorie)
 *     tags: [Trainings]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [categoryId, name]
 *             properties:
 *               categoryId:
 *                 type: string
 *                 example: cardio
 *               id:
 *                 type: string
 *                 example: cardio_3
 *               name:
 *                 type: string
 *                 example: Nouvel entraînement
 *               difficulty:
 *                 type: string
 *               duration:
 *                 type: integer
 *               description:
 *                 type: string
 *     responses:
 *       201:
 *         description: Programme créé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TrainingProgram'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 */
app.post('/api/trainings/programs', (req, res) => {
  try {
    const { categoryId, id, name, difficulty, duration, description, imageUrl, objective } = req.body;
    if (!categoryId || !name) return res.status(400).json({ error: 'categoryId et name requis' });
    const cat = trainings.find(c => c.id === categoryId);
    if (!cat) return res.status(404).json({ error: 'Catégorie non trouvée' });
    const newProgram = {
      id: id || `prog_${Date.now()}`,
      name,
      difficulty: difficulty || 'Facile',
      duration: duration || 20,
      description: description || '',
      imageUrl: imageUrl || '',
      objective: objective || '' ,
      exercises: []
    };
    cat.programs.push(newProgram);
    res.status(201).json(newProgram);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/programs/{programId}:
 *   put:
 *     security:
 *       - bearerAuth: []
 *     summary: Mettre à jour un programme d'entraînement
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: programId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               duration:
 *                 type: integer
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Programme mis à jour
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/TrainingProgram'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.put('/api/trainings/programs/:programId', (req, res) => {
  try {
    const { programId } = req.params;
    let found = null;
    for (const cat of trainings) {
      const prog = cat.programs.find(p => p.id === programId);
      if (prog) { found = prog; break; }
    }
    if (!found) return res.status(404).json({ error: 'Programme non trouvé' });
    const { name, duration, description, difficulty, imageUrl, objective } = req.body;
    if (name) found.name = name;
    if (duration) found.duration = duration;
    if (description) found.description = description;
    if (difficulty) found.difficulty = difficulty;
    if (imageUrl) found.imageUrl = imageUrl;
    if (objective) found.objective = objective;
    res.json(found);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/trainings/programs/{programId}:
 *   delete:
 *     security:
 *       - bearerAuth: []
 *     summary: Supprimer un programme d'entraînement
 *     tags: [Trainings]
 *     parameters:
 *       - in: path
 *         name: programId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Programme supprimé
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.delete('/api/trainings/programs/:programId', (req, res) => {
  try {
    const { programId } = req.params;
    for (const cat of trainings) {
      const idx = cat.programs.findIndex(p => p.id === programId);
      if (idx !== -1) {
        cat.programs.splice(idx, 1);
        return res.json({ success: true, programId });
      }
    }
    return res.status(404).json({ error: 'Programme non trouvé' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== ROUTES NUTRITION =====

// GET tous les repas
app.get('/api/nutrition/meals', (req, res) => {
  try {
    res.json(meals);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET repas par objectif
app.get('/api/nutrition/meals/objective/:objective', (req, res) => {
  try {
    const filtered = meals.filter(meal => 
      meal.objectives.includes(req.params.objective)
    );
    res.json(filtered);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET un repas spécifique
app.get('/api/nutrition/meals/:mealId', (req, res) => {
  try {
    const meal = meals.find(m => m.id === req.params.mealId);
    if (meal) {
      res.json(meal);
    } else {
      res.status(404).json({ error: 'Repas non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST ajouter un repas aux favoris
app.post('/api/nutrition/favorites/add', (req, res) => {
  try {
    const { userId, mealId } = req.body;
    
    if (!userId || !mealId) {
      return res.status(400).json({ error: 'userId et mealId requis' });
    }

    res.status(201).json({
      success: true,
      userId,
      mealId,
      addedAt: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST retirer d'un repas des favoris
app.delete('/api/nutrition/favorites/remove', (req, res) => {
  try {
    const { userId, mealId } = req.body;
    
    if (!userId || !mealId) {
      return res.status(400).json({ error: 'userId et mealId requis' });
    }

    res.json({
      success: true,
      userId,
      mealId,
      removedAt: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET favoris d'un utilisateur
app.get('/api/nutrition/favorites/:userId', (req, res) => {
  try {
    // Simuler les favoris
    const favorites = meals.slice(0, 2);
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET statistiques nutrition
app.get('/api/nutrition/stats/:userId', (req, res) => {
  try {
    const stats = {
      userId: req.params.userId,
      averageCaloriesPerDay: 2100,
      totalMealsLogged: 87,
      favoriteMeals: 8,
      nutritionStreak: 12
    };
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== CRUD NUTRITION (Meals) =====

/**
 * @swagger
 * /api/nutrition/meals:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Créer un nouveau repas
 *     tags: [Nutrition]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, calories]
 *             properties:
 *               id:
 *                 type: string
 *                 example: meal_new_001
 *               name:
 *                 type: string
 *                 example: Poulet grillé avec riz
 *               calories:
 *                 type: integer
 *                 example: 520
 *               protein:
 *                 type: number
 *                 example: 35
 *               carbs:
 *                 type: number
 *                 example: 45
 *               fat:
 *                 type: number
 *                 example: 12
 *               description:
 *                 type: string
 *                 example: Repas équilibré riche en protéines
 *               imageUrl:
 *                 type: string
 *                 example: assets/images/chicken_rice.jpg
 *               objectives:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["muscle", "sain"]
 *               prepTime:
 *                 type: integer
 *                 example: 15
 *     responses:
 *       201:
 *         description: Repas créé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Meal'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 */
app.post('/api/nutrition/meals', (req, res) => {
  try {
    const { id, name, calories, protein, carbs, fat, description, imageUrl, objectives, prepTime } = req.body;
    
    if (!name || calories === undefined) {
      return res.status(400).json({ error: 'name et calories requis' });
    }
    
    const newMeal = {
      id: id || `meal_${Date.now()}`,
      name,
      calories,
      protein: protein || 0,
      carbs: carbs || 0,
      fat: fat || 0,
      description: description || '',
      imageUrl: imageUrl || '',
      objectives: objectives || [],
      prepTime: prepTime || 0,
      createdAt: new Date().toISOString()
    };
    
    meals.push(newMeal);
    res.status(201).json(newMeal);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/nutrition/meals/{mealId}:
 *   put:
 *     security:
 *       - bearerAuth: []
 *     summary: Mettre à jour un repas
 *     tags: [Nutrition]
 *     parameters:
 *       - in: path
 *         name: mealId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               calories:
 *                 type: integer
 *               protein:
 *                 type: number
 *               carbs:
 *                 type: number
 *               fat:
 *                 type: number
 *               description:
 *                 type: string
 *               imageUrl:
 *                 type: string
 *               objectives:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Repas mis à jour
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Meal'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.put('/api/nutrition/meals/:mealId', (req, res) => {
  try {
    const { mealId } = req.params;
    const meal = meals.find(m => m.id === mealId);
    
    if (!meal) {
      return res.status(404).json({ error: 'Repas non trouvé' });
    }
    
    const { name, calories, protein, carbs, fat, description, imageUrl, objectives, prepTime } = req.body;
    
    if (name) meal.name = name;
    if (calories !== undefined) meal.calories = calories;
    if (protein !== undefined) meal.protein = protein;
    if (carbs !== undefined) meal.carbs = carbs;
    if (fat !== undefined) meal.fat = fat;
    if (description !== undefined) meal.description = description;
    if (imageUrl !== undefined) meal.imageUrl = imageUrl;
    if (objectives) meal.objectives = objectives;
    if (prepTime !== undefined) meal.prepTime = prepTime;
    
    meal.updatedAt = new Date().toISOString();
    res.json(meal);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/nutrition/meals/{mealId}:
 *   delete:
 *     security:
 *       - bearerAuth: []
 *     summary: Supprimer un repas
 *     tags: [Nutrition]
 *     parameters:
 *       - in: path
 *         name: mealId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Repas supprimé
 *       404:
 *         $ref: '#/components/responses/NotFound'
 */
app.delete('/api/nutrition/meals/:mealId', (req, res) => {
  try {
    const { mealId } = req.params;
    const idx = meals.findIndex(m => m.id === mealId);
    
    if (idx === -1) {
      return res.status(404).json({ error: 'Repas non trouvé' });
    }
    
    meals.splice(idx, 1);
    res.json({ success: true, mealId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== AI ENDPOINTS (Gemini if configured, otherwise mock) =====

async function generateWithGemini(prompt) {
  if (!geminiEnabled) throw new Error('Gemini API key not configured');

  // Construct REST endpoint for Gemini API v1beta
  const url = `${GEMINI_BASE}/models/${encodeURIComponent(GEMINI_MODEL)}:generateContent?key=${encodeURIComponent(GEMINI_API_KEY)}`;

  const body = {
    contents: [
      {
        parts: [
          { text: prompt }
        ]
      }
    ],
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 500,
    }
  };

  try {
    const resp = await axios.post(url, body, { timeout: 30000 });
    const data = resp.data;

    // Extract text from Gemini response
    if (!data) return '';
    if (data.candidates && data.candidates[0]) {
      const c = data.candidates[0];
      if (c.content && c.content.parts && c.content.parts[0]) {
        return c.content.parts[0].text || '';
      }
    }
    // Fallback: stringify entire response
    return JSON.stringify(data);
  } catch (error) {
    console.error('Gemini API error:', error.response?.status, error.response?.data || error.message);
    throw error;
  }
}

app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message, context } = req.body || {};
    if (!message || !context) return res.status(400).json({ error: 'message et context requis' });

    // If Gemini client available, use it; otherwise return mock
    if (geminiEnabled && GEMINI_API_KEY) {
      const systemPrompt = context === 'training'
        ? `Tu es un entraîneur personnel motivant et compétent. Tu donnes des conseils spécifiques et adaptés sur l'entraînement, la technique, la progression et la récupération. Tu utilises un ton amical et encourageant. Réponds toujours en français. IMPORTANT: Limite ta réponse à maximum 300 caractères, sois concis et direct.`
        : `Tu es un nutritionniste expert et bienveillant. Tu donnes des conseils personnalisés sur l'alimentation, l'hydratation et les compléments. Tu utilises un ton amical et motivant. Réponds toujours en français. IMPORTANT: Limite ta réponse à maximum 300 caractères, sois concis et direct.`;
      
      const userMessage = `${systemPrompt}\n\nUtilisateur: ${message}`;
      try {
        let text = await generateWithGemini(userMessage);
        // Limiter à 300 caractères côté serveur aussi
        if (text.length > 300) {
          text = text.substring(0, 297) + '...';
        }
        return res.json({ success: true, response: text, timestamp: new Date().toISOString() });
      } catch (e) {
        console.error('Gemini chat error:', e.message || e);
        // fall through to mock below
      }
    }

    // Mock fallback
    let reply = '';
    if (context === 'training') {
      reply = `Conseil rapide: alterne cardio et renforcement. Exemple: 3 séries de 10 répétitions pour les mouvements de force.`;
    } else if (context === 'nutrition') {
      reply = `Conseil nutrition: vise un apport protéique après l'entraînement, et hydrate-toi régulièrement.`;
    } else {
      reply = `Désolé, je ne connais pas ce contexte.`;
    }

    return res.json({ success: true, response: reply, timestamp: new Date().toISOString() });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.post('/api/ai/generate-training', async (req, res) => {
  try {
    const { objectives, level, durationPerWeek, availableEquipment, constraints } = req.body || {};
    if (!objectives || !level || !durationPerWeek) return res.status(400).json({ error: 'objectives, level, et durationPerWeek requis' });

    if (genaiClient) {
      const prompt = `Génère un programme d'entraînement en JSON strict. ` +
        `Champs requis: id, name, description, duration (minutes), difficulty, objectives (array), exercises (array d'objets {name,sets,reps,rest,description}), schedule (object jours->exercices). ` +
        `Contexte utilisateur: objectives=${JSON.stringify(objectives)}, level=${level}, durationPerWeek=${durationPerWeek}, availableEquipment=${JSON.stringify(availableEquipment)}, constraints=${JSON.stringify(constraints)}. ` +
        `Réponds uniquement par un objet JSON valide.`;
      try {
        const text = await generateWithGemini(prompt);
        try {
          const parsed = JSON.parse(text);
          // normalize exercise names if present
          if (parsed && parsed.workouts) {
            parsed.workouts.forEach(w => {
              if (w.exercises && Array.isArray(w.exercises)) {
                w.exercises.forEach(ex => {
                  if (ex.name) ex.name = normalizeExerciseName(ex.name);
                });
              }
            });
          }
          // Validate against schema
          if (trainingSchema) {
            const validate = ajv.getSchema('trainingProgram') || ajv.compile(trainingSchema);
            const valid = validate(parsed);
            if (!valid) {
              console.warn('Validation failed for Gemini training output:', validate.errors);
              return res.status(201).json({ success: true, trainingRaw: parsed, validationErrors: validate.errors, generatedAt: new Date().toISOString() });
            }
          }
          return res.status(201).json({ success: true, training: parsed, generatedAt: new Date().toISOString() });
        } catch (parseErr) {
          console.warn('Gemini returned non-JSON for training, returning raw text');
          return res.status(201).json({ success: true, trainingRaw: text, generatedAt: new Date().toISOString() });
        }
      } catch (e) {
        console.error('Gemini generate-training error:', e.message || e);
        // fall through to mock below
      }
    }

    // Mock fallback
    const program = {
      id: `prog_${Date.now()}`,
      name: `${level} - Programme ${durationPerWeek}j/semaine`,
      description: `Programme généré pour ${objectives.join(', ')}`,
      duration: durationPerWeek * 30,
      difficulty: level,
      objectives: objectives,
      exercises: [
        { name: 'Échauffement', sets: 1, reps: '5-10min', rest: '0s', description: 'Marche ou vélo léger' },
        { name: 'Squat', sets: 3, reps: '8-12', rest: '60s', description: 'Pieds écartés à la largeur des hanches' },
        { name: 'Pompes', sets: 3, reps: '8-12', rest: '60s', description: 'Garde le corps droit' }
      ],
      schedule: {
        monday: ['Échauffement', 'Squat'],
        wednesday: ['Pompes'],
        friday: ['Squat', 'Pompes']
      }
    };

    return res.status(201).json({ success: true, training: program, generatedAt: new Date().toISOString() });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.post('/api/ai/generate-nutrition', async (req, res) => {
  try {
    const { objectives, dietType, calorieGoal, restrictions, mealsPerDay } = req.body || {};
    if (!objectives || !dietType || !calorieGoal) return res.status(400).json({ error: 'objectives, dietType, et calorieGoal requis' });

    if (genaiClient) {
      const prompt = `Génère un plan de nutrition en JSON strict avec champs: plan (name,description,totalCalories,macros), meals (array d'objets {id,name,timing,calories,protein,carbs,fat,ingredients,instructions}), tips (array). ` +
        `Contexte: objectives=${JSON.stringify(objectives)}, dietType=${dietType}, calorieGoal=${calorieGoal}, restrictions=${JSON.stringify(restrictions)}, mealsPerDay=${mealsPerDay}. ` +
        `Réponds uniquement par un objet JSON valide.`;
      try {
        const text = await generateWithGemini(prompt);
        try {
          const parsed = JSON.parse(text);
          return res.status(201).json({ success: true, nutrition: parsed, generatedAt: new Date().toISOString() });
        } catch (parseErr) {
          console.warn('Gemini returned non-JSON for nutrition, returning raw text');
          return res.status(201).json({ success: true, nutritionRaw: text, generatedAt: new Date().toISOString() });
        }
      } catch (e) {
        console.error('Gemini generate-nutrition error:', e.message || e);
        // fall through to mock
      }
    }

    const plan = {
      plan: {
        name: `Plan ${dietType} - ${calorieGoal} kcal`,
        description: `Plan pour ${objectives.join(', ')}`,
        totalCalories: calorieGoal,
        macros: { protein: 30, carbs: 45, fat: 25 }
      },
      meals: Array.from({ length: mealsPerDay || 3 }).map((_, i) => ({
        id: `meal_${i + 1}`,
        name: `Repas ${i + 1}`,
        timing: ['Petit-déjeuner', 'Déjeuner', 'Dîner'][i] || `Repas ${i + 1}`,
        calories: Math.round(calorieGoal / (mealsPerDay || 3)),
        protein: 25,
        carbs: 60,
        fat: 15,
        ingredients: ['Ingrédient A', 'Ingrédient B'],
        instructions: 'Préparer et déguster.'
      })),
      tips: ['Boire de l\'eau', 'Respecter les portions']
    };

    return res.status(201).json({ success: true, nutrition: plan, generatedAt: new Date().toISOString() });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

// ===== TIPS ENDPOINTS =====

// Load tips data at startup
let trainingTips = [];
let nutritionTips = [];
try {
  const trainingTipsPath = path.join(__dirname, 'data', 'training_tips.json');
  const nutritionTipsPath = path.join(__dirname, 'data', 'nutrition_tips.json');
  trainingTips = JSON.parse(fs.readFileSync(trainingTipsPath, 'utf8')).tips || [];
  nutritionTips = JSON.parse(fs.readFileSync(nutritionTipsPath, 'utf8')).tips || [];
  console.log(`✅ Loaded ${trainingTips.length} training tips and ${nutritionTips.length} nutrition tips.`);
} catch (e) {
  console.warn('⚠️ Could not load tips:', e.message || e);
}

app.get('/api/tips/training', (req, res) => {
  res.json({ tips: trainingTips });
});

app.get('/api/tips/nutrition', (req, res) => {
  res.json({ tips: nutritionTips });
});

// ===== DÉMARRAGE DU SERVEUR =====
app.listen(PORT, () => {
  console.log(`\n🚀 Serveur Move Up lancé sur http://localhost:${PORT}`);
  console.log(`\n📚 Documentation Swagger: http://localhost:${PORT}/api-docs`);
  console.log(`📝 API disponible sur http://localhost:${PORT}/api`);
  console.log(`\n💪 Entraînements: http://localhost:${PORT}/api/trainings/categories`);
  console.log(`🍎 Nutrition: http://localhost:${PORT}/api/nutrition/meals`);
  console.log(`\n⚙️  Mode: ${process.env.NODE_ENV}`);
  console.log(`\nAppuyez sur Ctrl+C pour arrêter le serveur\n`);
});

module.exports = app;
