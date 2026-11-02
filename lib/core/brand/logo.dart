import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../design_system/tokens.dart';

/// Logo Nitip: tas belanja dengan pegangan berbentuk huruf "n" + gelembung chat.
/// [progress] 0..1 untuk animasi gambar (M-01); 1 = logo penuh.
class NitipMark extends StatelessWidget {
  const NitipMark({super.key, this.size = 96, this.progress = 1, this.ink = NColors.ink, this.accent = NColors.brand});

  final double size;
  final double progress;
  final Color ink;
  final Color accent;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _MarkPainter(progress, ink, accent));
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.t, this.ink, this.accent);
  final double t;
  final Color ink;
  final Color accent;

  double _seg(double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size s) {
    final k = s.width / 100;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawPartial(Path p, double f) {
      for (final PathMetric m in p.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * Curves.easeOutCubic.transform(f)), stroke);
      }
    }

    final body = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20 * k, 38 * k, 56 * k, 50 * k), Radius.circular(12 * k)));
    drawPartial(body, _seg(0, .5));

    // pegangan = huruf "n" (bounce kecil di akhir)
    final bounce = t > .7 ? (1 - (t - .7) / .3) * 0.0 : 0.0;
    final handle = Path()
      ..moveTo(36 * k, 40 * k)
      ..lineTo(36 * k, (28 + bounce) * k)
      ..quadraticBezierTo(36 * k, 17 * k, 48 * k, 17 * k)
      ..quadraticBezierTo(60 * k, 17 * k, 60 * k, 28 * k)
      ..lineTo(60 * k, 40 * k);
    drawPartial(handle, _seg(.4, .75));

    // gelembung chat (pop)
    final pop = Curves.easeOutBack.transform(_seg(.72, 1));
    if (pop > 0) {
      final c = Offset(78 * k, 22 * k);
      canvas.drawCircle(c, 11 * k * pop, Paint()..color = accent);
      final tail = Path()
        ..moveTo(70 * k, 28 * k)
        ..lineTo(66 * k, 36 * k)
        ..lineTo(76 * k, 31 * k)
        ..close();
      canvas.save();
      canvas.scale(pop, pop);
      canvas.translate((1 - pop) * 70 * k / pop * 0, 0);
      canvas.drawPath(tail, Paint()..color = accent);
      canvas.restore();
      final dots = Paint()..color = ink;
      for (var i = -1; i <= 1; i++) {
        canvas.drawCircle(c + Offset(i * 4.6 * k, 0), 1.5 * k * pop, dots);
      }
    }
  }

  @override
  bool shouldRepaint(_MarkPainter o) => o.t != t || o.ink != ink || o.accent != accent;
}

/// Wordmark "nitip" (huruf kecil, ExtraBold).
class NitipWordmark extends StatelessWidget {
  const NitipWordmark({super.key, this.size = 40, this.color = NColors.ink});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text('nitip', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: size, fontWeight: FontWeight.w800, letterSpacing: -size * .04, color: color, height: 1));
}
