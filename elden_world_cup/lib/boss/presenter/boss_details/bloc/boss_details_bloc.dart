import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../album/domain/entity/boss.dart';
import '../../../domain/entity/progress.dart';
import '../../../domain/usecase/load_progress_usecase.dart';
import '../../../domain/usecase/set_map_revealed_usecase.dart';
import '../../../domain/usecase/toggle_defeated_usecase.dart';

part 'boss_details_event.dart';
part 'boss_details_state.dart';

class BossDetailsBloc extends Bloc<BossDetailsEvent, BossDetailsState> {
  final LoadProgressUsecase _loadProgress;
  final ToggleDefeatedUsecase _toggleDefeated;
  final SetMapRevealedUsecase _setMapRevealed;

  BossDetailsBloc({
    required Boss boss,
    required LoadProgressUsecase loadProgress,
    required ToggleDefeatedUsecase toggleDefeated,
    required SetMapRevealedUsecase setMapRevealed,
  })  : _loadProgress = loadProgress,
        _toggleDefeated = toggleDefeated,
        _setMapRevealed = setMapRevealed,
        super(BossDetailsState(boss: boss)) {
    on<BossDetailsStarted>(_onStarted);
    on<BossDefeatToggled>(_onDefeatToggled);
    on<BossMapRevealed>(_onMapRevealed);
    on<BossMapHidden>(_onMapHidden);
  }

  Future<void> _onStarted(
      BossDetailsStarted event, Emitter<BossDetailsState> emit) async {
    final progress = await _loadProgress();
    emit(state.copyWith(progress: progress));
  }

  Future<void> _onDefeatToggled(
      BossDefeatToggled event, Emitter<BossDetailsState> emit) async {
    final wasDefeated = state.isDefeated;
    final next = await _toggleDefeated(state.progress, state.boss.id);
    emit(state.copyWith(
      progress: next,
      // play the reveal animation only on the pending -> defeated transition
      justRevealed: !wasDefeated && next.isDefeated(state.boss.id),
    ));
  }

  Future<void> _onMapRevealed(
      BossMapRevealed event, Emitter<BossDetailsState> emit) async {
    final next =
        await _setMapRevealed(state.progress, state.boss.id, revealed: true);
    emit(state.copyWith(progress: next, justRevealed: false));
  }

  Future<void> _onMapHidden(
      BossMapHidden event, Emitter<BossDetailsState> emit) async {
    final next =
        await _setMapRevealed(state.progress, state.boss.id, revealed: false);
    emit(state.copyWith(progress: next, justRevealed: false));
  }
}
