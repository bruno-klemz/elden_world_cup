import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/boss.dart';
import '../../domain/entity/region.dart';
import 'bloc/search_bloc.dart';
import 'search_result.dart';

/// Pure UI for search. Reads [SearchBloc]; pops with a [SearchResult] on tap.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        title: const Text('Buscar',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          final bloc = context.read<SearchBloc>();
          return Column(
            children: [
              _field(bloc),
              _tabs(context, state, bloc),
              Expanded(
                child: state.tab == SearchTab.regions
                    ? _regionList(context, state)
                    : _bossList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(SearchBloc bloc) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: TextField(
          autofocus: false,
          style: const TextStyle(color: AppColors.goldLight, fontSize: 14),
          cursorColor: AppColors.gold,
          onChanged: (v) => bloc.add(SearchQueryChanged(v)),
          decoration: InputDecoration(
            hintText: 'Buscar região ou boss...',
            hintStyle: const TextStyle(color: Color(0xFF6B5D44)),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      );

  Widget _tabs(BuildContext context, SearchState state, SearchBloc bloc) => Row(
        children: [
          _tab(state, bloc, SearchTab.regions, 'Regiões', state.regionCount()),
          _tab(state, bloc, SearchTab.bosses, 'Bosses', state.bossCount()),
        ],
      );

  Widget _tab(SearchState state, SearchBloc bloc, SearchTab tab, String label,
          int count) {
    final active = state.tab == tab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.add(SearchTabChanged(tab)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.gold : AppColors.border,
                width: active ? 2 : 1,
              ),
            ),
          ),
          child: Text('$label  $count',
              style: TextStyle(
                  color: active ? AppColors.gold : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _regionList(BuildContext context, SearchState state) {
    final regions = state.regions();
    if (regions.isEmpty) return const _Empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      itemCount: regions.length,
      itemBuilder: (context, i) => _regionTile(context, state, regions[i]),
    );
  }

  Widget _regionTile(BuildContext context, SearchState state, Region region) {
    final defeated = state.defeatedIn(region.id);
    final total = state.data!.bossesIn(region.id).length;
    return _tile(
      leading: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8)),
        child: const Text('🗺️', style: TextStyle(fontSize: 16)),
      ),
      title: region.name,
      subtitle: '$defeated/$total derrotados',
      onTap: () => Navigator.of(context).pop(RegionResult(region.id)),
    );
  }

  Widget _bossList(BuildContext context, SearchState state) {
    final mains = state.mainBosses();
    final others = state.otherBosses();
    if (mains.isEmpty && others.isEmpty) return const _Empty();
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      children: [
        if (mains.isNotEmpty) ...[
          _sectionLabel('★ Principais'),
          for (final b in mains) _bossTile(context, state, b),
        ],
        if (others.isNotEmpty) ...[
          _sectionLabel('Demais'),
          for (final b in others) _bossTile(context, state, b),
        ],
      ],
    );
  }

  Widget _bossTile(BuildContext context, SearchState state, Boss boss) {
    final defeated = state.isDefeated(boss.id);
    final thumb = Image.asset('assets/${boss.art}',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
        errorBuilder: (c, e, s) => Container(color: AppColors.surfaceAlt));
    return _tile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: defeated
              ? thumb
              : ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: thumb,
                ),
        ),
      ),
      // crown only once defeated (reward), name muted while pending
      title: (boss.isMainBoss && defeated) ? '${boss.name}  👑' : boss.name,
      titleColor: defeated ? AppColors.goldLight : const Color(0xFF9A8A66),
      subtitle: state.regionName(boss.region),
      onTap: () => Navigator.of(context)
          .pop(BossResult(bossId: boss.id, regionId: boss.region)),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
      );

  Widget _tile({
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppColors.goldLight,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF4A3C2A), size: 20),
            ],
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Nada encontrado',
            style: TextStyle(color: AppColors.textMuted)),
      );
}
