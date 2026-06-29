import 'package:elden_world_cup/album/data/repository/boss_repository_impl.dart';
import 'package:elden_world_cup/album/domain/repository/boss_repository.dart';
import 'package:elden_world_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:elden_world_cup/album/presenter/album/album_screen.dart';
import 'package:elden_world_cup/boss/data/repository/progress_repository_impl.dart';
import 'package:elden_world_cup/boss/domain/repository/progress_repository.dart';
import 'package:elden_world_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:elden_world_cup/boss/domain/usecase/set_map_revealed_usecase.dart';
import 'package:elden_world_cup/boss/domain/usecase/toggle_defeated_usecase.dart';
import 'package:elden_world_cup/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/settings_bloc_harness.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[{"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
   "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Register the dependency graph with an in-memory boss repository.
    locator.reset();
    locator.registerLazySingleton<BossRepository>(
        () => BossRepositoryImpl.withLoader((_) async => _json));
    locator.registerLazySingleton<ProgressRepository>(
        () => ProgressRepositoryImpl());
    locator.registerFactory<LoadAlbumUsecase>(
        () => LoadAlbumUsecaseImpl(repository: locator<BossRepository>()));
    locator.registerFactory<LoadProgressUsecase>(() =>
        LoadProgressUsecaseImpl(repository: locator<ProgressRepository>()));
    locator.registerFactory<ToggleDefeatedUsecase>(() =>
        ToggleDefeatedUsecaseImpl(repository: locator<ProgressRepository>()));
    locator.registerFactory<SetMapRevealedUsecase>(() =>
        SetMapRevealedUsecaseImpl(repository: locator<ProgressRepository>()));
  });

  tearDown(() => locator.reset());

  testWidgets('app boots into album with content', (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: withSettings(const AlbumScreen())));
    await tester.pumpAndSettle();

    // first region page shows the region name and its bosses
    expect(find.text('Limgrave'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
  });
}
