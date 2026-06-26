import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../boss/domain/entity/progress.dart';
import '../../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../../boss/domain/usecase/toggle_defeated_usecase.dart';
import '../../../domain/entity/album_data.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/region.dart';
import '../../../domain/usecase/load_album_usecase.dart';

part 'album_event.dart';
part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final LoadAlbumUsecase _loadAlbum;
  final LoadProgressUsecase _loadProgress;
  final ToggleDefeatedUsecase _toggleDefeated;

  AlbumBloc({
    required LoadAlbumUsecase loadAlbum,
    required LoadProgressUsecase loadProgress,
    required ToggleDefeatedUsecase toggleDefeated,
  })  : _loadAlbum = loadAlbum,
        _loadProgress = loadProgress,
        _toggleDefeated = toggleDefeated,
        super(const AlbumState()) {
    on<AlbumStarted>(_onStarted);
    on<AlbumProgressRefreshed>(_onProgressRefreshed);
    on<AlbumRevealRequested>(_onRevealRequested);
    on<AlbumRevealConsumed>(_onRevealConsumed);
    on<AlbumBossQuickDefeated>(_onBossQuickDefeated);
  }

  Future<void> _onStarted(AlbumStarted event, Emitter<AlbumState> emit) async {
    emit(state.copyWith(status: AlbumStatus.loading));
    final data = await _loadAlbum();
    final progress = await _loadProgress();
    emit(state.copyWith(
      status: AlbumStatus.loaded,
      data: data,
      progress: progress,
    ));
  }

  Future<void> _onProgressRefreshed(
      AlbumProgressRefreshed event, Emitter<AlbumState> emit) async {
    final progress = await _loadProgress();
    emit(state.copyWith(progress: progress));
  }

  void _onRevealRequested(
      AlbumRevealRequested event, Emitter<AlbumState> emit) {
    emit(state.copyWith(justRevealedBossId: event.bossId));
  }

  void _onRevealConsumed(AlbumRevealConsumed event, Emitter<AlbumState> emit) {
    emit(state.copyWith(clearReveal: true));
  }

  Future<void> _onBossQuickDefeated(
      AlbumBossQuickDefeated event, Emitter<AlbumState> emit) async {
    // Guard: only mark a pending boss; never toggle off via the quick button.
    if (state.progress.isDefeated(event.bossId)) return;
    final next = await _toggleDefeated(state.progress, event.bossId);
    emit(state.copyWith(progress: next, justRevealedBossId: event.bossId));
  }
}
