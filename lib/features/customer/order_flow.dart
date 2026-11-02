import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/brand/brand.dart';
import '../../core/contact.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/format/format.dart';
import '../../core/motion/countdown_ring.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/odometer.dart';
import '../../data/backend.dart';
import '../../data/scope.dart';
import '../../demo/sound.dart';
import '../../domain/models/models.dart';
import 'cart_fx.dart';
import 'cart_screens.dart';

/// Satu layar yang berganti tahap mengikuti status pesanan (C-12..C-16), sehingga
/// perubahan live (kurir menerima, admin membatalkan kurir) langsung tercermin.
class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  OrderStatus? _prev;
  bool _showPaid = false;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final o = b.orderById(widget.orderId)!;
    if (_prev == OrderStatus.awaitingPayment && o.status != OrderStatus.awaitingPayment && o.status != OrderStatus.expired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showPaid = true);
        Sound.success();
        _t = Timer(const Duration(milliseconds: 1700), () { if (mounted) setState(() => _showPaid = false); });
      });
    }
    _prev = o.status;

    final Widget stage;
    if (_showPaid) {
      stage = _PaidView(key: const ValueKey('paid'), order: o);
    } else {
      stage = switch (o.status) {
        OrderStatus.awaitingPayment => QrisView(key: const ValueKey('qris'), order: o),
        OrderStatus.paid || OrderStatus.searchingCourier || OrderStatus.noCourierFound => SearchingView(key: const ValueKey('search'), order: o),
        OrderStatus.courierAssigned || OrderStatus.purchasing || OrderStatus.delivering => TrackingView(key: const ValueKey('track'), order: o),
        OrderStatus.delivered || OrderStatus.completed => DeliveredView(key: const ValueKey('done'), order: o),
        OrderStatus.expired => const EmptyState(key: ValueKey('exp'), icon: Icons.timer_off_rounded, title: 'Pesanan kedaluwarsa', message: 'Pembayaran tidak diterima tepat waktu.'),
      };
    }
    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: NColors.surfaceAlt,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
        title: Text(o.id, style: NText.title),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (w, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(a), child: w)),
        child: stage,
      ),
    );
  }
}

class _PaidView extends StatelessWidget {
  const _PaidView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => ConfettiBurst(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const DrawnCheck(size: 120),
          const SizedBox(height: 20),
          RichText(text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 28, color: NColors.ink600), children: [TextSpan(text: 'Pembayaran '), TextSpan(text: 'diterima', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink))])),
          const SizedBox(height: 8),
          RupiahText(order.total, size: 22),
        ]),
      );
}

class _CircleReveal extends CustomClipper<Path> {
  _CircleReveal(this.t);
  final double t;

  @override
  Path getClip(Size s) => Path()..addOval(Rect.fromCircle(center: s.center(Offset.zero), radius: s.longestSide * .75 * t));

  @override
  bool shouldReclip(_CircleReveal o) => o.t != t;
}

/// C-12 — QRIS dinamis (nominal tercatat di QR).
class QrisView extends StatefulWidget {
  const QrisView({super.key, required this.order});
  final Order order;

  @override
  State<QrisView> createState() => _QrisViewState();
}

class _QrisViewState extends State<QrisView> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  bool _paying = false;

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    if (!reduceMotion(context)) await _sweep.forward().orCancel.catchError((_) {});
    if (mounted) context.api.simulatePayment(widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final o = widget.order;
    final exp = o.createdAt.add(const Duration(minutes: 15));
    return ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
      NCard(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Text(Brand.merchantName, style: NText.bodyStrong),
          const Text('QRIS dinamis · nominal sudah tercatat', style: NText.caption),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, t, child) => ClipPath(clipper: _CircleReveal(t), child: child),
            child: Stack(alignment: Alignment.center, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: NColors.line)),
                child: QrImageView(data: 'NITIP-DEMO|${o.id}|${o.total}', size: 220, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: NColors.ink), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: NColors.ink)),
              ),
              if (_paying)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sweep,
                    builder: (_, _) => Align(alignment: Alignment(0, -1 + 2 * _sweep.value), child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: NColors.brand, boxShadow: [BoxShadow(color: NColors.brand.withValues(alpha: .7), blurRadius: 14, spreadRadius: 2)]))),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          RupiahText(o.total, size: 32, weight: FontWeight.w800),
          const SizedBox(height: 4),
          Text('Berlaku ${mmss(exp.difference(b.now))}', style: NText.caption),
          const SizedBox(height: 4),
          const Text('Scan pakai m-banking / e-wallet apa saja', style: NText.body),
        ]),
      ),
      const SizedBox(height: 16),
      PrimaryButton(label: 'Simulasi Bayar', icon: Icons.bolt_rounded, loading: _paying, onPressed: _pay),
      const SizedBox(height: 8),
      Center(child: TextButton(onPressed: _paying ? null : () { b.cancelUnpaid(o.id); Navigator.of(context).popUntil((r) => r.isFirst); }, child: const Text('Batalkan pesanan'))),
      const SizedBox(height: 4),
      const Center(child: Text('Tombol simulasi hanya ada di mode demo.', style: NText.caption)),
    ]);
  }
}

/// C-14 — mencari kurir (radar + countdown + kandidat berpindah).
class SearchingView extends StatelessWidget {
  const SearchingView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final offer = b.offerFor(order.id);
    final cand = offer == null ? null : b.courier(offer.courierId);
    final past = b.offers.where((x) => x.orderId == order.id && x.result != OfferResult.pending).toList();

    if (order.status == OrderStatus.noCourierFound) {
      return EmptyState(icon: Icons.two_wheeler_rounded, title: 'Kurir lagi penuh nih', message: 'Semua kurir sedang sibuk atau offline. Coba lagi sebentar.', action: PrimaryButton(label: 'Coba Lagi', onPressed: () => b.retrySearch(order.id)));
    }
    return Column(children: [
      const SizedBox(height: 16),
      RichText(textAlign: TextAlign.center, text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 24, color: NColors.ink600), children: [TextSpan(text: 'Mencari '), TextSpan(text: 'kurir', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink)), TextSpan(text: '…')])),
      Expanded(
        child: Center(
          child: Stack(alignment: Alignment.center, children: [
            const RadarPulse(size: 320),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (w, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: w)),
              child: cand == null || offer == null
                  ? const SizedBox(key: ValueKey('none'), width: 130, height: 130)
                  : CountdownRing(
                      key: ValueKey(cand.id),
                      expiresAt: offer.expiresAt,
                      total: offer.expiresAt.difference(offer.createdAt),
                      now: () => b.now,
                      size: 130,
                      stroke: 8,
                      child: Avatar(cand.name, size: 92),
                    ),
            ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(NSpace.gutter),
        child: NCard(
          child: Column(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (w, a) => SlideTransition(position: Tween(begin: const Offset(0, .6), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: w)),
              child: Text(
                cand == null ? 'Menyiapkan tawaran…' : (past.isEmpty ? 'Menawarkan ke ${cand.name} ★${cand.rating.toStringAsFixed(1)}' : 'Mencari kurir lain… ${cand.name} ★${cand.rating.toStringAsFixed(1)}'),
                key: ValueKey(cand?.id),
                style: NText.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Kalau tidak diterima dalam waktunya, otomatis pindah ke kurir lain.', style: NText.caption, textAlign: TextAlign.center),
            for (final p in past)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.close_rounded, size: 16, color: NColors.danger),
                  const SizedBox(width: 6),
                  Text('${b.courier(p.courierId).name} · ${p.result == OfferResult.rejected ? 'menolak' : 'tidak merespons'}', style: NText.caption.copyWith(color: NColors.ink400)),
                ]).animate().fadeIn().slideY(begin: .5),
              ),
          ]),
        ),
      ),
    ]);
  }
}

/// Posisi kurir di peta mengikuti progres sungguhan.
class _RoutePlan {
  _RoutePlan(this.points, this.pos, this.done);
  final List<Offset> points;
  final Offset pos;
  final double done;

  static _RoutePlan of(Backend b, Order o) {
    const start = Offset(.5, .5);
    final cs = o.canteenIds.map(b.canteen).toList();
    final dest = Offset(o.destination.building.mapX, o.destination.building.mapY);
    final pts = [start, ...cs.map((c) => Offset(c.mapX, c.mapY)), dest];
    final n = cs.length;
    double idx;
    switch (o.status) {
      case OrderStatus.courierAssigned:
        idx = 0;
      case OrderStatus.purchasing:
        idx = (o.purchasedCanteens.length + 1).clamp(1, n).toDouble();
      case OrderStatus.delivering:
        idx = n + .5;
      default:
        idx = n + 1.0;
    }
    final lo = idx.floor().clamp(0, pts.length - 1);
    final hi = idx.ceil().clamp(0, pts.length - 1);
    final pos = Offset.lerp(pts[lo], pts[hi], idx - lo)!;
    return _RoutePlan(pts, pos, idx / (pts.length - 1));
  }
}

class _Elapsed extends StatefulWidget {
  const _Elapsed({required this.since, required this.now});
  final DateTime since;
  final DateTime Function() now;

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late final Timer _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('Sudah ${mmss(widget.now().difference(widget.since))}', style: NText.number(14, color: NColors.brandText));
}

/// C-15 — lacak pesanan.
class TrackingView extends StatelessWidget {
  const TrackingView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final c = order.courierId == null ? null : b.courier(order.courierId!);
    final plan = _RoutePlan.of(b, order);
    final st = order.status;
    final purchasing = st == OrderStatus.purchasing || st == OrderStatus.courierAssigned;
    final canteens = order.canteenIds.map(b.canteen).toList();

    Widget step(String title, {required _S s, List<Widget> subs = const [], bool last = false}) => _TimelineStep(title: title, state: s, subs: subs, last: last);

    return ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
      CampusMap(
        buildings: b.buildings,
        canteens: canteens,
        selectedBuilding: order.destination.building.id,
        route: plan.points,
        routeDone: plan.done,
        courierPos: plan.pos,
        doneCanteens: order.purchasedCanteens,
        height: 230,
      ),
      const SizedBox(height: 12),
      if (c != null)
        NCard(
          child: Row(children: [
            Avatar(c.name, size: 52),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.name, style: NText.title), Text('★ ${c.rating.toStringAsFixed(1)} · NIM ${c.nim.substring(0, 4)}••••••', style: NText.caption), if (order.acceptedAt != null) _Elapsed(since: order.acceptedAt!, now: () => b.now)])),
            IconButton.filledTonal(onPressed: () => openWhatsApp(c.phone, text: 'Halo kak, soal pesanan ${order.id}'), icon: const Icon(Icons.chat_rounded), tooltip: 'WhatsApp'),
            IconButton.filledTonal(onPressed: () => callPhone(c.phone), icon: const Icon(Icons.call_rounded), tooltip: 'Telepon'),
          ]),
        ).animate().flip(direction: Axis.horizontal, begin: -.25, end: 0, duration: 600.ms, curve: Curves.easeOutCubic).fadeIn(),
      const SizedBox(height: 12),
      NCard(
        child: Column(children: [
          step('Dibayar', s: _S.done),
          step('Kurir menuju kantin', s: st == OrderStatus.courierAssigned ? _S.active : _S.done),
          step('Belanja di kantin', s: purchasing ? (st == OrderStatus.courierAssigned ? _S.pending : _S.active) : _S.done, subs: [
            for (final k in canteens)
              Row(children: [
                Icon(order.purchasedCanteens.contains(k.id) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: order.purchasedCanteens.contains(k.id) ? NColors.success : NColors.ink400),
                const SizedBox(width: 8),
                Text(k.name, style: NText.caption),
              ]),
          ]),
          step('Diantar ke ${order.destination.building.name.split('·').first.trim()}', s: st == OrderStatus.delivering ? _S.active : _S.pending),
          step('Sampai', s: _S.pending, last: true),
        ]),
      ),
      const SizedBox(height: 12),
      NCard(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Ringkasan pesanan · ${rupiah(order.total)}', style: NText.title),
            children: [for (final l in order.lines) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text('${l.qty}× ${l.name}', style: NText.body)), Text(rupiah(l.total), style: NText.number(13))]))],
          ),
        ),
      ),
    ]);
  }
}

enum _S { done, active, pending }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.state, this.subs = const [], this.last = false});
  final String title;
  final _S state;
  final List<Widget> subs;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) { _S.done => NColors.success, _S.active => NColors.brand, _S.pending => NColors.line };
    Widget dot = AnimatedContainer(
      duration: Dur.slow,
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: state == _S.pending ? Colors.white : color, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: state == _S.done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
    );
    if (state == _S.active && !reduceMotion(context)) {
      dot = dot.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(.85, .85), end: const Offset(1.15, 1.15), duration: 800.ms);
    }
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 26,
          child: Column(children: [
            dot,
            if (!last) Expanded(child: AnimatedContainer(duration: Dur.slow, width: 3, margin: const EdgeInsets.symmetric(vertical: 2), color: state == _S.done ? NColors.success : NColors.line)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: state == _S.pending ? NText.body : NText.bodyStrong),
              for (final s in subs) Padding(padding: const EdgeInsets.only(top: 6), child: s),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// C-16 — pesanan sampai + rating.
class DeliveredView extends StatefulWidget {
  const DeliveredView({super.key, required this.order});
  final Order order;

  @override
  State<DeliveredView> createState() => _DeliveredViewState();
}

class _DeliveredViewState extends State<DeliveredView> {
  int _stars = 0;
  final Set<String> _tags = {};

  static const _emoji = ['🙂', '😕', '😐', '🙂', '😊', '😋'];

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final o = widget.order;
    final c = o.courierId == null ? null : b.courier(o.courierId!);
    final rated = o.rating != null;
    return ConfettiBurst(
      child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
        const SizedBox(height: 8),
        const Center(child: Text('😋', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 8),
        RichText(textAlign: TextAlign.center, text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 26, color: NColors.ink600), children: [TextSpan(text: 'Selamat '), TextSpan(text: 'menikmati', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink)), TextSpan(text: '!')])),
        const SizedBox(height: 4),
        Text('Pesanan ${o.id} sudah sampai.', style: NText.body, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (!rated && c != null)
          NCard(
            child: Column(children: [
              Row(children: [Avatar(c.name, size: 44), const SizedBox(width: 12), Expanded(child: Text('Gimana kurirnya, ${c.name.split(' ').first}?', style: NText.title))]),
              const SizedBox(height: 12),
              AnimatedSwitcher(duration: Dur.fast, child: Text(_emoji[_stars], key: ValueKey(_stars), style: const TextStyle(fontSize: 40))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () { Feel.select(); setState(() => _stars = i); },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 40, color: i <= _stars ? NColors.warning : NColors.ink400)
                          .animate(key: ValueKey('$i-${i <= _stars}'), delay: Duration(milliseconds: i <= _stars ? i * 50 : 0))
                          .scale(begin: i <= _stars ? const Offset(.6, .6) : const Offset(1, 1), end: const Offset(1, 1), duration: 250.ms, curve: Crv.pop),
                    ),
                  ),
              ]),
              Wrap(spacing: 8, children: [for (final t in const ['Cepat', 'Ramah', 'Sesuai pesanan']) FilterChip(label: Text(t), selected: _tags.contains(t), onSelected: (v) => setState(() => v ? _tags.add(t) : _tags.remove(t)))]),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Kirim Penilaian',
                onPressed: _stars == 0 ? null : () {
                  b.confirmReceived(o.id, stars: _stars);
                  toast(context, 'Makasih! Penilaianmu sudah dikirim ⭐');
                },
              ),
              if (o.status == OrderStatus.delivered) TextButton(onPressed: () => b.confirmReceived(o.id), child: const Text('Pesanan sudah diterima, nilai nanti')),
            ]),
          )
        else
          NCard(child: Column(children: [
            Text(rated ? 'Terima kasih sudah menilai ${'⭐' * (o.rating ?? 0)}' : 'Pesanan selesai', style: NText.title),
            const SizedBox(height: 12),
            PriceRows(subtotal: o.subtotal, shipping: o.shipping, fee: o.fee, qty: o.totalQty, animate: false),
          ])),
        const SizedBox(height: 16),
        SecondaryButton(label: 'Kembali ke Beranda', onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
      ]),
    );
  }
}
