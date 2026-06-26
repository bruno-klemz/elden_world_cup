import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../album/domain/entity/boss.dart';
import '../../../../theme/app_theme.dart';

class MapSection extends StatelessWidget {
  const MapSection({
    super.key,
    required this.boss,
    required this.revealed,
    required this.onReveal,
    required this.onHide,
    required this.onOpenFullscreen,
  });

  final Boss boss;
  final bool revealed;
  final VoidCallback onReveal;
  final VoidCallback onHide;
  final VoidCallback onOpenFullscreen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(fit: StackFit.expand, children: [
          _baseMap(),
          if (!revealed) _locked() else _revealedOverlay(),
        ]),
      ),
    );
  }

  Widget _baseMap() {
    final img = Image.asset('assets/images/map/base_map.webp',
        fit: BoxFit.cover,
        alignment: Alignment(boss.mapCoord.x * 2 - 1, boss.mapCoord.y * 2 - 1),
        errorBuilder: (context, error, stack) =>
            Container(color: const Color(0xFF14201A)));
    if (revealed) return img;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5), BlendMode.darken),
        child: img,
      ),
    );
  }

  Widget _locked() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Localização oculta para evitar spoiler',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFC9B78F),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onReveal,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.background),
              child: const Text('👁 Revelar mapa',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ],
        ),
      );

  Widget _revealedOverlay() => Stack(children: [
        const Center(child: Text('📍', style: TextStyle(fontSize: 26))),
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: onHide,
            child: _chip('🔒 Ocultar', muted: true),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onOpenFullscreen,
            child: _chip('⤢ Ampliar'),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 18, 11, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85)
                ],
              ),
            ),
            child: Text(boss.locationName,
                style: const TextStyle(
                    color: Color(0xFFCFE0D3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]);

  Widget _chip(String text, {bool muted = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(text,
            style: TextStyle(
                color:
                    muted ? AppColors.textMuted : const Color(0xFFC9B78F),
                fontSize: 9,
                fontWeight: FontWeight.w700)),
      );
}
