const trainingPrompt = ({objectives, level, durationPerWeek, availableEquipment, constraints}) => {
  return `Génère un objet JSON strict correspondant au schéma TrainingProgram. ` +
    `Réponds uniquement par un JSON valide (aucun texte hors JSON). ` +
    `Contrainte: champs requis: id, name, difficulty (Facile|Intermédiaire|Difficile), objectives (array), workouts (array). ` +
    `Chaque workout doit contenir id,name,day (optionnel), durationMinutes (optionnel), warmup (array optionnel), exercises (array). ` +
    `Chaque exercise doit contenir id,name,sets (integer),reps (string),restSeconds (integer) et peut contenir tempo,instructions,equipment,muscles. ` +
    `Contexte utilisateur: objectives=${JSON.stringify(objectives)}, level=${level}, durationPerWeek=${durationPerWeek}, availableEquipment=${JSON.stringify(availableEquipment)}, constraints=${JSON.stringify(constraints)}. ` +
    `Produis des noms d'exercices canoniques lorsque possible (Squat, Pompes, Soulevé de terre).`;
}

const nutritionPrompt = ({objectives, dietType, calorieGoal, restrictions, mealsPerDay}) => {
  return `Génère un objet JSON strict représentant un plan de nutrition (plan + meals + tips). ` +
    `Réponds uniquement par un JSON valide. Contexte: objectives=${JSON.stringify(objectives)}, dietType=${dietType}, calorieGoal=${calorieGoal}, restrictions=${JSON.stringify(restrictions)}, mealsPerDay=${mealsPerDay}.`;
}

module.exports = { trainingPrompt, nutritionPrompt };
