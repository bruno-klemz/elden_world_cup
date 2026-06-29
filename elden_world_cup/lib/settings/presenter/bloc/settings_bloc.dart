import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/load_settings_usecase.dart';
import '../../domain/usecase/set_blur_pending_usecase.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LoadSettingsUsecase _loadSettings;
  final SetBlurPendingUsecase _setBlurPending;

  SettingsBloc({
    required LoadSettingsUsecase loadSettings,
    required SetBlurPendingUsecase setBlurPending,
  })  : _loadSettings = loadSettings,
        _setBlurPending = setBlurPending,
        super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsBlurToggled>(_onBlurToggled);
  }

  Future<void> _onStarted(
      SettingsStarted event, Emitter<SettingsState> emit) async {
    final settings = await _loadSettings();
    emit(SettingsState(blurPending: settings.blurPending));
  }

  Future<void> _onBlurToggled(
      SettingsBlurToggled event, Emitter<SettingsState> emit) async {
    final next = !state.blurPending;
    final settings = await _setBlurPending(blurPending: next);
    emit(SettingsState(blurPending: settings.blurPending));
  }
}
