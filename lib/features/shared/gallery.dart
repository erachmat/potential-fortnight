import 'package:flutter/material.dart';

import '../../core/brand/logo.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/motion/countdown_ring.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';

/// Rute tersembunyi /_gallery: semua komponen & animasi di satu halaman.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _qty = 2;
  int _chip = 0;
  int _nav = 0;
  int _amount = 40700;
  int _shake = 0;
  late final DateTime _exp = DateTime.now().add(const Duration(seconds: 60));

  Widget _sec(String t, Widget c) => Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: NText.h2), const SizedBox(height: 12), c]),
      );

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery komponen'), backgroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _sec('Logo', const Row(children: [NitipMark(size: 72), SizedBox(width: 16), NitipWordmark(size: 48)])),
        _sec('Tombol', Column(children: [
          PrimaryButton(label: 'Bayar Rp48.800', onPressed: () {}),
          const SizedBox(height: 8),
          const PrimaryButton(label: 'Nonaktif', onPressed: null),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Batalkan', onPressed: () {}),
          const SizedBox(height: 8),
          SlideToConfirm(label: 'Geser untuk Terima', onConfirmed: () {}),
        ])),
        _sec('Stepper + odometer', Row(children: [
          QtyStepper(qty: _qty, onInc: () => setState(() => _qty++), onDec: () => setState(() => _qty = (_qty - 1).clamp(0, 99))),
          const Spacer(),
          RupiahText(_amount, size: 24),
          IconButton(onPressed: () => setState(() => _amount += 8100), icon: const Icon(Icons.add_circle_outline)),
        ])),
        _sec('Chip kategori', CategoryChips(items: const ['Semua', 'Makanan', 'Minuman', 'Snack'], selected: _chip, onSelected: (i) => setState(() => _chip = i))),
        _sec('Countdown ring', CountdownRing(expiresAt: _exp, total: const Duration(seconds: 60), now: DateTime.now)),
        _sec('Centang + confetti', SizedBox(height: 140, child: ConfettiBurst(child: DrawnCheck(key: UniqueKey())))),
        _sec('Radar', const Center(child: RadarPulse(size: 200))),
        _sec('Shake', Center(child: GestureDetector(onTap: () => setState(() => _shake++), child: const NCard(child: Text('Tap untuk getar'))).shakeOn(_shake))),
        _sec('Skeleton & empty', Column(children: [const Skeleton(height: 56, radius: 16), const SizedBox(height: 8), const Skeleton(width: 180), SizedBox(height: 220, child: EmptyState(icon: Icons.shopping_bag_outlined, title: 'Belum ada jajan', message: 'Yuk lihat kantin.', action: SecondaryButton(label: 'Lihat kantin', onPressed: () {})))])),
        _sec('Makanan & KTM', Column(children: [
          Row(children: [for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(right: 8), child: FoodThumb(emoji: b.products[i].emoji, seed: i))]),
          const SizedBox(height: 12),
          const KtmCard(name: 'Rina Ayu Lestari', nim: '2023010145'),
        ])),
        _sec('Peta kampus', CampusMap(buildings: b.buildings, canteens: b.canteens, selectedBuilding: 'ga', route: const [Offset(.22, .30), Offset(.50, .22), Offset(.15, .62)], routeDone: .4, courierPos: const Offset(.4, .25))),
        _sec('Bottom nav', SizedBox(height: 80, child: FloatingPillNav(items: const [NavItem(Icons.home_rounded, 'Beranda'), NavItem(Icons.receipt_long_rounded, 'Pesanan', badge: 1), NavItem(Icons.notifications_rounded, 'Notif'), NavItem(Icons.person_rounded, 'Profil')], index: _nav, onChanged: (i) => setState(() => _nav = i)))),
      ]),
    );
  }
}
