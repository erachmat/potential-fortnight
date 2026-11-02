import 'package:flutter/material.dart';

import '../../core/brand/brand.dart';
import '../../core/brand/logo.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/format/format.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';
import '../../demo/notifications/banner.dart';
import '../../domain/models/models.dart';
import 'job_screen.dart';
import 'offer_screen.dart';
import 'wallet_screens.dart';

class CourierHost extends InheritedWidget {
  const CourierHost({super.key, required this.onExit, required super.child});
  final VoidCallback onExit;

  static CourierHost of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<CourierHost>()!;

  @override
  bool updateShouldNotify(CourierHost old) => false;
}

/// Aplikasi Kurir. Order masuk tampil sebagai layar penuh di atas navigator (K-03).
class CourierApp extends StatefulWidget {
  const CourierApp({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  State<CourierApp> createState() => _CourierAppState();
}

class _CourierAppState extends State<CourierApp> {
  int _epoch = 0;
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final offer = _loggedIn ? b.pendingOfferForCourier(b.courierId) : null;
    return CourierHost(
      onExit: () => setState(() { _epoch++; _loggedIn = false; widget.onExit(); }),
      child: RoleBanner(
        role: AppRole.courier,
        child: Stack(children: [
          Positioned.fill(
            child: Navigator(
              key: ValueKey(_epoch),
              onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => CourierLogin(onLoggedIn: () => setState(() => _loggedIn = true))),
            ),
          ),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 550),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (w, a) => SlideTransition(position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(a), child: w),
              child: offer == null ? const SizedBox.shrink(key: ValueKey('no-offer')) : OfferScreen(key: ValueKey('offer-${offer.orderId}-${offer.courierId}'), offer: offer),
            ),
          ),
        ]),
      ),
    );
  }
}

/// K-01 — Masuk kurir.
class CourierLogin extends StatefulWidget {
  const CourierLogin({super.key, required this.onLoggedIn});
  final VoidCallback onLoggedIn;

  @override
  State<CourierLogin> createState() => _CourierLoginState();
}

class _CourierLoginState extends State<CourierLogin> {
  final _id = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _login() {
    final b = context.api;
    final c = b.couriers.where((c) => c.nim == _id.text.trim()).firstOrNull ?? b.courier('sari');
    b.courierId = c.id;
    widget.onLoggedIn();
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const CourierHome()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NColors.ink,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
          const SizedBox(height: 32),
          const NitipMark(size: 56, ink: Colors.white),
          const SizedBox(height: 20),
          const Text(Brand.courierName, style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const Text(Brand.courierTagline, style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 32),
          TextField(controller: _id, style: const TextStyle(color: NColors.ink), decoration: const InputDecoration(hintText: 'NIM kurir')),
          const SizedBox(height: 12),
          TextField(controller: _pw, obscureText: true, decoration: const InputDecoration(hintText: 'Kata sandi'), onSubmitted: (_) => _login()),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: ActionChip(avatar: const Icon(Icons.bolt_rounded, size: 18, color: NColors.brandText), label: const Text('Pakai akun demo (Sari)'), backgroundColor: NColors.brandSoft, side: BorderSide.none, onPressed: () { _id.text = '2022010211'; _pw.text = 'demo1234'; })),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Masuk', light: true, onPressed: _login),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: CourierHost.of(context).onExit, child: const Text('Ganti peran', style: TextStyle(color: Colors.white70)))),
        ]),
      ),
    );
  }
}

/// K-02 — beranda kurir.
class CourierHome extends StatelessWidget {
  const CourierHome({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final c = b.meCourier;
    final recap = b.recap(c.id);
    final active = b.orders.where((o) => o.courierId == c.id && o.status.isActiveDelivery).firstOrNull;
    final today = b.orders.where((o) => o.courierId == c.id && o.status.index >= OrderStatus.delivered.index).take(6).toList();
    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      body: ListView(padding: EdgeInsets.zero, children: [
        _Header(courier: c),
        Padding(
          padding: const EdgeInsets.all(NSpace.gutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WalletScreen())),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Saldo tersedia', style: NText.caption), const SizedBox(height: 4), RupiahText(b.availableOf(c.id), size: 28, weight: FontWeight.w800)])),
                const Icon(Icons.account_balance_wallet_rounded, color: NColors.brandText, size: 32),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Stat('Pesanan', '${recap.count}')),
              const SizedBox(width: 10),
              Expanded(child: _Stat('Ongkir', rupiah(recap.shipping))),
              const SizedBox(width: 10),
              Expanded(child: _Stat('Rating', '★ ${c.rating.toStringAsFixed(1)}')),
            ]),
            if (active != null) ...[
              const SizedBox(height: 20),
              const Text('Pesanan berjalan', style: NText.h2),
              const SizedBox(height: 10),
              NCard(
                color: NColors.ink,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobScreen(orderId: active.id))),
                child: Row(children: [
                  const CircleAvatar(backgroundColor: NColors.brand, child: Icon(Icons.shopping_bag_rounded, color: NColors.ink)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(active.id, style: NText.title.copyWith(color: Colors.white)), Text('${active.status.label} · ${active.destination.building.name.split('·').first.trim()}', style: NText.caption.copyWith(color: Colors.white70))])),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Riwayat terbaru', style: NText.h2),
            const SizedBox(height: 10),
            if (today.isEmpty)
              const NCard(child: Text('Belum ada pesanan selesai.', style: NText.body))
            else
              for (final o in today)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NCard(child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.id, style: NText.bodyStrong), Text('${o.totalQty} item · ${o.canteenIds.length} kantin', style: NText.caption)])), Text(rupiah(o.courierEarning, sign: true), style: NText.number(15, color: NColors.success))])),
                ),
          ]),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => NCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: NText.caption), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: NText.number(17)))]),
      );
}

/// Header gelap + toggle online/offline (M-29).
class _Header extends StatelessWidget {
  const _Header({required this.courier});
  final Courier courier;

  @override
  Widget build(BuildContext context) {
    final b = context.api;
    final on = courier.online;
    return Container(
      padding: EdgeInsets.fromLTRB(NSpace.gutter, MediaQuery.paddingOf(context).top + 16, NSpace.gutter, 28),
      decoration: const BoxDecoration(color: NColors.ink, borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Avatar(courier.name, size: 44, dark: true),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Halo, ${courier.name.split(' ').first}', style: NText.title.copyWith(color: Colors.white)), Text('NIM ${courier.nim}', style: NText.caption.copyWith(color: Colors.white60))])),
          const SizedBox(width: 56),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () { Feel.medium(); b.setCourierOnline(courier.id, !on); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: on ? NColors.brand : const Color(0xFF2B2623), borderRadius: NRadius.pillBr),
            child: Stack(alignment: Alignment.center, children: [
              Center(child: Text(on ? (courier.busy ? 'ONLINE · Sedang mengantar' : 'ONLINE · Menunggu pesanan…') : 'OFFLINE · Ketuk untuk mulai', style: NText.bodyStrong.copyWith(color: on ? NColors.ink : Colors.white70))),
              AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 56, height: 56, decoration: BoxDecoration(color: on ? NColors.ink : Colors.white24, shape: BoxShape.circle), child: Icon(on ? Icons.two_wheeler_rounded : Icons.power_settings_new_rounded, color: Colors.white)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
