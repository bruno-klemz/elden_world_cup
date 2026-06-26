import 'package:flutter/material.dart';
import '../presentation/theme/app_theme.dart';

/// DEV-ONLY: tap the base map to read a boss's relative (x,y) coordinate.
/// Not wired into the shipped app. To use temporarily, set
/// `home: const CoordPickerScreen()` in main.dart.
class CoordPickerScreen extends StatelessWidget {
  const CoordPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Coord Picker (dev)')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              final x = (details.localPosition.dx / constraints.maxWidth)
                  .clamp(0.0, 1.0);
              final y = (details.localPosition.dy / constraints.maxHeight)
                  .clamp(0.0, 1.0);
              final text =
                  '"mapCoord": { "x": ${x.toStringAsFixed(3)}, "y": ${y.toStringAsFixed(3)} }';
              debugPrint(text);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(text)));
            },
            child: Image.asset('assets/images/map/base_map.webp',
                fit: BoxFit.cover,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                errorBuilder: (context, error, stack) => const Center(
                    child: Text('base_map.webp ausente (placeholder)',
                        style: TextStyle(color: AppColors.textMuted)))),
          );
        },
      ),
    );
  }
}
