import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../map/presenter/fullscreen_map/fullscreen_map.dart';
import '../../../theme/app_theme.dart';
import 'bloc/boss_details_bloc.dart';
import 'widgets/boss_hero.dart';
import 'widgets/combat_section.dart';
import 'widgets/loot_section.dart';
import 'widgets/map_section.dart';
import 'widgets/section_label.dart';

/// Full-screen boss details. Reads [BossDetailsBloc] from context.
///
/// Marking the boss as defeated pops the route returning the boss id, so the
/// album (the registry UI) is the place that plays the reveal animation.
class BossDetailsView extends StatelessWidget {
  const BossDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<BossDetailsBloc, BossDetailsState>(
        listenWhen: (prev, curr) => curr.justRevealed && !prev.justRevealed,
        listener: (context, state) =>
            Navigator.of(context).pop(state.boss.id),
        builder: (context, state) {
          final boss = state.boss;
          final bloc = context.read<BossDetailsBloc>();
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                backgroundColor: AppColors.background,
                iconTheme: const IconThemeData(color: AppColors.goldLight),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final top = constraints.biggest.height;
                    final collapsed = top <=
                        kToolbarHeight + MediaQuery.of(context).padding.top + 8;
                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: collapsed ? 1 : 0,
                        child: Text(boss.name,
                            style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ),
                      background: BossHero(boss: boss, defeated: state.isDefeated),
                    );
                  },
                ),
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('📍 Onde encontrar'),
                        MapSection(
                          boss: boss,
                          revealed: state.isMapRevealed,
                          onReveal: () => bloc.add(const BossMapRevealed()),
                          onHide: () => bloc.add(const BossMapHidden()),
                          onOpenFullscreen: () =>
                              FullscreenMap.show(context, boss),
                        ),
                        const SectionLabel('⚔️ Combate'),
                        CombatSection(
                            strongVs: boss.strongVs, weakTo: boss.weakTo),
                        const SectionLabel('💎 Loot'),
                        LootSection(loot: boss.loot),
                        const SectionLabel('📖 Lore'),
                        Text(boss.lore, style: AppText.lore),
                        const SizedBox(height: 20),
                        _ActionButton(
                          defeated: state.isDefeated,
                          onToggle: () => bloc.add(const BossDefeatToggled()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.defeated, required this.onToggle});
  final bool defeated;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (!defeated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onToggle,
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
        onPressed: onToggle,
        child: const Text('Desmarcar',
            style: TextStyle(color: Color(0xFF6B5D44), fontSize: 12)),
      ),
    ]);
  }
}
