part of 'album_bloc.dart';

enum AlbumStatus { initial, loading, loaded }

class AlbumState extends Equatable {
  final AlbumStatus status;
  final AlbumData? data;
  final Progress progress;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.data,
    this.progress = const Progress(),
  });

  bool get isLoaded => status == AlbumStatus.loaded && data != null;

  List<Region> get regions => data?.regions ?? const [];
  int get totalBosses => data?.bosses.length ?? 0;
  int get totalDefeated => progress.defeated.length;

  List<Boss> bossesIn(String regionId) => data?.bossesIn(regionId) ?? const [];
  int countIn(String regionId) => bossesIn(regionId).length;
  int defeatedIn(String regionId) =>
      progress.defeatedCountIn(bossesIn(regionId).map((b) => b.id));

  bool isDefeated(String id) => progress.isDefeated(id);

  AlbumState copyWith({
    AlbumStatus? status,
    AlbumData? data,
    Progress? progress,
  }) {
    return AlbumState(
      status: status ?? this.status,
      data: data ?? this.data,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [status, data, progress];
}
