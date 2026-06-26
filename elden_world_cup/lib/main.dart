import 'package:flutter/material.dart';
import 'album/presenter/album/album_screen.dart';
import 'service_locator.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const EldenAlbumApp());
}

class EldenAlbumApp extends StatelessWidget {
  const EldenAlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elden Album',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.gold, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const AlbumScreen(),
    );
  }
}
