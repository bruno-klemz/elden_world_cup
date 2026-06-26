import 'package:flutter/material.dart';
import '../../../album/domain/entity/boss.dart';
import '../../../theme/app_theme.dart';

class FullscreenMap extends StatelessWidget {
  const FullscreenMap({super.key, required this.boss});
  final Boss boss;

  static Future<void> show(BuildContext context, Boss boss) =>
      Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true, builder: (_) => FullscreenMap(boss: boss)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Image.asset('assets/images/map/base_map.webp',
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          errorBuilder: (context, error, stack) =>
                              Container(color: const Color(0xFF14201A))),
                      Positioned(
                        left: boss.mapCoord.x * constraints.maxWidth - 14,
                        top: boss.mapCoord.y * constraints.maxHeight - 28,
                        child:
                            const Text('📍', style: TextStyle(fontSize: 28)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.goldLight),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text('Localização de ${boss.name}',
                    style: const TextStyle(
                        color: AppColors.goldLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
