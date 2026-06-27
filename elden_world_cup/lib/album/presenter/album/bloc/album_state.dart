part of 'album_bloc.dart';

enum AlbumStatus { initial, loading, loaded }

class AlbumState extends Equatable {
  final AlbumStatus status;
  final AlbumData? data;
  final Progress progress;

  /// Id of a boss whose slot should play the reveal animation. Null once
  /// consumed.
  final String? justRevealedBossId;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.data,
    this.progress = const Progress(),
    this.justRevealedBossId,
  });

  bool get isLoaded => status == AlbumStatus.loaded && data != null;

  List<Region> get regions => data?.regions ?? const [];
  int get totalBosses => data?.bosses.length ?? 0;
  int get totalDefeated => progress.defeated.length;

  List<Boss> bossesIn(String regionId) => data?.bossesIn(regionId) ?? const [];
  int countIn(String regionId) => bossesIn(regionId).length;
  int defeatedIn(String regionId) =>
      progress.defeatedCountIn(bossesIn(regionId).map((b) => b.id));

  /// Headline bosses of a region, ordered by mainOrder (left to right).
  List<Boss> mainBossesIn(String regionId) =>
      bossesIn(regionId).where((b) => b.isMainBoss).toList()
        ..sort((a, b) => a.mainOrder.compareTo(b.mainOrder));

  /// Non-headline bosses of a region, sorted alphabetically (case-insensitive).
  List<Boss> otherBossesIn(String regionId) =>
      bossesIn(regionId).where((b) => !b.isMainBoss).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  bool isDefeated(String id) => progress.isDefeated(id);

  AlbumState copyWith({
    AlbumStatus? status,
    AlbumData? data,
    Progress? progress,
    String? justRevealedBossId,
    bool clearReveal = false,
  }) {
    return AlbumState(
      status: status ?? this.status,
      data: data ?? this.data,
      progress: progress ?? this.progress,
      justRevealedBossId:
          clearReveal ? null : (justRevealedBossId ?? this.justRevealedBossId),
    );
  }

  @override
  List<Object?> get props => [status, data, progress, justRevealedBossId];
}
