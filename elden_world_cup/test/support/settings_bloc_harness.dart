import 'package:elden_world_cup/settings/domain/entity/settings.dart';
import 'package:elden_world_cup/settings/domain/usecase/load_settings_usecase.dart';
import 'package:elden_world_cup/settings/domain/usecase/set_blur_pending_usecase.dart';
import 'package:elden_world_cup/settings/presenter/bloc/settings_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _FakeLoad implements LoadSettingsUsecase {
  _FakeLoad(this.value);
  final bool value;
  @override
  Future<Settings> call() async => Settings(blurPending: value);
}

class _FakeSetBlur implements SetBlurPendingUsecase {
  @override
  Future<Settings> call({required bool blurPending}) async =>
      Settings(blurPending: blurPending);
}

/// Wraps [child] with a real [SettingsBloc] seeded to [blurPending], for widget
/// tests of anything that renders [PendingArt] under the global settings bloc.
Widget withSettings(Widget child, {bool blurPending = true}) {
  final bloc = SettingsBloc(
    loadSettings: _FakeLoad(blurPending),
    setBlurPending: _FakeSetBlur(),
  )..add(const SettingsStarted());
  return BlocProvider.value(value: bloc, child: child);
}
