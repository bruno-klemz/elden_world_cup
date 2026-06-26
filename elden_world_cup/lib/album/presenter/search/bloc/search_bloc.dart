import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../boss/domain/entity/progress.dart';
import '../../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../domain/entity/album_data.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/region.dart';
import '../../../domain/usecase/load_album_usecase.dart';
import '../search_match.dart';

part 'search_event.dart';
part 'search_state.dart';

enum SearchTab { regions, bosses }

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final LoadAlbumUsecase _loadAlbum;
  final LoadProgressUsecase _loadProgress;

  SearchBloc({
    required LoadAlbumUsecase loadAlbum,
    required LoadProgressUsecase loadProgress,
  })  : _loadAlbum = loadAlbum,
        _loadProgress = loadProgress,
        super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchTabChanged>(_onTabChanged);
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onStarted(SearchStarted e, Emitter<SearchState> emit) async {
    final data = await _loadAlbum();
    final progress = await _loadProgress();
    emit(state.copyWith(data: data, progress: progress, loaded: true));
  }

  void _onTabChanged(SearchTabChanged e, Emitter<SearchState> emit) =>
      emit(state.copyWith(tab: e.tab));

  void _onQueryChanged(SearchQueryChanged e, Emitter<SearchState> emit) =>
      emit(state.copyWith(query: e.query));
}
