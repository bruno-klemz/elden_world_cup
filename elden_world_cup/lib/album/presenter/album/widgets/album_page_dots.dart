import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Floating pill of dots indicating the current region page among [count].
class AlbumPageDots extends StatelessWidget {
  const AlbumPageDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  /// Total vertical space the pill occupies (height + bottom margin), used by
  /// pages as bottom inset so the last row clears it.
  static const double reservedHeight = 56;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
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
        ),
      ),
    );
  }
}
