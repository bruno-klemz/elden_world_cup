import 'package:flutter/material.dart';
import '../../../domain/entity/boss.dart';
import '../../../../shared/widgets/pending_art.dart';
import '../../../../theme/app_theme.dart';
import 'reveal_overlay.dart';

class StickerSlot extends StatefulWidget {
  const StickerSlot({
    super.key,
    required this.boss,
    required this.defeated,
    required this.onTap,
    this.isMain = false,
    this.animateReveal = false,
    this.onRevealDone,
    this.onQuickDefeat,
  });

  final Boss boss;
  final bool defeated;
  final VoidCallback onTap;

  /// Headline boss of its region. When defeated, gets a crown, a heavier gold
  /// border and a steady "alive" pulse. While pending it looks like any other
  /// pending slot (the reward only appears once defeated).
  final bool isMain;

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
  AnimationController? _pulse;
  bool _playReveal = false;

  bool get _showPulse => widget.isMain && widget.defeated;

  @override
  void initState() {
    super.initState();
    if (widget.animateReveal) _startReveal();
    if (_showPulse) _startPulse();
  }

  @override
  void didUpdateWidget(StickerSlot old) {
    super.didUpdateWidget(old);
    if (widget.animateReveal && !old.animateReveal) _startReveal();
    if (_showPulse && _pulse == null) _startPulse();
  }

  void _startReveal() {
    _fade ??= AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade!.forward(from: 0);
    setState(() => _playReveal = true);
  }

  void _startPulse() {
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fade?.dispose();
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showColored = widget.defeated;
    final isMainDone = widget.isMain && showColored;
    // Gold is reserved for main bosses — so they stand out. Regular defeated
    // slots use a discreet border (the colored art already signals "done").
    final borderColor = isMainDone
        ? AppColors.gold
        : showColored
            ? const Color(0xFF4A3C2A)
            : AppColors.border;
    final borderWidth = isMainDone ? 2.5 : 1.0;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _artLayer(showColored),
          _nameStrip(showColored, isMainDone),
          if (isMainDone)
            const Positioned(
              top: 5,
              left: 5,
              child: Text('👑', style: TextStyle(fontSize: 15)),
            ),
          if (!showColored &&
              !widget.animateReveal &&
              widget.onQuickDefeat != null)
            _quickCheckButton(),
        ],
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: _showPulse && _pulse != null
            ? AnimatedBuilder(
                animation: _pulse!,
                builder: (context, child) => _frame(
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                  glow: _pulse!.value, // 0..1
                  glowColor: AppColors.gold,
                  child: child!,
                ),
                child: card,
              )
            : _frame(
                borderColor: borderColor,
                borderWidth: borderWidth,
                glow: 0,
                glowColor: AppColors.gold,
                child: card,
              ),
      ),
    );
  }

  Widget _frame({
    required Color borderColor,
    required double borderWidth,
    required double glow,
    required Color glowColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: glow > 0
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.15 + glow * 0.4),
                  blurRadius: 6 + glow * 12,
                  spreadRadius: glow * 2,
                ),
              ]
            : null,
      ),
      child: child,
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

  Widget _pendingArt() => PendingArt(
        art: widget.boss.art,
        blurSigma: 6,
        grayscale: true,
        darken: 0.45,
      );

  Widget _nameStrip(bool showColored, bool isMainDone) => Positioned(
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
                  color: isMainDone
                      ? AppColors.goldLight
                      : showColored
                          ? const Color(0xFFCBB88A) // muted gold for regulars
                          : const Color(0xFF9A8A66))),
        ),
      );

  Widget _quickCheckButton() => Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: widget.onQuickDefeat,
          child: CustomPaint(
            key: const Key('slot-quick-check'),
            painter: _DashedCirclePainter(),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.goldLight),
            ),
          ),
        ),
      );
}

/// Draws a dashed gold ring — signals "empty, tap to fill" (an action), not a
/// filled status badge.
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 0.75;
    const dashCount = 16;
    const sweep = 2 * 3.1415926 / dashCount;
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * 0.55, // dash vs gap ratio
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
