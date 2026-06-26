import 'package:bloc_test/bloc_test.dart';
import 'package:elden_world_cup/album/domain/entity/album_data.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:elden_world_cup/album/presenter/album/bloc/album_bloc.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';
import 'package:elden_world_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadAlbum extends Mock implements LoadAlbumUsecase {}

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

final _album = AlbumData(
  regions: const [Region(id: 'limgrave', name: 'Limgrave', order: 1)],
  bosses: const [
    Boss(
        id: 'margit',
        name: 'Margit',
        region: 'limgrave',
        art: 'a.webp',
        locationName: 'loc',
        mapCoord: MapCoord(0.1, 0.2),
        lore: 'l'),
  ],
);

void main() {
  late _MockLoadAlbum loadAlbum;
  late _MockLoadProgress loadProgress;

  setUp(() {
    loadAlbum = _MockLoadAlbum();
    loadProgress = _MockLoadProgress();
  });

  AlbumBloc build() =>
      AlbumBloc(loadAlbum: loadAlbum, loadProgress: loadProgress);

  blocTest<AlbumBloc, AlbumState>(
    'AlbumStarted loads data and progress -> loaded',
    setUp: () {
      when(() => loadAlbum()).thenAnswer((_) async => _album);
      when(() => loadProgress())
          .thenAnswer((_) async => const Progress(defeated: {'margit'}));
    },
    build: build,
    act: (bloc) => bloc.add(const AlbumStarted()),
    expect: () => [
      isA<AlbumState>().having((s) => s.status, 'status', AlbumStatus.loading),
      isA<AlbumState>()
          .having((s) => s.isLoaded, 'isLoaded', true)
          .having((s) => s.totalBosses, 'totalBosses', 1)
          .having((s) => s.totalDefeated, 'totalDefeated', 1)
          .having((s) => s.defeatedIn('limgrave'), 'defeatedIn', 1),
    ],
  );

  blocTest<AlbumBloc, AlbumState>(
    'AlbumProgressRefreshed reloads only progress',
    setUp: () {
      when(() => loadAlbum()).thenAnswer((_) async => _album);
      when(() => loadProgress()).thenAnswer((_) async => const Progress());
    },
    build: build,
    seed: () => AlbumState(
        status: AlbumStatus.loaded, data: _album, progress: const Progress()),
    act: (bloc) {
      when(() => loadProgress())
          .thenAnswer((_) async => const Progress(defeated: {'margit'}));
      bloc.add(const AlbumProgressRefreshed());
    },
    expect: () => [
      isA<AlbumState>().having((s) => s.isDefeated('margit'), 'defeated', true),
    ],
  );

  blocTest<AlbumBloc, AlbumState>(
    'AlbumRevealRequested sets justRevealedBossId, Consumed clears it',
    build: build,
    seed: () =>
        const AlbumState(status: AlbumStatus.loaded, progress: Progress()),
    act: (bloc) {
      bloc.add(const AlbumRevealRequested('margit'));
      bloc.add(const AlbumRevealConsumed());
    },
    expect: () => [
      isA<AlbumState>()
          .having((s) => s.justRevealedBossId, 'revealId', 'margit'),
      isA<AlbumState>().having((s) => s.justRevealedBossId, 'revealId', null),
    ],
  );
}
