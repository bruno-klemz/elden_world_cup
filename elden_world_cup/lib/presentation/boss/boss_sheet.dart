import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/boss.dart';
import '../../state/album_controller.dart';
import '../map/fullscreen_map.dart';
import '../theme/app_theme.dart';
import 'widgets/boss_hero.dart';
import 'widgets/combat_section.dart';
import 'widgets/loot_section.dart';
import 'widgets/map_section.dart';
import 'widgets/reveal_overlay.dart';
import 'widgets/section_label.dart';

class BossSheet extends StatefulWidget {
  const BossSheet({super.key, required this.boss});
  final Boss boss;

  static Future<void> show(BuildContext context, Boss boss) {
    final controller = context.read<AlbumController>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: BossSheet(boss: boss),
        ),
      ),
    );
  }

  @override
  State<BossSheet> createState() => _BossSheetState();
}

class _BossSheetState extends State<BossSheet> {
  bool _playReveal = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlbumController>();
    final boss = widget.boss;
    final defeated = c.isDefeated(boss.id);
    final mapRevealed = c.isMapRevealed(boss.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.goldLight),
          title: Text(boss.name,
              style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          flexibleSpace: FlexibleSpaceBar(
            background: RevealOverlay(
              play: _playReveal,
              onDone: () => setState(() => _playReveal = false),
              child: BossHero(boss: boss, defeated: defeated),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('📍 Onde encontrar'),
                MapSection(
                  boss: boss,
                  revealed: mapRevealed,
                  onReveal: () => c.revealMap(boss.id),
                  onHide: () => c.hideMap(boss.id),
                  onOpenFullscreen: () => FullscreenMap.show(context, boss),
                ),
                const SectionLabel('⚔️ Combate'),
                CombatSection(strongVs: boss.strongVs, weakTo: boss.weakTo),
                const SectionLabel('💎 Loot'),
                LootSection(loot: boss.loot),
                const SectionLabel('📖 Lore'),
                Text(boss.lore, style: AppText.lore),
                const SizedBox(height: 20),
                _actionButton(c, defeated),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(AlbumController c, bool defeated) {
    if (!defeated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await c.toggleDefeated(widget.boss.id);
            setState(() => _playReveal = true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('⚔️ Marcar como derrotado',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      );
    }
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('✓ Conquista registrada',
              style: TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ),
      ),
      TextButton(
        onPressed: () => c.toggleDefeated(widget.boss.id),
        child: const Text('Desmarcar',
            style: TextStyle(color: Color(0xFF6B5D44), fontSize: 12)),
      ),
    ]);
  }
}
