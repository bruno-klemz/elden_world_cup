import 'package:elden_world_cup/settings/domain/entity/settings.dart';
import 'package:elden_world_cup/settings/domain/usecase/load_settings_usecase.dart';
import 'package:elden_world_cup/settings/domain/usecase/set_blur_pending_usecase.dart';
import 'package:elden_world_cup/settings/presenter/bloc/settings_bloc.dart';
import 'package:elden_world_cup/shared/widgets/pending_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoad implements LoadSettingsUsecase {
  _FakeLoad(this.value);
  final bool value;
  @override
  Future<Settings> call() async => Settings(blurPending: value);
}

class _FakeSetBlur implements SetBlurPendingUsecase {
  @override
  Future<Settings> call({required bool blurPending}) async =>
      Settings(blurPending: blurPending);
}

Widget _host({required bool blur, required Widget child}) {
  final bloc = SettingsBloc(
    loadSettings: _FakeLoad(blur),
    setBlurPending: _FakeSetBlur(),
  )..add(const SettingsStarted());
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider.value(value: bloc, child: child),
    ),
  );
}

void main() {
  testWidgets('blur ON includes an ImageFiltered (blur) layer',
      (tester) async {
    await tester.pumpWidget(_host(
      blur: true,
      child: const PendingArt(
          art: 'images/x.webp', blurSigma: 6, grayscale: true, darken: 0.45),
    ));
    await tester.pump();

    expect(find.byType(ImageFiltered), findsOneWidget);
  });

  testWidgets('blur OFF drops the ImageFiltered layer but keeps ColorFiltered',
      (tester) async {
    await tester.pumpWidget(_host(
      blur: false,
      child: const PendingArt(
          art: 'images/x.webp', blurSigma: 6, grayscale: true, darken: 0.45),
    ));
    await tester.pump();

    expect(find.byType(ImageFiltered), findsNothing);
    // grayscale + darken still applied via ColorFiltered.
    expect(find.byType(ColorFiltered), findsWidgets);
  });
}
