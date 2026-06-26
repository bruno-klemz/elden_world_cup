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
