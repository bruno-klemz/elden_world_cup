import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/models/boss.dart';
import '../../theme/app_theme.dart';

// Standard luminance grayscale matrix for ColorFilter.matrix.
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

class StickerSlot extends StatelessWidget {
  const StickerSlot({
    super.key,
    required this.boss,
    required this.defeated,
    required this.onTap,
  });

  final Boss boss;
  final bool defeated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: defeated ? AppColors.gold : AppColors.border,
                width: defeated ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _art(),
                if (defeated)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      key: const Key('slot-check'),
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: AppColors.gold, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          size: 11, color: AppColors.background),
                    ),
                  ),
                _nameStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _art() {
    final image = Image.asset('assets/${boss.art}',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
        errorBuilder: (context, error, stack) =>
            Container(color: AppColors.surfaceAlt));
    if (defeated) return image;
    // pending: grayscale + blur + darken
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.45), BlendMode.darken),
          child: image,
        ),
      ),
    );
  }

  Widget _nameStrip() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(3, 12, 3, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
            ),
          ),
          child: Text(boss.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.slotName.copyWith(
                  color: defeated
                      ? AppColors.goldLight
                      : const Color(0xFF9A8A66))),
        ),
      );
}
