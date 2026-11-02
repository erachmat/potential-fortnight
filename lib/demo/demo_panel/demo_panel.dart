import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/motion/motion.dart';
import '../../data/backend.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import '../sound.dart';

Future<void> showDemoPanel(BuildContext context, {GoRouter? router}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.sheet))),
    builder: (_) => BackendScope(backend: BackendScope.read(context), child: DemoPanel(router: router)),
  );
}

class DemoPanel extends StatefulWidget {
  const DemoPanel({super.key, this.router});
  final GoRouter? router;

  @override
  State<DemoPanel> createState() => _DemoPanelState();
}

class _DemoPanelState extends State<DemoPanel> {
  Widget _h(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(t, style: NText.title));

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final clock = b.clock;
    final speed = clock is SimClock ? clock.speed : 1.0;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      maxChildSize: .95,
      builder: (_, controller) => ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: NColors.line, borderRadius: NRadius.pillBr))),
        const SizedBox(height: 12),
        const Text('Panel Demo', style: NText.h1),
        const Text('Hanya untuk presenter.', style: NText.body),
        _h('Data'),
        SecondaryButton(
          label: 'Reset semua data',
          icon: Icons.restart_alt_rounded,
          danger: true,
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Reset semua data?'),
                content: const Text('Semua pesanan, saldo, dan pendaftaran kembali ke data awal demo.'),
                actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset'))],
              ),
            );
            if (ok == true) {
              b.reset();
              if (context.mounted) setState(() {});
            }
          },
        ),
        _h('Timeout tawaran kurir'),
        SegmentedButton<int>(
          segments: const [ButtonSegment(value: 15, label: Text('15 detik')), ButtonSegment(value: 60, label: Text('60 detik'))],
          selected: {b.offerTimeout.inSeconds},
          onSelectionChanged: (s) => setState(() => b.offerTimeout = Duration(seconds: s.first)),
        ),
        _h('Kecepatan waktu simulasi'),
        SegmentedButton<double>(
          segments: const [ButtonSegment(value: 1, label: Text('1×')), ButtonSegment(value: 2, label: Text('2×')), ButtonSegment(value: 5, label: Text('5×'))],
          selected: {speed},
          onSelectionChanged: (s) => setState(() { if (clock is SimClock) clock.speed = s.first; }),
        ),
        _h('Perilaku kurir bot'),
        for (final c in b.couriers.where((c) => c.id != 'andi'))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: Text('${c.name} ★${c.rating.toStringAsFixed(1)}', style: NText.bodyStrong)),
              DropdownButton<BotBehavior>(
                value: c.behavior,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: BotBehavior.manual, child: Text('Manual')),
                  DropdownMenuItem(value: BotBehavior.ignore, child: Text('Abaikan')),
                  DropdownMenuItem(value: BotBehavior.reject, child: Text('Tolak')),
                  DropdownMenuItem(value: BotBehavior.acceptAfter, child: Text('Terima (5 dtk)')),
                ],
                onChanged: (v) => setState(() { c.behavior = v!; b.refresh(); }),
              ),
              Switch(value: c.online, onChanged: (v) { b.setCourierOnline(c.id, v); setState(() {}); }),
            ]),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-pilot Sari', style: NText.bodyStrong),
          subtitle: const Text('Terima + selesaikan pesanan otomatis (demo 1 HP)', style: NText.caption),
          value: b.autoPilotCourierId == 'sari',
          onChanged: (v) => setState(() { b.autoPilotCourierId = v ? 'sari' : null; b.refresh(); }),
        ),
        _h('Pintasan'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          SecondaryButton(label: 'Picu order masuk', icon: Icons.notifications_active_rounded, onPressed: () => _spawnOrder(b)),
          SecondaryButton(label: 'Kurir di kantin', icon: Icons.storefront_rounded, onPressed: () => _jump(b, 1)),
          SecondaryButton(label: 'Pesanan sampai', icon: Icons.flag_rounded, onPressed: () => _jump(b, 2)),
        ]),
        _h('Umpan balik'),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Suara'), value: Sound.enabled, onChanged: (v) => setState(() => Sound.enabled = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Haptik'), value: Feel.haptics, onChanged: (v) => setState(() => Feel.haptics = v)),
        if (widget.router != null) ...[
          _h('Pindah peran'),
          Wrap(spacing: 8, children: [
            for (final r in const [('Customer', '/customer'), ('Kurir', '/courier'), ('Admin', '/admin'), ('Pilih peran', '/roles')])
              SecondaryButton(label: r.$1, onPressed: () { Navigator.pop(context); widget.router!.go(r.$2); }),
          ]),
        ],
      ]),
    );
  }

  /// Buat pesanan siap pakai (2 pisang + 4 kopi, Gedung A) lalu dibayar -> tawaran ke kurir.
  void _spawnOrder(Backend b) {
    if (b.cart.isEmpty) {
      b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: 2);
      b.addToCart(b.products.firstWhere((p) => p.id == 'b1'), qty: 4);
    }
    final o = b.placeOrder(Destination(building: b.buildings.first, room: 'Lt. 3, R. 305', landmark: 'Depan lab komputer'));
    b.simulatePayment(o.id);
    Navigator.pop(context);
  }

  void _jump(Backend b, int level) {
    final o = b.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.expired && o.id != 'NTP-0398' && o.status.index >= OrderStatus.courierAssigned.index && o.status.index < OrderStatus.delivered.index).firstOrNull;
    if (o == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Belum ada pesanan yang sedang diantar.')));
      return;
    }
    if (level == 1) {
      for (final c in o.canteenIds.take(1)) {
        b.markCanteenPurchased(o.id, c);
      }
    } else {
      for (final c in o.canteenIds) {
        b.markCanteenPurchased(o.id, c);
      }
      if (o.status == OrderStatus.delivering) b.deliver(o.id);
    }
    Navigator.pop(context);
  }
}
