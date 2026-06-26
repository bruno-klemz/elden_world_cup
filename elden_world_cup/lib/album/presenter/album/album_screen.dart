import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service_locator.dart';
import '../../domain/usecase/load_album_usecase.dart';
import '../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../boss/domain/usecase/toggle_defeated_usecase.dart';
import 'album_view.dart';
import 'bloc/album_bloc.dart';

/// Composition root for the album: creates [AlbumBloc] from the locator.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumBloc(
        loadAlbum: locator<LoadAlbumUsecase>(),
        loadProgress: locator<LoadProgressUsecase>(),
        toggleDefeated: locator<ToggleDefeatedUsecase>(),
      )..add(const AlbumStarted()),
      child: const AlbumView(),
    );
  }
}
