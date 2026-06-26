import 'package:bloc_test/bloc_test.dart';
import 'package:elden_world_cup/album/domain/entity/album_data.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:elden_world_cup/album/presenter/search/bloc/search_bloc.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';
import 'package:elden_world_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadAlbum extends Mock implements LoadAlbumUsecase {}

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

Boss _b(String id, String name, String region, {int mainOrder = 0}) => Boss(
      id: id,
      name: name,
      region: region,
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0, 0),
      lore: '',
      mainOrder: mainOrder,
    );

final _data = AlbumData(
  regions: const [
    Region(id: 'limgrave', name: 'Limgrave', order: 1),
    Region(id: 'caelid', name: 'Caelid', order: 2),
  ],
  bosses: [
    _b('margit', 'Margit', 'limgrave', mainOrder: 1),
    _b('godrick', 'Godrick', 'limgrave', mainOrder: 2),
    _b('agheel', 'Agheel', 'limgrave'),
    _b('radahn', 'Radahn', 'caelid', mainOrder: 1),
  ],
);

void main() {
  late _MockLoadAlbum loadAlbum;
  late _MockLoadProgress loadProgress;

  setUp(() {
    loadAlbum = _MockLoadAlbum();
    loadProgress = _MockLoadProgress();
    when(() => loadAlbum()).thenAnswer((_) async => _data);
    when(() => loadProgress())
        .thenAnswer((_) async => const Progress(defeated: {'radahn'}));
  });

  SearchBloc build() =>
      SearchBloc(loadAlbum: loadAlbum, loadProgress: loadProgress);

  blocTest<SearchBloc, SearchState>(
    'regions sorted by most defeated; ties keep game order',
    build: build,
    act: (b) => b.add(const SearchStarted()),
    verify: (b) {
      // caelid has 1 defeated (radahn) -> first; limgrave 0 -> second by order
      expect(b.state.regions().map((r) => r.id).toList(), ['caelid', 'limgrave']);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'bosses: mains A-Z then others A-Z',
    build: build,
    act: (b) => b.add(const SearchStarted()),
    verify: (b) {
      expect(b.state.mainBosses().map((x) => x.name).toList(),
          ['Godrick', 'Margit', 'Radahn']); // A-Z across all mains
      expect(b.state.otherBosses().map((x) => x.name).toList(), ['Agheel']);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'query filters the lists (diacritic-insensitive)',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchQueryChanged('rad'));
    },
    verify: (b) {
      expect(b.state.regions(), isEmpty);
      expect(b.state.mainBosses().map((x) => x.name).toList(), ['Radahn']);
      expect(b.state.otherBosses(), isEmpty);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'tab change keeps the query',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchQueryChanged('rad'));
      b.add(const SearchTabChanged(SearchTab.bosses));
    },
    verify: (b) {
      expect(b.state.tab, SearchTab.bosses);
      expect(b.state.query, 'rad');
    },
  );
}
