import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedIndex = 0; // 0: Semaine, 1: Mois, 2: Annuel
  int _chartPeriodIndex = 0; // 0: Hebdomadaire, 1: Mensuel, 2: Annuel

  // Data generation based on index
  Map<String, dynamic> _getData(int index) {
    const int baseCalories = 2780;
    const int baseWorkouts = 4;
    const int baseTotalWorkouts = 5;

    switch (index) {
      case 0: // Semaine
        return {
          'calories': (baseCalories * 5).toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}, ',
          ),
          'workouts': '$baseWorkouts/$baseTotalWorkouts',
          'workoutLabel': 'Entraînements\nhebdomadaire',
          'workoutUnit': 'Semaine',
          'growth': '+12%',
          'chartLabels': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
        };
      case 1: // Mois
        return {
          'calories': (baseCalories * 20).toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}, ',
          ),
          'workouts': '${baseWorkouts * 4}/${baseTotalWorkouts * 4}',
          'workoutLabel': 'Entraînements\nmensuels',
          'workoutUnit': 'Mois',
          'growth': '+8%',
          'chartLabels': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
        };
      case 2: // Annuel
        return {
          'calories': (baseCalories * 240).toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}, ',
          ),
          'workouts':
              '${baseWorkouts * 48}/${baseTotalWorkouts * 48}', // 4 weeks * 12 months = 48
          'workoutLabel': 'Entraînements\nannuels',
          'workoutUnit': 'Année',
          'growth': '+15%',
          'chartLabels': [
            'Jan',
            'Fév',
            'Mar',
            'Avr',
            'Mai',
            'Juin',
            'Juil',
            'Août',
            'Sep',
            'Oct',
            'Nov',
            'Déc',
          ],
        };
      default:
        return {};
    }
  }

  Map<String, dynamic> get _currentData => _getData(_selectedIndex);

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.accentGreen),
          onPressed: () {
            // Action retour si nécessaire
          },
        ),
        centerTitle: true,
        title: const Text(
          'PROGRES',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tes Progrès',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Toggle Buttons Row
              Row(
                children: [
                  _buildToggleButton('Semaine', 0),
                  const SizedBox(width: 10),
                  _buildToggleButton('Mois', 1),
                  const SizedBox(width: 10),
                  _buildToggleButton('Annuel', 2),
                ],
              ),
              const SizedBox(height: 20),
              // Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Calories brûlées',
                      value: data['calories'],
                      unit: 'Kcal',
                      footer: data['growth'],
                      footerColor: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: data['workoutLabel'],
                      value: data['workouts'],
                      unit: data['workoutUnit'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Performance',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Small Stat Cards
              Row(
                children: [
                  _buildSmallStatCard(
                    icon: Icons.person,
                    value: '63',
                    label: 'Poids',
                    isHighlighted: false,
                  ),
                  _buildSmallStatCard(
                    icon: Icons.flash_on,
                    value: '5423',
                    label: 'Kcal Brûlées',
                    isHighlighted: true,
                  ),
                  _buildSmallStatCard(
                    icon: Icons.timer,
                    value: '3h 46m',
                    label: 'Durée Totale',
                    isHighlighted: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Chart Section
              _buildChartSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGreen : Colors.grey[500],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.black : AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    String? footer,
    Color? footerColor,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[300]!, const Color.fromRGBO(0, 0, 0, 0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          if (footer != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                footer,
                style: TextStyle(
                  color: footerColor ?? AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isHighlighted,
  }) {
    final bgColor = isHighlighted
        ? AppColors.accentGreen
        : const Color(0xFF2C2C2E);
    final textColor = isHighlighted ? AppColors.black : AppColors.white;
    final iconColor = isHighlighted ? AppColors.black : AppColors.white;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final chartData = _getData(_chartPeriodIndex);
    final labels = chartData['chartLabels'] as List<String>;
    final totalAverage = chartData['calories'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Moyenne Totale',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalAverage Kcal',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildDropdownButton('Kcal'),
                  const SizedBox(width: 8),
                  _buildPeriodDropdown(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: GraphPainter(
                color: AppColors.accentGreen,
                pointsCount: labels.length,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    final periods = ['Hebdomadaire', 'Mensuel', 'Annuel'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _chartPeriodIndex = (_chartPeriodIndex + 1) % periods.length;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              periods[_chartPeriodIndex],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final Color color;
  final int pointsCount;

  GraphPainter({required this.color, required this.pointsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    List<Offset> points = [];
    if (pointsCount == 7) {
      points = [
        Offset(0, size.height * 0.7),
        Offset(size.width * 0.16, size.height * 0.5),
        Offset(size.width * 0.33, size.height * 0.6),
        Offset(size.width * 0.5, size.height * 0.3),
        Offset(size.width * 0.66, size.height * 0.45),
        Offset(size.width * 0.83, size.height * 0.25),
        Offset(size.width, size.height * 0.4),
      ];
    } else if (pointsCount == 4) {
      points = [
        Offset(0, size.height * 0.6),
        Offset(size.width * 0.33, size.height * 0.3),
        Offset(size.width * 0.66, size.height * 0.5),
        Offset(size.width, size.height * 0.4),
      ];
    } else {
      for (int i = 0; i < pointsCount; i++) {
        points.add(
          Offset(
            size.width * (i / (pointsCount - 1)),
            size.height * (0.4 + (i % 3 == 0 ? 0.2 : -0.1)),
          ),
        );
      }
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
        final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );
      }
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
