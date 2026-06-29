import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'album/presenter/album/album_screen.dart';
import 'app/mobile_frame.dart';
import 'service_locator.dart';
import 'settings/domain/usecase/load_settings_usecase.dart';
import 'settings/domain/usecase/set_blur_pending_usecase.dart';
import 'settings/presenter/bloc/settings_bloc.dart';
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
    // SettingsBloc is provided above MaterialApp so it sits above the Navigator
    // and is shared by every route (album, search, boss details).
    return BlocProvider(
      create: (_) => SettingsBloc(
        loadSettings: locator<LoadSettingsUsecase>(),
        setBlurPending: locator<SetBlurPendingUsecase>(),
      )..add(const SettingsStarted()),
      child: MaterialApp(
        title: 'Elden Album',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.gold, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        builder: (context, child) => MobileFrame(child: child!),
        home: const AlbumScreen(),
      ),
    );
  }
}
