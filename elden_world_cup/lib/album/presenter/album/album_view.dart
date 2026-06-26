import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/presenter/boss_details/boss_details_screen.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/boss.dart';
import 'bloc/album_bloc.dart';
import 'widgets/progress_header.dart';
import 'widgets/region_section.dart';

/// Pure UI for the album. Reads [AlbumBloc] from context.
class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final _scrollController = ScrollController();
  final _slotKeys = <String, GlobalKey>{};

  GlobalKey _slotKeyFor(String bossId) =>
      _slotKeys.putIfAbsent(bossId, () => GlobalKey());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openBoss(BuildContext context, Boss boss) async {
    final defeatedId = await BossDetailsScreen.push(context, boss);
    if (!context.mounted) return;
    final bloc = context.read<AlbumBloc>();
    bloc.add(const AlbumProgressRefreshed());
    if (defeatedId != null) {
      bloc.add(AlbumRevealRequested(defeatedId));
    }
  }

  Future<void> _scrollToSlot(String bossId) async {
    final key = _slotKeys[bossId];
    final ctx = key?.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        alignment: 0.3,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AlbumBloc, AlbumState>(
        listenWhen: (prev, curr) =>
            curr.justRevealedBossId != null &&
            curr.justRevealedBossId != prev.justRevealedBossId,
        listener: (context, state) {
          // Scroll to the freshly defeated slot so its reveal is always seen.
          final id = state.justRevealedBossId;
          if (id != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToSlot(id));
          }
        },
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: ProgressHeader(
                      defeated: state.totalDefeated, total: state.totalBosses),
                ),
                for (final region in state.regions)
                  SliverToBoxAdapter(
                    child: RegionSection(
                      region: region,
                      bosses: state.bossesIn(region.id),
                      defeatedCount: state.defeatedIn(region.id),
                      isDefeated: state.isDefeated,
                      revealBossId: state.justRevealedBossId,
                      slotKeyFor: _slotKeyFor,
                      onRevealDone: () =>
                          context.read<AlbumBloc>().add(const AlbumRevealConsumed()),
                      onBossTap: (boss) => _openBoss(context, boss),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
