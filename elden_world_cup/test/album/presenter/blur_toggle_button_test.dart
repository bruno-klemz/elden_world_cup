import 'package:elden_world_cup/album/presenter/album/widgets/blur_toggle_button.dart';
import 'package:elden_world_cup/settings/presenter/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/settings_bloc_harness.dart';

void main() {
  testWidgets('shows a hidden (eye-off) icon when blur is enabled',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: withSettings(const BlurToggleButton(), blurPending: true))));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('shows a visible (eye) icon when blur is disabled',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: withSettings(const BlurToggleButton(), blurPending: false))));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('tapping toggles the blur preference', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: withSettings(const BlurToggleButton(), blurPending: true))));
    await tester.pump();

    await tester.tap(find.byType(BlurToggleButton));
    await tester.pump();

    // After one toggle from the default-on state, it flips to off.
    final bloc = BlocProvider.of<SettingsBloc>(
        tester.element(find.byType(BlurToggleButton)));
    expect(bloc.state.blurPending, isFalse);
  });
}
