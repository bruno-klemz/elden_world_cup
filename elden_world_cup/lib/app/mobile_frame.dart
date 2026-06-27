import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Wraps the app in a centered phone-width column on web, so the UI keeps its
/// intended mobile proportions instead of stretching across a wide browser
/// window. On native platforms the child is returned untouched.
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child, this.isWeb = kIsWeb});

  final Widget child;

  /// Injectable so both the web and native paths are testable.
  final bool isWeb;

  /// Phone-width cap, in logical pixels (iPhone Pro Max class).
  static const double maxWidth = 430;

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return child;
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
