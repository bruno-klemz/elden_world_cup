import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class RevealOverlay extends StatefulWidget {
  const RevealOverlay({
    super.key,
    required this.child,
    required this.play,
    this.onDone,
  });

  final Widget child;
  final bool play;
  final VoidCallback? onDone;

  @override
  State<RevealOverlay> createState() => _RevealOverlayState();
}

class _RevealOverlayState extends State<RevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    if (widget.play) _play();
  }

  @override
  void didUpdateWidget(RevealOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) _play();
  }

  void _play() {
    _c.forward(from: 0).whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          if (v == 0) return const SizedBox.shrink();
          final glow = (v < 0.5 ? v * 2 : (1 - v) * 2).clamp(0.0, 1.0);
          return Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldLight.withValues(alpha: glow * 0.6),
                      blurRadius: 60,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Opacity(
                    opacity: glow,
                    child: const Text('✨', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }
}
