import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/models/training_model.dart';

class WorkoutScreen extends StatefulWidget {
  final TrainingProgram program;

  const WorkoutScreen({
    super.key,
    required this.program,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  int _currentExerciseIndex = 0;
  bool _isWorkPhase = true; // true = travail, false = repos

  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Flexions',
      'duration': 30,
      'rest': 15,
      'image': 'assets/images/cardio.jpg',
    },
    {
      'name': 'Burpees',
      'duration': 20,
      'rest': 20,
      'image': 'assets/images/cardio.jpg',
    },
    {
      'name': 'Mountain Climbers',
      'duration': 30,
      'rest': 15,
      'image': 'assets/images/cardio.jpg',
    },
    {
      'name': 'Jumping Jacks',
      'duration': 25,
      'rest': 15,
      'image': 'assets/images/cardio.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.program.duration * 60;
    _remainingSeconds = _totalSeconds;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _fadeController.forward();
    _startWorkout();
  }

  void _startWorkout() {
    setState(() => _isRunning = true);
    _startCountdown();
  }

  void _startCountdown() {
    _countdownController = AnimationController(
      duration: Duration(seconds: _remainingSeconds),
      vsync: this,
    );

    _countdownController.addListener(() {
      setState(() {
        _remainingSeconds = (_totalSeconds * (1 - _countdownController.value)).toInt();
      });

      if (_remainingSeconds == 0) {
        _countdownController.stop();
        _onWorkoutComplete();
      }
    });

    _countdownController.forward();
  }

  void _togglePause() {
    setState(() {
      if (_isRunning) {
        _countdownController.stop();
        _isRunning = false;
      } else {
        _countdownController.forward(from: _countdownController.value);
        _isRunning = true;
      }
    });
  }

  void _onWorkoutComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey700,
        title: const Text(
          '🎉 Entraînement terminé!',
          style: TextStyle(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Excellent travail! Tu as complété ${widget.program.name}',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retourner à l'écran précédent
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  void _stopWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey700,
        title: const Text(
          'Arrêter l\'entraînement?',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Es-tu sûr de vouloir arrêter? Tu as complété ${_formatTime(_totalSeconds - _remainingSeconds)}',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continuer',
              style: TextStyle(color: AppColors.accentGreen),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B6B),
              foregroundColor: AppColors.white,
            ),
            child: const Text('Arrêter'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = exercises[_currentExerciseIndex];
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = 1.0 - (_remainingSeconds / _totalSeconds);

    return WillPopScope(
      onWillPop: () async {
        _stopWorkout();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: _stopWorkout,
          ),
          title: Text(
            widget.program.name,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barre de progression
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.grey700,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress < 0.5
                            ? AppColors.accentGreen
                            : progress < 0.8
                                ? Color(0xFFFFA94D)
                                : Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Image de l'exercice
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          currentExercise['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.grey700,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: AppColors.accentGreen,
                                size: 60,
                              ),
                            );
                          },
                        ),
                        // Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.primaryDark.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Phase indicator
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isWorkPhase
                                  ? AppColors.accentGreen
                                  : Color(0xFF748DD8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isWorkPhase ? '💪 TRAVAIL' : '😮‍💨 REPOS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Nom de l'exercice
                Text(
                  currentExercise['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // Décompte circulaire
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accentGreen.withOpacity(0.1),
                          AppColors.accentGreen.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.accentGreen.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer circle progress
                        CustomPaint(
                          painter: CircleProgressPainter(
                            progress: progress,
                            color: AppColors.accentGreen,
                          ),
                          size: const Size(200, 200),
                        ),
                        // Time display
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.1)
                                  .animate(CurvedAnimation(
                                    parent: _countdownController,
                                    curve: Curves.easeInOut,
                                  )),
                              child: Text(
                                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.accentGreen,
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Boutons de contrôle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Stop/Annuler
                    ElevatedButton.icon(
                      onPressed: _stopWorkout,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Arrêter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B6B),
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                    // Bouton Pause/Reprendre
                    ElevatedButton.icon(
                      onPressed: _togglePause,
                      icon: Icon(
                        _isRunning ? Icons.pause_circle : Icons.play_circle,
                      ),
                      label: Text(_isRunning ? 'Pause' : 'Reprendre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Statistiques
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Statistiques',
                        style: const TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.timer_outlined,
                              label: 'Temps écoulé',
                              value: _formatTime(_totalSeconds - _remainingSeconds),
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.hourglass_bottom,
                              label: 'Temps restant',
                              value: _formatTime(_remainingSeconds),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGreen, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw progress arc
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
