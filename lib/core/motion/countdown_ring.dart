import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

import 'package:flutter/material.dart';

import '../design_system/tokens.dart';
import '../format/format.dart';

/// Cincin countdown yang dihitung dari timestamp [expiresAt] (bukan timer lokal)
/// sehingga semua panel sinkron. Hijau -> kuning (<=50%) -> merah (<=20%).
class CountdownRing extends StatefulWidget {
  const CountdownRing({
    super.key,
    required this.expiresAt,
    required this.total,
    required this.now,
    this.size = 120,
    this.stroke = 8,
    this.child,
    this.showText = true,
  });

  final DateTime expiresAt;
  final Duration total;
  final DateTime Function() now;
  final double size;
  final double stroke;
  final Widget? child;
  final bool showText;

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.expiresAt.difference(widget.now());
    final frac = (left.inMilliseconds / widget.total.inMilliseconds).clamp(0.0, 1.0);
    final color = frac <= 0.2 ? NColors.danger : (frac <= 0.5 ? NColors.warning : NColors.success);
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(frac, color, widget.stroke),
          child: Center(
            child: widget.child ??
                (widget.showText
                    ? Text(mmss(Duration(seconds: left.inSeconds + (left.inMilliseconds % 1000 > 0 ? 1 : 0))),
                        style: NText.number(widget.size * 0.25, color: color))
                    : null),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.frac, this.color, this.stroke);
  final double frac;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = NColors.line;
    canvas.drawArc(r, 0, math.pi * 2, false, base);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * frac, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.frac != frac || o.color != color;
}
