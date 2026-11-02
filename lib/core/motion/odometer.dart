import 'package:flutter/material.dart';

import '../design_system/tokens.dart';
import '../format/format.dart';
import 'motion.dart';

/// Teks rupiah yang angkanya bergulir per digit saat nilai berubah (M-17/M-33).
class RupiahText extends StatelessWidget {
  const RupiahText(
    this.value, {
    super.key,
    this.size = 16,
    this.weight = FontWeight.w700,
    this.color = NColors.ink,
    this.sign = false,
    this.animate = true,
  });

  final int value;
  final double size;
  final FontWeight weight;
  final Color color;
  final bool sign;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final style = NText.number(size, weight: weight, color: color);
    if (!animate || reduceMotion(context)) {
      return Text(rupiah(value, sign: sign), style: style);
    }
    return Odometer(text: rupiah(value, sign: sign), style: style);
  }
}

/// Setiap karakter digit bergulir vertikal dari nilai lama ke baru.
class Odometer extends StatelessWidget {
  const Odometer({super.key, required this.text, required this.style, this.duration = const Duration(milliseconds: 350)});

  final String text;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Key dihitung dari kanan supaya digit satuan tetap "milik" posisi yang sama.
        for (var i = 0; i < chars.length; i++)
          _Slot(key: ValueKey('slot-${chars.length - i}'), char: chars[i], style: style, duration: duration),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({super.key, required this.char, required this.style, required this.duration});

  final String char;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final isDigit = RegExp(r'\d').hasMatch(char);
    if (!isDigit) return Text(char, style: style);
    final h = (style.fontSize ?? 16) * (style.height ?? 1.2);
    final target = int.parse(char);
    final tp = TextPainter(text: TextSpan(text: '0', style: style), textDirection: TextDirection.ltr)..layout();
    return ClipRect(
      child: SizedBox(
        width: tp.width,
        height: h,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: target.toDouble()),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: h * 10,
            child: Transform.translate(
              offset: Offset(0, -v * h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [for (var d = 0; d < 10; d++) SizedBox(height: h, child: Text('$d', style: style))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
