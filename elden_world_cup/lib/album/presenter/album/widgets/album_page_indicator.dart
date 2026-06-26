import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Floating pill showing the current region position as "current/total",
/// sitting above a bottom scrim that fades the scrolling content into the
/// scaffold background so nothing shows vividly behind it. Scales to any number
/// of regions (unlike a row of dots).
class AlbumPageIndicator extends StatelessWidget {
  const AlbumPageIndicator({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${currentIndex + 1}',
              style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: ' / $count',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      );
}
