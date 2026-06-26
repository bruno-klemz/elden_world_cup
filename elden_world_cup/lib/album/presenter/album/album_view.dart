import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/presenter/boss_details/boss_details_screen.dart';
import '../../../theme/app_theme.dart';
import 'bloc/album_bloc.dart';
import 'widgets/progress_header.dart';
import 'widgets/region_section.dart';

/// Pure UI for the album. Reads [AlbumBloc] from context.
class AlbumView extends StatelessWidget {
  const AlbumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
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
                      onBossTap: (boss) async {
                        await BossDetailsScreen.push(context, boss);
                        if (context.mounted) {
                          context
                              .read<AlbumBloc>()
                              .add(const AlbumProgressRefreshed());
                        }
                      },
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
