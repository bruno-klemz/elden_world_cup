import 'package:bloc_test/bloc_test.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';
import 'package:elden_world_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:elden_world_cup/boss/domain/usecase/set_map_revealed_usecase.dart';
import 'package:elden_world_cup/boss/domain/usecase/toggle_defeated_usecase.dart';
import 'package:elden_world_cup/boss/presenter/boss_details/bloc/boss_details_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

class _MockToggleDefeated extends Mock implements ToggleDefeatedUsecase {}

class _MockSetMapRevealed extends Mock implements SetMapRevealedUsecase {}

const _boss = Boss(
  id: 'malenia',
  name: 'Malenia',
  region: 'haligtree',
  art: 'a.webp',
  locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4),
  lore: 'l',
);

void main() {
  late _MockLoadProgress loadProgress;
  late _MockToggleDefeated toggleDefeated;
  late _MockSetMapRevealed setMapRevealed;

  setUpAll(() {
    registerFallbackValue(const Progress());
  });

  setUp(() {
    loadProgress = _MockLoadProgress();
    toggleDefeated = _MockToggleDefeated();
    setMapRevealed = _MockSetMapRevealed();
  });

  BossDetailsBloc build() => BossDetailsBloc(
        boss: _boss,
        loadProgress: loadProgress,
        toggleDefeated: toggleDefeated,
        setMapRevealed: setMapRevealed,
      );

  blocTest<BossDetailsBloc, BossDetailsState>(
    'BossDefeatToggled marks defeated and flags justRevealed',
    setUp: () {
      when(() => toggleDefeated(any(), any()))
          .thenAnswer((_) async => const Progress(defeated: {'malenia'}));
    },
    build: build,
    act: (bloc) => bloc.add(const BossDefeatToggled()),
    expect: () => [
      isA<BossDetailsState>()
          .having((s) => s.isDefeated, 'isDefeated', true)
          .having((s) => s.justRevealed, 'justRevealed', true),
    ],
  );

  blocTest<BossDetailsBloc, BossDetailsState>(
    'BossMapRevealed reveals the map without firing the defeat reveal',
    setUp: () {
      when(() => setMapRevealed(any(), any(), revealed: any(named: 'revealed')))
          .thenAnswer((_) async => const Progress(revealedMap: {'malenia'}));
    },
    build: build,
    act: (bloc) => bloc.add(const BossMapRevealed()),
    expect: () => [
      isA<BossDetailsState>()
          .having((s) => s.isMapRevealed, 'isMapRevealed', true)
          .having((s) => s.justRevealed, 'justRevealed', false),
    ],
  );
}
