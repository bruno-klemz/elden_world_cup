import 'package:elden_world_cup/album/domain/entity/album_data.dart';
import 'package:elden_world_cup/album/domain/entity/boss.dart';
import 'package:elden_world_cup/album/domain/entity/map_coord.dart';
import 'package:elden_world_cup/album/domain/entity/region.dart';
import 'package:elden_world_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:elden_world_cup/album/presenter/search/bloc/search_bloc.dart';
import 'package:elden_world_cup/album/presenter/search/search_result.dart';
import 'package:elden_world_cup/album/presenter/search/search_view.dart';
import 'package:elden_world_cup/boss/domain/entity/progress.dart';
import 'package:elden_world_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadAlbum extends Mock implements LoadAlbumUsecase {}

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

final _data = AlbumData(
  regions: const [Region(id: 'limgrave', name: 'Limgrave', order: 1)],
  bosses: [
    const Boss(
        id: 'godrick',
        name: 'Godrick',
        region: 'limgrave',
        art: 'a.webp',
        locationName: 'loc',
        mapCoord: MapCoord(0, 0),
        lore: '',
        mainOrder: 1),
  ],
);

SearchBloc _makeBloc() {
  final la = _MockLoadAlbum();
  final lp = _MockLoadProgress();
  when(() => la()).thenAnswer((_) async => _data);
  when(() => lp()).thenAnswer((_) async => const Progress());
  return SearchBloc(loadAlbum: la, loadProgress: lp)..add(const SearchStarted());
}

void main() {
  testWidgets('regions tab shows regions; switching to bosses shows bosses',
      (tester) async {
    final bloc = _makeBloc();
    await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(value: bloc, child: const SearchView())));
    await tester.pumpAndSettle();

    expect(find.text('Limgrave'), findsWidgets);

    await tester.tap(find.textContaining('Bosses'));
    await tester.pumpAndSettle();
    expect(find.text('★ Principais'), findsOneWidget);
    expect(find.textContaining('Godrick'), findsOneWidget);
  });

  testWidgets('pending main boss shows no crown in search', (tester) async {
    final bloc = _makeBloc(); // empty progress -> Godrick pending
    await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(value: bloc, child: const SearchView())));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Bosses'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Godrick'), findsOneWidget);
    expect(find.textContaining('👑'), findsNothing); // crown only when defeated
  });

  testWidgets('tapping a region pops with RegionResult', (tester) async {
    final bloc = _makeBloc();
    SearchResult? popped;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                popped = await Navigator.of(context).push<SearchResult>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                        value: bloc, child: const SearchView()),
                  ),
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Limgrave').first);
    await tester.pumpAndSettle();

    expect(popped, isA<RegionResult>());
    expect((popped! as RegionResult).regionId, 'limgrave');
  });
}
