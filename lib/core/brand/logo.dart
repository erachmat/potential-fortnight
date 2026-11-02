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
  Widget build(BuildContext context) => Align(
        // Align + widthFactor/heightFactor: ukuran logo tidak ikut melebar saat parent memberi lebar ketat (mis. ListView).
        alignment: Alignment.topLeft,
        widthFactor: 1,
        heightFactor: 1,
        child: SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter(progress, ink, accent))),
      );
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

    // badan tas: trapesium melebar ke bawah (bukan kotak, supaya tidak terbaca sebagai gembok)
    final body = Path()
      ..moveTo(26 * k, 38 * k)
      ..lineTo(70 * k, 38 * k)
      ..lineTo(77 * k, 86 * k)
      ..lineTo(19 * k, 86 * k)
      ..close();
    drawPartial(body, _seg(0, .5));

    // pegangan = huruf "n" yang menembus ke dalam badan tas
    final handle = Path()
      ..moveTo(35 * k, 54 * k)
      ..lineTo(35 * k, 32 * k)
      ..quadraticBezierTo(35 * k, 14 * k, 48 * k, 14 * k)
      ..quadraticBezierTo(61 * k, 14 * k, 61 * k, 32 * k)
      ..lineTo(61 * k, 54 * k);
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
