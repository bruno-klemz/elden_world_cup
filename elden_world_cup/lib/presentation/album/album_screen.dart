import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/boss.dart';
import '../../state/album_controller.dart';
import '../boss/boss_sheet.dart';
import '../theme/app_theme.dart';
import 'widgets/progress_header.dart';
import 'widgets/region_section.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key, this.onBossTap});

  /// Injection seam for tests; when null, taps are wired to BossSheet in Task 12.
  final void Function(BuildContext, Boss)? onBossTap;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlbumController>();
    if (!c.isLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProgressHeader(
                  defeated: c.totalDefeated, total: c.totalBosses),
            ),
            for (final region in c.regions)
              SliverToBoxAdapter(
                child: RegionSection(
                  region: region,
                  bosses: c.data.bossesIn(region.id),
                  controller: c,
                  onBossTap: (boss) =>
                      (onBossTap ?? (ctx, b) => BossSheet.show(ctx, b))
                          .call(context, boss),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
