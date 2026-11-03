import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// The signature gradient ring. It rotates slowly; with reduced motion it stays still.
class GradientRing extends StatefulWidget {
  const GradientRing({super.key, required this.show, required this.radius, required this.child, this.inset = 0});

  final bool show;
  final double radius;
  final double inset;
  final Widget child;

  @override
  State<GradientRing> createState() => _GradientRingState();
}

class _GradientRingState extends State<GradientRing> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(GradientRing old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final still = MediaQuery.disableAnimationsOf(context);
    if (widget.show && !still) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.show)
          Positioned.fill(
            left: widget.inset,
            top: widget.inset,
            right: widget.inset,
            bottom: widget.inset,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _spin,
                    builder: (context, _) => CustomPaint(painter: _RingPainter(_spin.value * 2 * math.pi, widget.radius)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.turn, this.radius);
  final double turn;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final box = (Offset.zero & size).inflate(3);
    final rrect = RRect.fromRectAndRadius(box, Radius.circular(radius + 3));
    final shader = SweepGradient(
      colors: [...ringColors, ringColors.first],
      transform: GradientRotation(turn),
    ).createShader(box);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = const Color(0x99FFFFFF),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.turn != turn || old.radius != radius;
}

/// Makes a region tappable with the ring on touch-down, keyboard focus, or when [flash] is set.
class RingTarget extends StatefulWidget {
  const RingTarget({
    super.key,
    required this.onTap,
    required this.child,
    this.radius = 8,
    this.flash = false,
    this.label,
    this.selected,
  });

  final VoidCallback onTap;
  final Widget child;
  final double radius;
  final bool flash;
  final String? label;
  final bool? selected;

  @override
  State<RingTarget> createState() => _RingTargetState();
}

class _RingTargetState extends State<RingTarget> {
  bool _down = false;
  bool _focused = false;
  bool _hover = false;
  Offset _travel = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap();
            return null;
          }),
        },
        child: Listener(
          onPointerDown: (e) => setState(() {
            _down = true;
            _travel = Offset.zero;
          }),
          onPointerMove: (e) {
            _travel += e.delta;
            if (_down && _travel.distance > 12) setState(() => _down = false);
          },
          onPointerUp: (_) => setState(() => _down = false),
          onPointerCancel: (_) => setState(() => _down = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: GradientRing(
              show: _down || _focused || _hover || widget.flash,
              radius: widget.radius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A 44 by 44 tap target for small icon buttons. The ring shows on keyboard focus and on hover.
class TapBox extends StatefulWidget {
  const TapBox({super.key, required this.onTap, required this.label, required this.child, this.size = 44, this.toggled, this.ringRadius = 18});

  final VoidCallback onTap;
  final String label;
  final Widget child;
  final double size;
  final bool? toggled;
  final double ringRadius;

  @override
  State<TapBox> createState() => _TapBoxState();
}

class _TapBoxState extends State<TapBox> {
  bool _focused = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: widget.toggled,
      label: widget.label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(child: GradientRing(show: _focused || _hover, radius: widget.ringRadius, child: widget.child)),
          ),
        ),
      ),
    );
  }
}

void tick() => HapticFeedback.selectionClick();
