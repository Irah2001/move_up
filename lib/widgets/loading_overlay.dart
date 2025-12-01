import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accentGreen),
            const SizedBox(height: 15),
            Text(message, style: const TextStyle(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}
