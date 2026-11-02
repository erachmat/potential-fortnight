import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/format.dart';
import '../../core/motion/countdown_ring.dart';
import '../../core/motion/motion.dart';
import '../../data/scope.dart';
import '../../demo/sound.dart';
import '../../domain/models/models.dart';

/// K-03 — order masuk (layar penuh, countdown dari timestamp server).
class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key, required this.offer});
  final CourierOffer offer;

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  bool _tickPlayed = false;

  @override
  void initState() {
    super.initState();
    Sound.ding();
    Feel.heavy();
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final of = widget.offer;
    final o = b.orderById(of.orderId)!;
    final total = of.expiresAt.difference(of.createdAt);
    final left = of.expiresAt.difference(b.now);
    if (left.inSeconds <= 5 && !_tickPlayed) {
      _tickPlayed = true;
      Sound.tick();
    }
    final canteens = o.canteenIds.map(b.canteen).toList();
    return Material(
      color: NColors.brand,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NSpace.gutter),
          child: Column(children: [
            const SizedBox(height: 8),
            const Text('PESANAN BARU', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2, color: NColors.ink))
                .animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: .5, end: 1, duration: 700.ms),
            const Spacer(),
            Container(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: left.inSeconds <= 5 ? [BoxShadow(color: NColors.danger.withValues(alpha: .5), blurRadius: 30, spreadRadius: 4)] : null),
              padding: const EdgeInsets.all(10),
              child: CountdownRing(expiresAt: of.expiresAt, total: total, now: () => b.now, size: 150, stroke: 10),
            ).animate(target: left.inSeconds <= 5 ? 1 : 0).shake(hz: 6, duration: 500.ms),
            const SizedBox(height: 20),
            const Text('Kamu terima', style: TextStyle(fontFamily: 'PlusJakartaSans', color: NColors.ink, fontSize: 14)),
            Text(rupiah(o.courierEarning), style: NText.number(40, weight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: NRadius.sheetBr),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _Fact('${canteens.length} kantin', '${o.totalQty} item')),
                  Expanded(child: _Fact('Belanja', rupiah(o.subtotal))),
                  Expanded(child: _Fact('Ongkir', rupiah(o.shipping))),
                ]),
                const Divider(height: 24, color: NColors.line),
                Row(children: [
                  const Icon(Icons.place_rounded, color: NColors.brandText),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${o.destination.building.name.split('·').first.trim()} · ${o.destination.room}', style: NText.bodyStrong)),
                ]),
              ]),
            ),
            const Spacer(),
            SlideToConfirm(label: 'Geser untuk Terima', onConfirmed: () => b.acceptOffer(of.orderId, of.courierId)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => b.rejectOffer(of.orderId, of.courierId), child: const Text('Tolak', style: TextStyle(color: NColors.ink, fontWeight: FontWeight.w700))),
          ]),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.a, this.b);
  final String a, b;

  @override
  Widget build(BuildContext context) => Column(children: [Text(a, style: NText.caption), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(b, style: NText.number(16)))]);
}
