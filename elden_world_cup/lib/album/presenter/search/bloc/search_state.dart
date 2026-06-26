part of 'search_bloc.dart';

class SearchState extends Equatable {
  final AlbumData? data;
  final Progress progress;
  final SearchTab tab;
  final String query;
  final bool loaded;

  const SearchState({
    this.data,
    this.progress = const Progress(),
    this.tab = SearchTab.regions,
    this.query = '',
    this.loaded = false,
  });

  int regionCount() => data?.regions.length ?? 0;
  int bossCount() => data?.bosses.length ?? 0;

  int defeatedIn(String regionId) => progress.defeatedCountIn(
      (data?.bossesIn(regionId) ?? const []).map((b) => b.id));

  /// Regions sorted by most defeated (desc); ties keep the game order.
  List<Region> regions() {
    final list = [...?data?.regions];
    list.sort((a, b) {
      final byDefeated = defeatedIn(b.id).compareTo(defeatedIn(a.id));
      if (byDefeated != 0) return byDefeated;
      return a.order.compareTo(b.order);
    });
    return list.where((r) => searchMatches(r.name, query)).toList();
  }

  /// Main bosses (A-Z) followed by the rest (A-Z), filtered by query.
  List<Boss> mainBosses() => _sortedBosses(mainOnly: true);
  List<Boss> otherBosses() => _sortedBosses(mainOnly: false);

  List<Boss> _sortedBosses({required bool mainOnly}) {
    final all = [...?data?.bosses]
        .where((b) => b.isMainBoss == mainOnly)
        .where((b) => searchMatches(b.name, query))
        .toList()
      ..sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return all;
  }

  bool isDefeated(String bossId) => progress.isDefeated(bossId);
  String regionName(String regionId) =>
      data?.regions.firstWhere((r) => r.id == regionId).name ?? regionId;

  SearchState copyWith({
    AlbumData? data,
    Progress? progress,
    SearchTab? tab,
    String? query,
    bool? loaded,
  }) {
    return SearchState(
      data: data ?? this.data,
      progress: progress ?? this.progress,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => [data, progress, tab, query, loaded];
}
