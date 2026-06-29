import 'package:elden_world_cup/settings/domain/entity/settings.dart';
import 'package:elden_world_cup/settings/domain/repository/settings_repository.dart';
import 'package:elden_world_cup/settings/domain/usecase/load_settings_usecase.dart';
import 'package:elden_world_cup/settings/domain/usecase/set_blur_pending_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements SettingsRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const Settings()));

  late _MockRepo repo;

  setUp(() => repo = _MockRepo());

  test('LoadSettingsUsecase returns the repository value', () async {
    when(() => repo.load())
        .thenAnswer((_) async => const Settings(blurPending: false));

    final result = await LoadSettingsUsecaseImpl(repository: repo)();

    expect(result.blurPending, isFalse);
  });

  test('SetBlurPendingUsecase saves and returns the new value', () async {
    when(() => repo.save(any())).thenAnswer((_) async {});

    final result =
        await SetBlurPendingUsecaseImpl(repository: repo)(blurPending: false);

    expect(result.blurPending, isFalse);
    verify(() => repo.save(const Settings(blurPending: false))).called(1);
  });
}
