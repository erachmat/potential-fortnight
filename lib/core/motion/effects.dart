import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../design_system/tokens.dart';
import 'motion.dart';

/// Lingkaran + centang yang "digambar" (M-22).
class DrawnCheck extends StatefulWidget {
  const DrawnCheck({super.key, this.size = 96, this.color = NColors.success, this.onDone});

  final double size;
  final Color color;
  final VoidCallback? onDone;

  @override
  State<DrawnCheck> createState() => _DrawnCheckState();
}

class _DrawnCheckState extends State<DrawnCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotion(context);
    if (reduce) _c.value = 1;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _CheckPainter(_c.value, widget.color)),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = s.width * 0.07;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final circleT = Curves.easeOutCubic.transform((t / 0.6).clamp(0, 1));
    final rect = (Offset.zero & s).deflate(stroke);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * circleT, false, paint);
    final checkT = Curves.easeOut.transform(((t - 0.55) / 0.45).clamp(0, 1));
    if (checkT > 0) {
      final a = Offset(s.width * 0.28, s.height * 0.52);
      final b = Offset(s.width * 0.44, s.height * 0.67);
      final c = Offset(s.width * 0.73, s.height * 0.36);
      final path = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy);
      final m = path.computeMetrics().first;
      canvas.drawPath(m.extractPath(0, m.length * checkT), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.t != t;
}

/// Ledakan confetti sekali jalan dari tengah.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.child, this.fire = true});

  final Widget child;
  final bool fire;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> {
  final _c = ConfettiController(duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.fire) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && !reduceMotion(context)) _c.play(); });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _c,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 28,
            gravity: 0.25,
            emissionFrequency: 0.0,
            colors: const [NColors.brand, NColors.ink, NColors.warning, NColors.success, Color(0xFFFFD2BD)],
          ),
        ),
      ],
    );
  }
}

/// Getar horizontal 3x (M-18). Ubah [trigger] untuk memicu.
extension ShakeX on Widget {
  Widget shakeOn(int trigger) => animate(key: ValueKey('shake-$trigger'), autoPlay: trigger > 0).shakeX(hz: 6, amount: 6, duration: 400.ms);
}

/// Gelombang konsentris + sapuan (M-23).
class RadarPulse extends StatefulWidget {
  const RadarPulse({super.key, this.size = 260, this.color = NColors.brand});

  final double size;
  final Color color;

  @override
  State<RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<RadarPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(painter: _RadarPainter(_c.value, widget.color, reduceMotion(context))),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.t, this.color, this.reduce);
  final double t;
  final Color color;
  final bool reduce;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final maxR = s.width / 2;
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - p) * 0.5);
      canvas.drawCircle(c, maxR * (0.25 + 0.75 * p), paint);
    }
    if (!reduce) {
      final sweep = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(t * math.pi * 2),
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.35)],
        stops: const [0.7, 1],
      );
      canvas.drawCircle(c, maxR, Paint()..shader = sweep.createShader(Offset.zero & s));
    }
    canvas.drawCircle(c, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.t != t;
}
