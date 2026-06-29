import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/presenter/bloc/settings_bloc.dart';
import '../../theme/app_theme.dart';

// Standard luminance grayscale matrix for ColorFilter.matrix.
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

/// Renders not-yet-defeated boss art with the "pending" treatment. The blur
/// layer is toggled by the global [SettingsBloc] (`blurPending`); the other
/// effects ([grayscale], [darken]) are per call-site and always applied.
class PendingArt extends StatelessWidget {
  const PendingArt({
    super.key,
    required this.art,
    required this.blurSigma,
    this.grayscale = false,
    this.darken = 0,
    this.alignment = const Alignment(0, -0.6),
    this.fit = BoxFit.cover,
  });

  /// Asset path under `assets/` (e.g. `images/malenia.webp`).
  final String art;

  /// Blur strength applied when the global blur preference is on.
  final double blurSigma;

  /// Desaturate to black & white.
  final bool grayscale;

  /// Darken overlay opacity (0 = none).
  final double darken;

  final Alignment alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final blur = context.watch<SettingsBloc>().state.blurPending;

    Widget art = Image.asset('assets/${this.art}',
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stack) =>
            Container(color: AppColors.surfaceAlt));

    if (darken > 0) {
      art = ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: darken), BlendMode.darken),
        child: art,
      );
    }

    if (blur) {
      art = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: art,
      );
    }

    if (grayscale) {
      art = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
        child: art,
      );
    }

    return art;
  }
}
