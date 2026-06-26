import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Floating pill of dots indicating the current region page among [count],
/// sitting above a bottom scrim that fades the scrolling content into the
/// scaffold background so nothing shows vividly behind it.
class AlbumPageDots extends StatelessWidget {
  const AlbumPageDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  /// Vertical space the pill + its margin occupies, used by pages as bottom
  /// inset so the last row clears it.
  static const double reservedHeight = 76;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return IgnorePointer(
      child: Container(
        // full-width scrim: transparent at top -> background at the bottom
        padding: EdgeInsets.only(top: 40, bottom: 16 + safeBottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: _pill(),
        ),
      ),
    );
  }

  Widget _pill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: i == 0 ? 0 : 7),
                width: i == currentIndex ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? AppColors.gold
                      : const Color(0xFF5A4C34),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      );
}
