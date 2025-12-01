import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';

class ChatbotWidget extends StatefulWidget {
  final VoidCallback onTap;

  const ChatbotWidget({
    super.key,
    required this.onTap,
  });

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGreen,
                AppColors.accentGreen.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 12),
              const Text(
                'Assistant IA',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Préparez vos entraînements',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'Discuter →',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
