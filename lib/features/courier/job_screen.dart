import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/contact.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/format.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';
import '../../demo/sound.dart';
import '../../domain/models/models.dart';

/// K-04 + K-05 — detail per kantin, checklist belanja, antar, serahkan.
class JobScreen extends StatefulWidget {
  const JobScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final Set<String> _checked = {};
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final o = b.orderById(widget.orderId)!;
    final done = o.status.index >= OrderStatus.delivered.index;
    if (done) return EarningsView(order: o);

    // pesanan dibatalkan admin / dialihkan
    if (o.courierId != b.courierId) {
      return Scaffold(
        appBar: AppBar(title: Text(o.id)),
        body: EmptyState(icon: Icons.info_outline_rounded, title: 'Pesanan dialihkan', message: 'Pesanan ini tidak lagi menjadi tugasmu.', action: SecondaryButton(label: 'Kembali', onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst))),
      );
    }

    final elapsed = o.acceptedAt == null ? Duration.zero : b.now.difference(o.acceptedAt!);
    final slaLeft = b.slaLimit - elapsed;
    final slaColor = slaLeft.isNegative ? NColors.danger : (slaLeft.inMinutes < 10 ? NColors.warning : NColors.success);
    final canteens = o.canteenIds.map(b.canteen).toList();
    final customer = b.customers.where((c) => c.id == o.customerId).firstOrNull;
    final delivering = o.status == OrderStatus.delivering;

    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      body: Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(NSpace.gutter, MediaQuery.paddingOf(context).top + 8, NSpace.gutter, 20),
          decoration: const BoxDecoration(color: NColors.ink, borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
              Text(o.id, style: NText.title.copyWith(color: Colors.white)),
              const Spacer(),
              const SizedBox(width: 56),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _Metric('Berjalan', mmss(elapsed), Colors.white)),
              Expanded(child: _Metric(slaLeft.isNegative ? 'Lewat SLA' : 'Sisa SLA', mmss(slaLeft.abs()), slaColor)),
              Expanded(child: _Metric('Kamu terima', rupiah(o.courierEarning), NColors.brand)),
            ]),
          ]),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
            Row(children: [
              _StepDot('Belanja', active: !delivering, done: delivering),
              const Expanded(child: Divider(color: NColors.line, thickness: 2)),
              _StepDot('Antar', active: delivering, done: false),
              const Expanded(child: Divider(color: NColors.line, thickness: 2)),
              const _StepDot('Serahkan', active: false, done: false),
            ]),
            const SizedBox(height: 16),
            for (final k in canteens) _CanteenCard(order: o, canteen: k, checked: _checked, onChanged: () => setState(() {})),
            NCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.place_rounded, color: NColors.brandText), const SizedBox(width: 8), Expanded(child: Text(o.destination.building.name, style: NText.title))]),
                const SizedBox(height: 4),
                Text('${o.destination.room} · ${o.destination.landmark}', style: NText.body),
                if (customer != null) ...[
                  const Divider(height: 24, color: NColors.line),
                  Row(children: [
                    Expanded(child: Text('${o.customerName} · ${customer.phone}', style: NText.caption)),
                    IconButton.filledTonal(onPressed: () => openWhatsApp(customer.phone, text: 'Halo kak, aku kurir pesanan ${o.id}'), icon: const Icon(Icons.chat_rounded), tooltip: 'WhatsApp'),
                    IconButton.filledTonal(onPressed: () => callPhone(customer.phone), icon: const Icon(Icons.call_rounded), tooltip: 'Telepon'),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            NCard(color: NColors.brandSoft, child: Column(children: [
              _Line('Belanja', rupiah(o.subtotal)),
              _Line('Ongkir', rupiah(o.shipping)),
              const Divider(height: 16, color: NColors.line),
              _Line('Kamu terima', rupiah(o.courierEarning), bold: true),
            ])),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.gutter, 8, NSpace.gutter, 12),
            child: delivering
                ? SlideToConfirm(label: 'Geser kalau sudah diserahkan', onConfirmed: () => b.deliver(o.id))
                : const PrimaryButton(label: 'Selesaikan belanja di semua kantin', onPressed: null),
          ),
        ),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [Text(label, style: NText.caption.copyWith(color: Colors.white60)), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: NText.number(20, color: color)))]);
}

class _Line extends StatelessWidget {
  const _Line(this.a, this.b, {this.bold = false});
  final String a, b;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: bold ? NText.title : NText.body), Text(b, style: NText.number(bold ? 17 : 14, weight: bold ? FontWeight.w800 : FontWeight.w600))]));
}

class _StepDot extends StatelessWidget {
  const _StepDot(this.label, {required this.active, required this.done});
  final String label;
  final bool active, done;

  @override
  Widget build(BuildContext context) => Column(children: [
        AnimatedContainer(duration: Dur.slow, width: 24, height: 24, decoration: BoxDecoration(color: done ? NColors.success : (active ? NColors.brand : Colors.white), shape: BoxShape.circle, border: Border.all(color: done ? NColors.success : (active ? NColors.brand : NColors.line), width: 2)), child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null),
        const SizedBox(height: 4),
        Text(label, style: NText.caption),
      ]);
}

/// Teks yang "dicoret" dengan garis yang ditarik (M-31).
class StrikeText extends StatelessWidget {
  const StrikeText(this.text, {super.key, required this.struck, this.style});
  final String text;
  final bool struck;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final st = (style ?? NText.body).copyWith(color: struck ? NColors.ink400 : null);
    return Stack(alignment: Alignment.centerLeft, children: [
      Text(text, style: st),
      Positioned.fill(
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(tween: Tween(end: struck ? 1 : 0), duration: Dur.base, curve: Curves.easeOutCubic, builder: (_, v, _) => FractionallySizedBox(widthFactor: v, child: Container(height: 2, color: NColors.ink400))),
        ),
      ),
    ]);
  }
}

class _CanteenCard extends StatelessWidget {
  const _CanteenCard({required this.order, required this.canteen, required this.checked, required this.onChanged});
  final Order order;
  final Canteen canteen;
  final Set<String> checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final b = context.api;
    final lines = order.lines.where((l) => l.canteenId == canteen.id).toList();
    final sub = lines.fold<int>(0, (a, l) => a + l.total);
    final bought = order.purchasedCanteens.contains(canteen.id);
    final allChecked = lines.every((l) => checked.contains('${canteen.id}:${l.productId}'));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedSize(
        duration: Dur.slow,
        curve: Crv.standard,
        alignment: Alignment.topCenter,
        child: NCard(
          color: bought ? const Color(0xFFEAF7EE) : NColors.surface,
          child: bought
              ? Row(children: [const Icon(Icons.check_circle_rounded, color: NColors.success, size: 28).animate().scale(duration: 300.ms, curve: Crv.pop), const SizedBox(width: 12), Expanded(child: Text('${canteen.name} · selesai dibeli', style: NText.bodyStrong))])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(canteen.name, style: NText.title),
                  const SizedBox(height: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: NColors.brandSoft, borderRadius: BorderRadius.circular(10)), child: Text('Siapkan uang ${rupiah(sub)} untuk ${canteen.name.split('·').first.trim()}', style: NText.caption.copyWith(color: NColors.brandText, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 8),
                  for (final l in lines)
                    InkWell(
                      onTap: () {
                        Feel.select();
                        final key = '${canteen.id}:${l.productId}';
                        checked.contains(key) ? checked.remove(key) : checked.add(key);
                        onChanged();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          AnimatedContainer(duration: Dur.fast, width: 24, height: 24, decoration: BoxDecoration(color: checked.contains('${canteen.id}:${l.productId}') ? NColors.success : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: checked.contains('${canteen.id}:${l.productId}') ? NColors.success : NColors.ink400, width: 2)), child: checked.contains('${canteen.id}:${l.productId}') ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null),
                          const SizedBox(width: 12),
                          Expanded(child: StrikeText('${l.qty}× ${l.name}   @${rupiah(l.price)}', struck: checked.contains('${canteen.id}:${l.productId}'), style: NText.bodyStrong)),
                          Text(rupiah(l.total), style: NText.number(14, weight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  const SizedBox(height: 8),
                  PrimaryButton(label: 'Selesai belanja di ${canteen.name.split('·').first.trim()}', onPressed: allChecked ? () { Feel.medium(); b.markCanteenPurchased(order.id, canteen.id); } : null),
                ]),
        ),
      ),
    );
  }
}

/// K-06 — selesai: koin berhamburan, saldo bergulir.
class EarningsView extends StatefulWidget {
  const EarningsView({super.key, required this.order});
  final Order order;

  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
  late int _shown;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final b = context.api;
    final after = b.availableOf(widget.order.courierId!);
    _shown = after - widget.order.courierEarning;
    Sound.coin();
    Future<void>.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => _shown = after); });
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Scaffold(
      backgroundColor: NColors.ink,
      body: SafeArea(
        child: ConfettiBurst(
          child: Padding(
            padding: const EdgeInsets.all(NSpace.gutter),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🪙', style: TextStyle(fontSize: 64)).animate().scale(duration: 500.ms, curve: Crv.pop),
              const SizedBox(height: 12),
              Text(rupiah(o.courierEarning, sign: true), style: NText.number(48, weight: FontWeight.w800, color: NColors.brand)).animate().fadeIn(duration: 400.ms).slideY(begin: .5, end: 0, curve: Crv.pop),
              const Text('masuk ke saldo kamu', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2B2623), borderRadius: NRadius.cardBr),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Belanja', style: NText.body.copyWith(color: Colors.white70)), Text(rupiah(o.subtotal), style: NText.number(15, color: Colors.white))]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Ongkir', style: NText.body.copyWith(color: Colors.white70)), Text(rupiah(o.shipping), style: NText.number(15, color: Colors.white))]),
                  const Divider(height: 24, color: Colors.white24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Saldo tersedia', style: NText.body.copyWith(color: Colors.white70)), RupiahText(_shown, size: 22, weight: FontWeight.w800, color: Colors.white)]),
                ]),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Kembali ke Beranda', light: true, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
            ]),
          ),
        ),
      ),
    );
  }
}
