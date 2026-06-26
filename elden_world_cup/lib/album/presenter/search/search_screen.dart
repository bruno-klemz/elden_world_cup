import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../service_locator.dart';
import '../../domain/usecase/load_album_usecase.dart';
import 'bloc/search_bloc.dart';
import 'search_result.dart';
import 'search_view.dart';

/// Composition root for the search screen. Pushes itself and resolves to the
/// selected [SearchResult] (or null if dismissed).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static Future<SearchResult?> push(BuildContext context) {
    return Navigator.of(context).push<SearchResult>(MaterialPageRoute(
      builder: (_) => const SearchScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(
        loadAlbum: locator<LoadAlbumUsecase>(),
        loadProgress: locator<LoadProgressUsecase>(),
      )..add(const SearchStarted()),
      child: const SearchView(),
    );
  }
}
