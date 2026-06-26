import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/region.dart';
import 'sticker_slot.dart';

class RegionSection extends StatelessWidget {
  const RegionSection({
    super.key,
    required this.region,
    required this.bosses,
    required this.defeatedCount,
    required this.isDefeated,
    required this.onBossTap,
  });

  final Region region;
  final List<Boss> bosses;
  final int defeatedCount;
  final bool Function(String bossId) isDefeated;
  final void Function(Boss) onBossTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(region.name.toUpperCase(), style: AppText.regionLabel),
              const SizedBox(width: 8),
              const Expanded(
                  child: Divider(color: AppColors.border, height: 1)),
              const SizedBox(width: 8),
              Text('$defeatedCount/${bosses.length}',
                  style:
                      const TextStyle(color: Color(0xFF6B5D44), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
            children: [
              for (final boss in bosses)
                StickerSlot(
                  boss: boss,
                  defeated: isDefeated(boss.id),
                  onTap: () => onBossTap(boss),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
