import 'package:flutter/material.dart';
import '../../../../album/domain/entity/boss.dart';
import '../../../../shared/widgets/pending_art.dart';
import '../../../../theme/app_theme.dart';

class BossHero extends StatelessWidget {
  const BossHero({super.key, required this.boss, required this.defeated});
  final Boss boss;
  final bool defeated;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      _art(),
      const _BottomFade(),
      Positioned(
        bottom: 12,
        left: 16,
        right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(boss.name,
                style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
            if (boss.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(boss.subtitle!,
                    style: const TextStyle(
                        color: Color(0xFFC9B78F), fontSize: 12)),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget _art() {
    if (defeated) {
      return Image.asset('assets/${boss.art}',
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.6),
          errorBuilder: (context, error, stack) =>
              Container(color: AppColors.surfaceAlt));
    }
    // Pending: blur (toggleable) + darken, no grayscale.
    return PendingArt(art: boss.art, blurSigma: 9, darken: 0.5);
  }
}

class _BottomFade extends StatelessWidget {
  const _BottomFade();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.45, 1.0],
            colors: [Colors.transparent, AppColors.background],
          ),
        ),
      );
}
