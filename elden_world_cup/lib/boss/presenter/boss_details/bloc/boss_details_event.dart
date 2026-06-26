part of 'boss_details_bloc.dart';

sealed class BossDetailsEvent extends Equatable {
  const BossDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the current progress for this boss.
class BossDetailsStarted extends BossDetailsEvent {
  const BossDetailsStarted();
}

/// Marks/unmarks the boss as defeated.
class BossDefeatToggled extends BossDetailsEvent {
  const BossDefeatToggled();
}

/// Reveals the spoiler-protected map for this boss.
class BossMapRevealed extends BossDetailsEvent {
  const BossMapRevealed();
}

/// Hides the map again for this boss.
class BossMapHidden extends BossDetailsEvent {
  const BossMapHidden();
}
