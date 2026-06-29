import 'package:bloc_test/bloc_test.dart';
import 'package:elden_world_cup/settings/domain/entity/settings.dart';
import 'package:elden_world_cup/settings/domain/usecase/load_settings_usecase.dart';
import 'package:elden_world_cup/settings/domain/usecase/set_blur_pending_usecase.dart';
import 'package:elden_world_cup/settings/presenter/bloc/settings_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoad extends Mock implements LoadSettingsUsecase {}

class _MockSetBlur extends Mock implements SetBlurPendingUsecase {}

void main() {
  late _MockLoad load;
  late _MockSetBlur setBlur;

  setUp(() {
    load = _MockLoad();
    setBlur = _MockSetBlur();
  });

  SettingsBloc build() =>
      SettingsBloc(loadSettings: load, setBlurPending: setBlur);

  blocTest<SettingsBloc, SettingsState>(
    'SettingsStarted loads the persisted blurPending value',
    setUp: () => when(() => load())
        .thenAnswer((_) async => const Settings(blurPending: false)),
    build: build,
    act: (bloc) => bloc.add(const SettingsStarted()),
    expect: () => [const SettingsState(blurPending: false)],
  );

  blocTest<SettingsBloc, SettingsState>(
    'SettingsBlurToggled flips the value and persists it',
    setUp: () => when(() => setBlur(blurPending: any(named: 'blurPending')))
        .thenAnswer((_) async => const Settings(blurPending: false)),
    build: build,
    // default state starts blurPending: true
    act: (bloc) => bloc.add(const SettingsBlurToggled()),
    expect: () => [const SettingsState(blurPending: false)],
    verify: (_) =>
        verify(() => setBlur(blurPending: false)).called(1),
  );
}
