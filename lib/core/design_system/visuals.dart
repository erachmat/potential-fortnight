import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import 'tokens.dart';

/// Pengganti foto makanan: kartu bergradasi + emoji besar (placeholder, lihat PROGRESS).
class FoodThumb extends StatelessWidget {
  const FoodThumb({super.key, required this.emoji, this.size = 64, this.radius = 16, this.seed = 0});

  final String emoji;
  final double size;
  final double radius;
  final int seed;

  static const _palettes = [
    [Color(0xFFFFE3D1), Color(0xFFFFB98F)],
    [Color(0xFFFFF0C2), Color(0xFFFFD36E)],
    [Color(0xFFE5F3E0), Color(0xFFB5DDA8)],
    [Color(0xFFFFE0E0), Color(0xFFFFB0B0)],
    [Color(0xFFE3ECFF), Color(0xFFB4C9FF)],
  ];

  @override
  Widget build(BuildContext context) {
    final p = _palettes[seed.abs() % _palettes.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * .5)),
    );
  }
}

class CanteenAvatar extends StatelessWidget {
  const CanteenAvatar(this.code, {super.key, this.size = 36});
  final String code;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: NColors.brand, borderRadius: BorderRadius.circular(size * .32)),
        child: Text(code, style: NText.number(size * .5, weight: FontWeight.w800)),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 44, this.dark = false});
  final String name;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((e) => e.isEmpty ? '' : e[0]).join().toUpperCase();
    final hue = (name.codeUnits.fold<int>(0, (a, b) => a + b) * 37) % 360;
    final c = HSLColor.fromAHSL(1, hue.toDouble(), .55, dark ? .35 : .82).toColor();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      child: Text(initials, style: NText.bodyStrong.copyWith(fontSize: size * .36, color: dark ? Colors.white : NColors.ink)),
    );
  }
}

/// KTM digambar lewat kode (tanpa aset). Watermark "CONTOH" supaya jelas bukan dokumen asli.
class KtmCard extends StatelessWidget {
  const KtmCard({super.key, required this.name, required this.nim, this.width = 300});

  final String name;
  final String nim;
  final double width;

  @override
  Widget build(BuildContext context) {
    final h = width * .63;
    return Container(
      width: width,
      height: h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFF1F3A68), Color(0xFF2F6FEB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: NShadow.card,
      ),
      child: Stack(children: [
        Positioned(
          right: -20,
          top: -20,
          child: Container(width: h * .6, height: h * .6, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .08))),
        ),
        Padding(
          padding: EdgeInsets.all(width * .06),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: width * .1, height: width * .1, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.school_rounded, size: width * .06, color: const Color(0xFF1F3A68))),
              SizedBox(width: width * .03),
              Expanded(child: Text('KARTU TANDA MAHASISWA\nUNIVERSITAS NUSANTARA CONTOH', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontSize: width * .032, fontWeight: FontWeight.w700, height: 1.25))),
            ]),
            const Spacer(),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(width: width * .22, height: width * .27, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)), child: Icon(Icons.person_rounded, color: Colors.white70, size: width * .16)),
              SizedBox(width: width * .05),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name.toUpperCase(), maxLines: 2, style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontSize: width * .05, fontWeight: FontWeight.w800)),
                  SizedBox(height: width * .012),
                  Text(nim, style: NText.number(width * .055, color: Colors.white, weight: FontWeight.w600)),
                  Text('Teknik Informatika', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white70, fontSize: width * .035)),
                ]),
              ),
            ]),
          ]),
        ),
        Center(
          child: Transform.rotate(
            angle: -math.pi / 9,
            child: Text('CONTOH', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: width * .2, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: .22))),
          ),
        ),
      ]),
    );
  }
}

/// Peta kampus ilustrasi. Gedung/kantin diposisikan relatif 0..1.
class CampusMap extends StatelessWidget {
  const CampusMap({
    super.key,
    required this.buildings,
    required this.canteens,
    this.selectedBuilding,
    this.onBuildingTap,
    this.route = const [],
    this.routeDone = 0,
    this.courierPos,
    this.doneCanteens = const {},
    this.highlightCanteens = const {},
    this.height = 280,
  });

  final List<Building> buildings;
  final List<Canteen> canteens;
  final String? selectedBuilding;
  final ValueChanged<Building>? onBuildingTap;

  /// Titik rute berurutan (relatif 0..1); [routeDone] = fraksi 0..1 yang sudah ditempuh.
  final List<Offset> route;
  final double routeDone;
  final Offset? courierPos;
  final Set<String> doneCanteens;
  final Set<String> highlightCanteens;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, height);
      Offset px(double x, double y) => Offset(x * size.width, y * size.height);
      return ClipRRect(
        borderRadius: NRadius.cardBr,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(children: [
            Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _MapPainter(route: route, done: routeDone)))),
            for (final b in buildings)
              Positioned(
                left: px(b.mapX, b.mapY).dx - 30,
                top: px(b.mapX, b.mapY).dy - 22,
                child: GestureDetector(
                  onTap: onBuildingTap == null ? null : () => onBuildingTap!(b),
                  child: _BuildingTile(b: b, selected: b.id == selectedBuilding),
                ),
              ),
            for (final k in canteens)
              Positioned(
                left: px(k.mapX, k.mapY).dx - 14,
                top: px(k.mapX, k.mapY).dy - 14,
                child: _CanteenPin(k: k, done: doneCanteens.contains(k.id), highlight: highlightCanteens.contains(k.id)),
              ),
            if (courierPos != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                left: px(courierPos!.dx, courierPos!.dy).dx - 16,
                top: px(courierPos!.dx, courierPos!.dy).dy - 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: NColors.ink, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: NShadow.card),
                  child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 16),
                ),
              ),
          ]),
        ),
      );
    });
  }
}

class _BuildingTile extends StatelessWidget {
  const _BuildingTile({required this.b, required this.selected});
  final Building b;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final short = b.name.split('·').first.trim();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
      width: 60,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? NColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected ? NShadow.float : NShadow.card,
        border: Border.all(color: selected ? NColors.brand : NColors.line, width: selected ? 2 : 1),
      ),
      child: Text(short, textAlign: TextAlign.center, maxLines: 2, style: NText.caption.copyWith(fontSize: 9.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : NColors.ink, height: 1.1)),
    );
  }
}

class _CanteenPin extends StatelessWidget {
  const _CanteenPin({required this.k, required this.done, required this.highlight});
  final Canteen k;
  final bool done;
  final bool highlight;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? NColors.success : (highlight ? NColors.brand : NColors.brandSoft),
          shape: BoxShape.circle,
          border: Border.all(color: done ? NColors.success : NColors.brand, width: 2),
        ),
        child: done ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : Text(k.code, style: NText.number(13, weight: FontWeight.w800)),
      );
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.route, required this.done});
  final List<Offset> route;
  final double done;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFEFF3EA));
    // jalan kampus
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final p = Path()
      ..moveTo(s.width * .05, s.height * .45)
      ..lineTo(s.width * .95, s.height * .45)
      ..moveTo(s.width * .35, s.height * .05)
      ..lineTo(s.width * .35, s.height * .95)
      ..moveTo(s.width * .72, s.height * .05)
      ..lineTo(s.width * .72, s.height * .95);
    canvas.drawPath(p, road);
    // taman
    final park = Paint()..color = const Color(0xFFD9E8CF);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .42, s.height * .50, s.width * .2, s.height * .22), const Radius.circular(18)), park);
    if (route.length >= 2) {
      final path = Path()..moveTo(route.first.dx * s.width, route.first.dy * s.height);
      for (final r in route.skip(1)) {
        path.lineTo(r.dx * s.width, r.dy * s.height);
      }
      // jalur putus-putus (belum ditempuh)
      final dash = Paint()
        ..color = NColors.ink400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (final m in path.computeMetrics()) {
        for (double d = 0; d < m.length; d += 14) {
          canvas.drawPath(m.extractPath(d, math.min(d + 7, m.length)), dash);
        }
        // jalur sudah ditempuh (oranye solid)
        canvas.drawPath(m.extractPath(0, m.length * done.clamp(0, 1)), Paint()
          ..color = NColors.brand
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter o) => o.done != done || o.route != route;
}
