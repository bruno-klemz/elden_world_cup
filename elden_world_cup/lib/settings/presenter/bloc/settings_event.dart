part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the persisted settings on startup.
class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

/// Flips the blur-pending preference and persists it.
class SettingsBlurToggled extends SettingsEvent {
  const SettingsBlurToggled();
}
