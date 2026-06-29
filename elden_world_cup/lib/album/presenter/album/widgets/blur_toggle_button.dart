import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../settings/presenter/bloc/settings_bloc.dart';
import '../../../../theme/app_theme.dart';

/// Circular top-bar button that toggles the global blur-pending preference.
/// Matches the search button's style; sits beside it in the album top bar.
class BlurToggleButton extends StatelessWidget {
  const BlurToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final blur = context.watch<SettingsBloc>().state.blurPending;
    return GestureDetector(
      onTap: () =>
          context.read<SettingsBloc>().add(const SettingsBlurToggled()),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        // Eye icon, like password/sensitive-info reveal toggles: crossed-out
        // when art is hidden (blurred), open when it's revealed.
        child: Icon(blur ? Icons.visibility_off : Icons.visibility,
            color: AppColors.goldLight, size: 19),
      ),
    );
  }
}
