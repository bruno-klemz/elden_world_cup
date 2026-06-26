part of 'album_bloc.dart';

sealed class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

/// Loads boss content and the persisted progress.
class AlbumStarted extends AlbumEvent {
  const AlbumStarted();
}

/// Reloads progress (e.g. after returning from the boss details screen).
class AlbumProgressRefreshed extends AlbumEvent {
  const AlbumProgressRefreshed();
}

/// Requests the reveal animation for a freshly defeated boss's slot.
class AlbumRevealRequested extends AlbumEvent {
  final String bossId;
  const AlbumRevealRequested(this.bossId);

  @override
  List<Object?> get props => [bossId];
}

/// Clears the pending reveal once the slot animation has played.
class AlbumRevealConsumed extends AlbumEvent {
  const AlbumRevealConsumed();
}

/// Marks a boss defeated directly from the album (quick-check button) and
/// triggers the reveal on its slot. No-op if already defeated.
class AlbumBossQuickDefeated extends AlbumEvent {
  final String bossId;
  const AlbumBossQuickDefeated(this.bossId);

  @override
  List<Object?> get props => [bossId];
}
