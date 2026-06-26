import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/presenter/boss_details/boss_details_screen.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/boss.dart';
import '../search/search_result.dart';
import '../search/search_screen.dart';
import 'bloc/album_bloc.dart';
import 'widgets/album_page_indicator.dart';
import 'widgets/region_page.dart';

/// Pure UI for the album. Reads [AlbumBloc] from context.
///
/// Each region is a page; the user flips horizontally between them.
class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final _pageController = PageController();
  final _slotKeys = <String, GlobalKey>{};
  int _currentPage = 0;

  GlobalKey _slotKeyFor(String bossId) =>
      _slotKeys.putIfAbsent(bossId, () => GlobalKey());

  @override
  void dispose() {
    _pageController.dispose();
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

  /// Flips to the region of [bossId], then scrolls its slot into view so the
  /// reveal animation is always seen.
  Future<void> _goToRevealedSlot(AlbumState state, String bossId) async {
    final regionId = state.data?.bossById(bossId).region;
    if (regionId == null) return;
    await _animateToRegion(state, regionId);
    if (mounted) _ensureSlotVisible(bossId);
  }

  /// Resolves the slot's context fresh (after any page change) and scrolls to
  /// it. No await before the context use, so it's always current.
  void _ensureSlotVisible(String bossId) {
    final ctx = _slotKeys[bossId]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      alignment: 0.3,
    );
  }

  Future<void> _animateToRegion(AlbumState state, String regionId) async {
    final pageIndex = state.regions.indexWhere((r) => r.id == regionId);
    if (pageIndex >= 0 && _pageController.hasClients) {
      await _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openSearch(BuildContext context, AlbumState state) async {
    final result = await SearchScreen.push(context);
    if (result == null || !context.mounted) return;
    switch (result) {
      case RegionResult(:final regionId):
        await _animateToRegion(state, regionId);
      case BossResult(:final regionId, :final bossId):
        await _animateToRegion(state, regionId);
        if (mounted) _ensureSlotVisible(bossId);
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
          final id = state.justRevealedBossId;
          if (id != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _goToRevealedSlot(state, id));
          }
        },
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }
          final regions = state.regions;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: regions.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final region = regions[i];
                  return RegionPage(
                    region: region,
                    mainBosses: state.mainBossesIn(region.id),
                    otherBosses: state.otherBossesIn(region.id),
                    defeatedCount: state.defeatedIn(region.id),
                    totalCount: state.countIn(region.id),
                    isDefeated: state.isDefeated,
                    revealBossId: state.justRevealedBossId,
                    slotKeyFor: _slotKeyFor,
                    bottomInset: AlbumPageIndicator.reservedHeight,
                    onRevealDone: () =>
                        context.read<AlbumBloc>().add(const AlbumRevealConsumed()),
                    onBossTap: (boss) => _openBoss(context, boss),
                    onQuickDefeat: (boss) => context
                        .read<AlbumBloc>()
                        .add(AlbumBossQuickDefeated(boss.id)),
                  );
                },
              ),
              if (regions.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AlbumPageIndicator(
                      count: regions.length, currentIndex: _currentPage),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _SearchButton(
                        onTap: () => _openSearch(context, state)),
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

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.search, color: AppColors.goldLight, size: 19),
      ),
    );
  }
}
