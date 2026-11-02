import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/format/format.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import '../../domain/pricing.dart';
import 'cart_fx.dart';
import 'order_flow.dart';

/// Baris rincian biaya (dipakai keranjang, ringkasan, e-receipt).
class PriceRows extends StatelessWidget {
  const PriceRows({super.key, required this.subtotal, required this.shipping, required this.fee, required this.qty, this.animate = true});

  final int subtotal, shipping, fee, qty;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    Widget row(String l, int v, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l, style: bold ? NText.title : NText.body),
            RupiahText(v, size: bold ? 20 : 14, weight: bold ? FontWeight.w800 : FontWeight.w600, animate: animate),
          ]),
        );
    return Column(children: [
      row('Subtotal', subtotal),
      row(qty > 0 ? 'Ongkir (${Pricing.shippingTierLabel(qty)})' : 'Ongkir', shipping),
      row('Biaya layanan 2%', fee),
      const Divider(height: 20, color: NColors.line),
      row('Total', subtotal + shipping + fee, bold: true),
    ]);
  }
}

/// Meter 0–20 item dengan penanda tier ongkir (M-16).
class ItemMeter extends StatelessWidget {
  const ItemMeter({super.key, required this.qty});
  final int qty;

  @override
  Widget build(BuildContext context) {
    final over = qty >= Pricing.maxQty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('$qty/${Pricing.maxQty} item', style: NText.bodyStrong.copyWith(color: over ? NColors.danger : NColors.ink)),
        const Spacer(),
        if (qty > 0) StatusBadge('Ongkir ${rupiah(Pricing.shipping(qty))}', color: NColors.brandText),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 22,
        child: LayoutBuilder(builder: (_, c) {
          final w = c.maxWidth;
          return Stack(clipBehavior: Clip.none, children: [
            Positioned(top: 6, left: 0, right: 0, child: Container(height: 8, decoration: BoxDecoration(color: NColors.line, borderRadius: NRadius.pillBr))),
            Positioned(
              top: 6,
              left: 0,
              child: AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, width: w * (qty / Pricing.maxQty), height: 8, decoration: BoxDecoration(color: over ? NColors.danger : NColors.brand, borderRadius: NRadius.pillBr)),
            ),
            for (final t in const [5, 10])
              Positioned(
                left: w * (t / Pricing.maxQty) - 7,
                top: 3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: qty > t ? NColors.ink : Colors.white, shape: BoxShape.circle, border: Border.all(color: qty > t ? NColors.ink : NColors.ink400, width: 2)),
                ),
              ),
          ]);
        }),
      ),
      const SizedBox(height: 2),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('1–5', style: NText.caption), Text('6–10', style: NText.caption), Text('11–20', style: NText.caption)]),
    ]);
  }
}

/// C-09 — keranjang.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _shake = 0;
  int? _lastShipping;
  String? _tierChip;
  Timer? _chipTimer;

  @override
  void dispose() {
    _chipTimer?.cancel();
    super.dispose();
  }

  void _trackTier(int qty) {
    final ship = qty > 0 ? Pricing.shipping(qty) : 0;
    if (_lastShipping != null && ship != _lastShipping && qty > 0) {
      _tierChip = 'Ongkir jadi ${rupiah(ship)} (${Pricing.shippingTierLabel(qty)})';
      _chipTimer?.cancel();
      _chipTimer = Timer(const Duration(milliseconds: 2500), () { if (mounted) setState(() => _tierChip = null); });
    }
    _lastShipping = ship;
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final qty = b.cartQty;
    final price = b.cartPrice;
    _trackTier(qty);
    final byCanteen = <String, List<CartLine>>{};
    for (final l in b.cart) {
      byCanteen.putIfAbsent(l.product.canteenId, () => []).add(l);
    }
    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      appBar: AppBar(title: const Text('Keranjang', style: NText.title), backgroundColor: NColors.surfaceAlt, elevation: 0),
      body: b.cart.isEmpty
          ? EmptyState(icon: Icons.shopping_bag_outlined, title: 'Belum ada jajan di keranjang', message: 'Pilih dulu dari kantin favoritmu.', action: SecondaryButton(label: 'Lihat kantin', onPressed: () => Navigator.pop(context)))
          : Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
                  NCard(child: ItemMeter(qty: qty)).shakeOn(_shake),
                  const SizedBox(height: 12),
                  for (final e in byCanteen.entries) ...[
                    NCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [CanteenAvatar(e.key, size: 30), const SizedBox(width: 10), Expanded(child: Text(b.canteen(e.key).name, style: NText.title))]),
                        const SizedBox(height: 8),
                        for (final l in e.value)
                          Dismissible(
                            key: ValueKey('cart-${l.product.id}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => b.removeFromCart(l.product.id),
                            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: NColors.danger.withValues(alpha: .1), child: const Icon(Icons.delete_outline_rounded, color: NColors.danger)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [
                                FoodThumb(emoji: l.product.emoji, size: 52, radius: 14, seed: l.product.id.hashCode),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.product.name, style: NText.bodyStrong), Text(rupiah(l.product.price), style: NText.caption)])),
                                QtyStepper(
                                  qty: l.qty,
                                  onDec: () => b.decFromCart(l.product.id),
                                  onInc: () {
                                    if (!b.addToCart(l.product)) {
                                      Feel.heavy();
                                      setState(() => _shake++);
                                      toast(context, 'Maksimal 20 item per pesanan. Kurangi dulu salah satu item ya.', error: true);
                                    } else {
                                      Feel.light();
                                    }
                                  },
                                ),
                              ]),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  NCard(
                    child: Column(children: [
                      AnimatedSwitcher(
                        duration: Dur.slow,
                        transitionBuilder: (w, a) => SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Crv.standard)), child: FadeTransition(opacity: a, child: w)),
                        child: _tierChip == null
                            ? const SizedBox(key: ValueKey('none'), width: double.infinity)
                            : Container(
                                key: ValueKey(_tierChip),
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: NColors.brandSoft, borderRadius: BorderRadius.circular(12)),
                                child: Text(_tierChip!, style: NText.bodyStrong.copyWith(color: NColors.brandText)),
                              ),
                      ),
                      PriceRows(subtotal: price.subtotal, shipping: price.shipping, fee: price.fee, qty: qty),
                    ]),
                  ),
                ]),
              ),
              SafeArea(
                top: false,
                child: Padding(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 8, NSpace.gutter, 12), child: PrimaryButton(label: 'Lanjut · ${rupiah(price.total)}', onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddressScreen())))),
              ),
            ]),
    );
  }
}

/// C-10 — alamat antar (peta kampus ilustrasi).
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Building? _b;
  final _room = TextEditingController();
  final _landmark = TextEditingController();

  @override
  void initState() {
    super.initState();
    final last = context.api.lastDestination;
    final pref = context.api.preferredBuilding;
    _b = pref ?? last?.building;
    if (last != null && last.building.id == _b?.id) {
      _room.text = last.room;
      _landmark.text = last.landmark;
    }
  }

  @override
  void dispose() {
    _room.dispose();
    _landmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final last = b.lastDestination;
    final valid = _b != null && _room.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Antar ke mana?', style: NText.title), backgroundColor: Colors.white, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
        CampusMap(buildings: b.buildings, canteens: b.canteens, selectedBuilding: _b?.id, onBuildingTap: (g) { Feel.select(); setState(() => _b = g); }, height: 300),
        const SizedBox(height: 8),
        Text(_b == null ? 'Ketuk gedung di peta untuk memilih.' : _b!.name, style: _b == null ? NText.body : NText.title),
        const SizedBox(height: 16),
        if (last != null)
          Align(alignment: Alignment.centerLeft, child: ActionChip(label: Text('Terakhir: ${last.building.name.split('·').first.trim()}, ${last.room}'), onPressed: () => setState(() { _b = last.building; _room.text = last.room; _landmark.text = last.landmark; }))),
        const SizedBox(height: 8),
        TextField(controller: _room, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Lantai / ruang (mis. Lt. 3, R. 305)')),
        const SizedBox(height: 12),
        TextField(controller: _landmark, decoration: const InputDecoration(hintText: 'Patokan (mis. depan lab komputer)')),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Pakai Alamat Ini',
          onPressed: valid ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SummaryScreen(dest: Destination(building: _b!, room: _room.text.trim(), landmark: _landmark.text.trim().isEmpty ? '-' : _landmark.text.trim())))) : null,
        ),
      ]),
    );
  }
}

/// C-11 — ringkasan pesanan.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.dest});
  final Destination dest;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final price = b.cartPrice;
    final byCanteen = <String, List<CartLine>>{};
    for (final l in b.cart) {
      byCanteen.putIfAbsent(l.product.canteenId, () => []).add(l);
    }
    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      appBar: AppBar(title: const Text('Ringkasan pesanan', style: NText.title), backgroundColor: NColors.surfaceAlt, elevation: 0),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
            NCard(child: Row(children: [
              const CircleAvatar(backgroundColor: NColors.brandSoft, child: Icon(Icons.place_rounded, color: NColors.brandText)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(dest.building.name, style: NText.title), Text('${dest.room} · ${dest.landmark}', style: NText.caption)])),
            ])),
            const SizedBox(height: 12),
            for (final e in byCanteen.entries) ...[
              NCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    leading: CanteenAvatar(e.key, size: 30),
                    title: Text(b.canteen(e.key).name, style: NText.title),
                    children: [for (final l in e.value) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text('${l.qty}× ${l.product.name}', style: NText.body)), Text(rupiah(l.product.price * l.qty), style: NText.number(14, weight: FontWeight.w600))]))],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            NCard(child: PriceRows(subtotal: price.subtotal, shipping: price.shipping, fee: price.fee, qty: price.qty, animate: false)),
            const SizedBox(height: 12),
            NCard(child: Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: NColors.ink, borderRadius: BorderRadius.circular(8)), child: const Text('QRIS', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
              const SizedBox(width: 12),
              const Expanded(child: Text('Bayar pakai m-banking / e-wallet apa saja', style: NText.body)),
              const Icon(Icons.check_circle_rounded, color: NColors.success),
            ])),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.gutter, 8, NSpace.gutter, 12),
            child: PrimaryButton(
              label: 'Bayar dengan QRIS · ${rupiah(price.total)}',
              onPressed: () {
                final o = context.api.placeOrder(dest);
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => OrderFlowScreen(orderId: o.id)), (r) => r.isFirst);
              },
            ),
          ),
        ),
      ]),
    );
  }
}
