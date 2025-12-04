import 'dart:math';

import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/services/tips_service.dart';

class TipCarousel extends StatefulWidget {
  final String tipType; // 'training' or 'nutrition'
  final String title;
  final int autoScrollSeconds; // Default 60, can be 30 or other

  const TipCarousel({
    super.key,
    required this.tipType,
    required this.title,
    this.autoScrollSeconds = 60,
  });

  @override
  State<TipCarousel> createState() => _TipCarouselState();
}

class _TipCarouselState extends State<TipCarousel> {
  late PageController _pageController;
  List<Map<String, String>> _tips = [];
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTips();
    // Auto-advance after delay specified
    Future.delayed(const Duration(seconds: 1), _startAutoScroll);
  }

  Future<void> _loadTips() async {
    final tips = widget.tipType == 'training'
        ? await TipsService.getTrainingTips()
        : await TipsService.getNutritionTips();
    setState(() {
      _tips = tips;
      _loading = false;
    });
  }

  void _startAutoScroll() {
    if (!mounted) return;
    Future.delayed(Duration(seconds: widget.autoScrollSeconds), () {
      if (mounted && _tips.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % _tips.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 180.0;
      // Reserve space for title and indicators; ensure page area has a sensible minimum
      final reserved = 44.0; // title + spacing + indicators
      final pageH = max(80.0, maxH - reserved);

      if (_loading) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          height: maxH,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: AppColors.accentGreen),
              ],
            ),
          ),
        );
      }

      if (_tips.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey700,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            'Aucun conseil disponible',
            style: TextStyle(color: Colors.grey[400]),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: pageH,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _tips.length,
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] ?? 'Conseil',
                          style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            tip['content'] ?? '',
                            style: const TextStyle(
                              color: AppColors.offWhite,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1}/${_tips.length}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            Wrap(
                              spacing: 4,
                              children: List.generate(
                                _tips.length,
                                (i) => Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == _currentIndex
                                        ? AppColors.accentGreen
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
