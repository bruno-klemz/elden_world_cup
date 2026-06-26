import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/entity/boss.dart';
import '../../../../theme/app_theme.dart';
import 'reveal_overlay.dart';

// Standard luminance grayscale matrix for ColorFilter.matrix.
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

class StickerSlot extends StatefulWidget {
  const StickerSlot({
    super.key,
    required this.boss,
    required this.defeated,
    required this.onTap,
    this.animateReveal = false,
    this.onRevealDone,
    this.onQuickDefeat,
  });

  final Boss boss;
  final bool defeated;
  final VoidCallback onTap;

  /// When true, the slot cross-fades from the pending (blurred B&W) art to the
  /// colored art with a glow + sparkle. Only the freshly defeated slot gets this.
  final bool animateReveal;
  final VoidCallback? onRevealDone;

  /// Quick-check shortcut shown on pending slots; marks the boss defeated
  /// without opening the details screen.
  final VoidCallback? onQuickDefeat;

  @override
  State<StickerSlot> createState() => _StickerSlotState();
}

class _StickerSlotState extends State<StickerSlot>
    with TickerProviderStateMixin {
  AnimationController? _fade;
  bool _playReveal = false;

  @override
  void initState() {
    super.initState();
    if (widget.animateReveal) _startReveal();
  }

  @override
  void didUpdateWidget(StickerSlot old) {
    super.didUpdateWidget(old);
    if (widget.animateReveal && !old.animateReveal) _startReveal();
  }

  void _startReveal() {
    _fade ??= AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade!.forward(from: 0);
    setState(() => _playReveal = true);
  }

  @override
  void dispose() {
    _fade?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showColored = widget.defeated;
    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: showColored ? AppColors.gold : AppColors.border,
                width: showColored ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _artLayer(showColored),
                _nameStrip(showColored),
                if (!showColored &&
                    !widget.animateReveal &&
                    widget.onQuickDefeat != null)
                  _quickCheckButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// During a reveal: pending art underneath, colored art fading in on top, all
  /// wrapped in the glow + sparkle overlay. Otherwise a single static layer.
  Widget _artLayer(bool showColored) {
    if (!widget.animateReveal) {
      return showColored ? _coloredArt() : _pendingArt();
    }
    return RevealOverlay(
      play: _playReveal,
      onDone: () {
        widget.onRevealDone?.call();
        if (mounted) setState(() => _playReveal = false);
      },
      child: Stack(fit: StackFit.expand, children: [
        _pendingArt(),
        FadeTransition(opacity: _fade!, child: _coloredArt()),
      ]),
    );
  }

  Widget _coloredArt() => Image.asset('assets/${widget.boss.art}',
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.6),
      errorBuilder: (context, error, stack) =>
          Container(color: AppColors.surfaceAlt));

  Widget _pendingArt() => ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.45), BlendMode.darken),
            child: _coloredArt(),
          ),
        ),
      );

  Widget _nameStrip(bool showColored) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(3, 12, 3, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
            ),
          ),
          child: Text(widget.boss.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.slotName.copyWith(
                  color: showColored
                      ? AppColors.goldLight
                      : const Color(0xFF9A8A66))),
        ),
      );

  Widget _quickCheckButton() => Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: widget.onQuickDefeat,
          child: Container(
            key: const Key('slot-quick-check'),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: const Icon(Icons.check,
                size: 15, color: AppColors.goldLight),
          ),
        ),
      );
}
