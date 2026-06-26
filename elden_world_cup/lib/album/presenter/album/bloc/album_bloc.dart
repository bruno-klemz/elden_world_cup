import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../boss/domain/entity/progress.dart';
import '../../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../domain/entity/album_data.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/region.dart';
import '../../../domain/usecase/load_album_usecase.dart';

part 'album_event.dart';
part 'album_state.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final LoadAlbumUsecase _loadAlbum;
  final LoadProgressUsecase _loadProgress;

  AlbumBloc({
    required LoadAlbumUsecase loadAlbum,
    required LoadProgressUsecase loadProgress,
  })  : _loadAlbum = loadAlbum,
        _loadProgress = loadProgress,
        super(const AlbumState()) {
    on<AlbumStarted>(_onStarted);
    on<AlbumProgressRefreshed>(_onProgressRefreshed);
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
}
