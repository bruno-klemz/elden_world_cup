import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/boss_repository.dart';
import 'data/progress_store.dart';
import 'state/album_controller.dart';
import 'presentation/album/album_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EldenAlbumApp());
}

class EldenAlbumApp extends StatelessWidget {
  const EldenAlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AlbumController(repo: BossRepository(), store: ProgressStore())
            ..init(),
      child: MaterialApp(
        title: 'Elden Album',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.gold, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const AlbumScreen(),
      ),
    );
  }
}
