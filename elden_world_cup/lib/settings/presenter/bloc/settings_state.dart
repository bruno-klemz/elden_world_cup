part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool blurPending;

  const SettingsState({this.blurPending = true});

  @override
  List<Object?> get props => [blurPending];
}
