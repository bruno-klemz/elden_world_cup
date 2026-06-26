import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/region.dart';
import 'sticker_slot.dart';

/// A single self-contained album page for one region: a collapsing header
/// (region name + progress) over a scrollable grid of sticker slots.
class RegionPage extends StatelessWidget {
  const RegionPage({
    super.key,
    required this.region,
    required this.bosses,
    required this.defeatedCount,
    required this.isDefeated,
    required this.onBossTap,
    required this.onQuickDefeat,
    this.revealBossId,
    this.onRevealDone,
    this.slotKeyFor,
    this.bottomInset = 0,
  });

  final Region region;
  final List<Boss> bosses;
  final int defeatedCount;
  final bool Function(String bossId) isDefeated;
  final void Function(Boss) onBossTap;
  final void Function(Boss) onQuickDefeat;

  final String? revealBossId;
  final VoidCallback? onRevealDone;
  final GlobalKey Function(String bossId)? slotKeyFor;

  /// Extra bottom padding so the last row clears the floating dots pill.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final total = bosses.length;
    final pct = total == 0 ? 0.0 : defeatedCount / total;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 132,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.surface,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final top = constraints.biggest.height;
              final collapsed =
                  top <= kToolbarHeight + MediaQuery.of(context).padding.top + 8;
              return FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: collapsed ? 1 : 0,
                  child: Text('${region.name}  ·  $defeatedCount/$total',
                      style: AppText.regionLabel),
                ),
                background: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, MediaQuery.of(context).padding.top + 18, 16, 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(region.name,
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5)),
                      const SizedBox(height: 4),
                      Text('$defeatedCount de $total derrotados',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 11),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceAlt,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottomInset),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final boss = bosses[i];
                return StickerSlot(
                  key: slotKeyFor?.call(boss.id),
                  boss: boss,
                  defeated: isDefeated(boss.id),
                  animateReveal: boss.id == revealBossId,
                  onRevealDone: boss.id == revealBossId ? onRevealDone : null,
                  onTap: () => onBossTap(boss),
                  onQuickDefeat: () => onQuickDefeat(boss),
                );
              },
              childCount: bosses.length,
            ),
          ),
        ),
      ],
    );
  }
}
