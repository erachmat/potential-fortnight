import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/brand/brand.dart';
import '../../core/brand/logo.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/format.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/ticking.dart';
import '../../data/scope.dart';
import '../../demo/notifications/banner.dart';
import '../../domain/models/models.dart';
import 'admin_pages.dart';

class AdminHost extends InheritedWidget {
  const AdminHost({super.key, required this.onExit, required this.goTo, required super.child});
  final VoidCallback onExit;
  final ValueChanged<int> goTo;

  static AdminHost of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AdminHost>()!;

  @override
  bool updateShouldNotify(AdminHost old) => false;
}

/// Nitip Console — responsif (sidebar ≥ 900 px, drawer di bawahnya).
class AdminApp extends StatefulWidget {
  const AdminApp({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _in = false;
  int _page = 0;

  static const _items = [
    (Icons.space_dashboard_rounded, 'Dashboard'),
    (Icons.verified_user_rounded, 'Validasi'),
    (Icons.receipt_long_rounded, 'Pesanan'),
    (Icons.two_wheeler_rounded, 'Kurir'),
    (Icons.payments_rounded, 'Tukar Saldo'),
    (Icons.download_rounded, 'Laporan'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_in) return _AdminLogin(onLogin: () => setState(() => _in = true), onExit: widget.onExit);
    final b = context.backend;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final badges = {1: b.pendingCustomers.length, 2: b.undeliveredCount, 4: b.withdrawals.where((w) => w.status == WithdrawalStatus.requested).length};
    final pages = [const DashboardPage(), const ValidationPage(), const OrdersPage(), const CouriersPage(), const WithdrawalsPage(), const ReportPage()];

    Widget sidebar({bool drawer = false}) => Container(
          width: 240,
          color: NColors.ink,
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 24), child: Row(children: [NitipMark(size: 32, ink: Colors.white), SizedBox(width: 10), Text(Brand.consoleName, style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))])),
              for (var i = 0; i < _items.length; i++)
                _NavTile(icon: _items[i].$1, label: _items[i].$2, selected: i == _page, badge: badges[i] ?? 0, onTap: () { setState(() => _page = i); if (drawer) Navigator.pop(context); }),
              const Spacer(),
              _NavTile(icon: Icons.logout_rounded, label: 'Keluar', selected: false, badge: 0, onTap: widget.onExit),
              const SizedBox(height: 12),
            ]),
          ),
        );

    final content = AnimatedSwitcher(duration: Dur.base, child: KeyedSubtree(key: ValueKey(_page), child: pages[_page]));
    return AdminHost(
      onExit: widget.onExit,
      goTo: (i) => setState(() => _page = i),
      child: RoleBanner(
        role: AppRole.admin,
        child: wide
            ? Scaffold(backgroundColor: NColors.surfaceAlt, body: Row(children: [sidebar(), Expanded(child: content)]))
            : Scaffold(
                backgroundColor: NColors.surfaceAlt,
                appBar: AppBar(backgroundColor: Colors.white, title: Text(_items[_page].$2, style: NText.title), actions: const [SizedBox(width: 70)]),
                drawer: Drawer(child: sidebar(drawer: true)),
                body: content,
              ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.selected, required this.badge, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: AnimatedContainer(
              duration: Dur.base,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: selected ? NColors.brand : Colors.transparent, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(icon, size: 22, color: selected ? NColors.ink : Colors.white70),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: NText.bodyStrong.copyWith(color: selected ? NColors.ink : Colors.white))),
                if (badge > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: selected ? NColors.ink : NColors.brand, borderRadius: NRadius.pillBr), child: Text('$badge', style: NText.caption.copyWith(color: selected ? Colors.white : NColors.ink, fontWeight: FontWeight.w800))),
              ]),
            ),
          ),
        ),
      );
}

class _AdminLogin extends StatelessWidget {
  const _AdminLogin({required this.onLogin, required this.onExit});
  final VoidCallback onLogin, onExit;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NColors.surfaceAlt,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(NSpace.gutter), children: [
              const NitipMark(size: 56),
              const SizedBox(height: 16),
              const Text(Brand.consoleName, style: NText.h1),
              const Text('Masuk sebagai admin / owner kantin.', style: NText.body),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(hintText: 'Email admin')),
              const SizedBox(height: 12),
              const TextField(obscureText: true, decoration: InputDecoration(hintText: 'Kata sandi')),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Masuk', onPressed: onLogin),
              const SizedBox(height: 8),
              Center(child: TextButton.icon(onPressed: onLogin, icon: const Icon(Icons.bolt_rounded, size: 18), label: const Text('Pakai akun demo'))),
              Center(child: TextButton(onPressed: onExit, child: const Text('Ganti peran', style: NText.caption))),
            ]),
          ),
        ),
      );
}

// ============================ Dashboard (A-02) ============================

class KpiCard extends StatefulWidget {
  const KpiCard({super.key, required this.label, required this.value, required this.format, this.icon, this.accent = NColors.brand, this.warnWhenPositive = false});

  final String label;
  final int value;
  final String Function(int) format;
  final IconData? icon;
  final Color accent;
  final bool warnWhenPositive;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  int _delta = 0;
  int _deltaKey = 0;

  @override
  void didUpdateWidget(KpiCard old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      _delta = widget.value - old.value;
      _deltaKey++;
      Future<void>.delayed(const Duration(milliseconds: 2800), () { if (mounted) setState(() => _delta = 0); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final warn = widget.warnWhenPositive && widget.value > 0;
    return NCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (widget.icon != null) Container(width: 34, height: 34, decoration: BoxDecoration(color: widget.accent.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, size: 18, color: widget.accent == NColors.brand ? NColors.brandText : widget.accent)),
          const Spacer(),
          if (_delta != 0) Text(_delta > 0 ? '+${widget.format(_delta)}' : widget.format(_delta), key: ValueKey(_deltaKey), style: NText.caption.copyWith(color: _delta > 0 ? NColors.success : NColors.danger, fontWeight: FontWeight.w800)).animate().fadeIn(duration: 200.ms).slideY(begin: .6, end: -.2, duration: 600.ms),
        ]),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.value.toDouble()),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(widget.format(v.round()), style: NText.number(28, weight: FontWeight.w800, color: warn ? NColors.danger : NColors.ink))),
        ),
        Text(widget.label, style: NText.caption),
      ]),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final late = b.orders.where(b.isLate).toList();
    final pending = b.pendingCustomers;
    final kpis = [
      KpiCard(label: 'Transaksi hari ini', value: b.transactionsToday, format: (v) => '$v', icon: Icons.receipt_long_rounded),
      KpiCard(label: 'Pendapatan hari ini (biaya layanan 2%)', value: b.feeToday, format: (v) => rupiah(v), icon: Icons.trending_up_rounded, accent: NColors.success),
      KpiCard(label: 'Nilai belanja (GMV)', value: b.gmvToday, format: (v) => rupiah(v), icon: Icons.shopping_basket_rounded, accent: NColors.info),
      KpiCard(label: 'Ongkir untuk kurir', value: b.shippingToday, format: (v) => rupiah(v), icon: Icons.two_wheeler_rounded, accent: NColors.ink),
      KpiCard(label: 'Pesanan belum diantar', value: b.undeliveredCount, format: (v) => '$v', icon: Icons.hourglass_bottom_rounded, accent: NColors.warning, warnWhenPositive: true),
      KpiCard(label: 'Kurir aktif', value: b.activeCouriers, format: (v) => '$v', icon: Icons.groups_rounded, accent: NColors.success),
    ];
    final chart = NCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Transaksi per jam', style: NText.title),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: _HourChart(data: b.perHour)),
      ]),
    );
    final feed = NCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Aktivitas langsung', style: NText.title),
        const SizedBox(height: 12),
        if (b.activity.isEmpty) const Text('Belum ada aktivitas.', style: NText.body),
        for (final a in b.activity.take(8))
          KeyedSubtree(
            key: ValueKey('${a.at.microsecondsSinceEpoch}-${a.text}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(clock(a.at), style: NText.number(12, weight: FontWeight.w600, color: NColors.ink400)),
                const SizedBox(width: 12),
                Expanded(child: Text(a.text, style: NText.body.copyWith(color: NColors.ink))),
              ]),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -.4, curve: Crv.standard),
          ),
      ]),
    );
    final attention = NCard(
      color: late.isEmpty && pending.isEmpty ? NColors.surface : const Color(0xFFFFF4F2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Perlu perhatian', style: NText.title),
        const SizedBox(height: 8),
        if (late.isEmpty && pending.isEmpty) const Text('Semua aman 👍', style: NText.body),
        for (final o in late)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber_rounded, color: NColors.danger).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: .4, end: 1, duration: 700.ms),
            title: Text('${o.id} lewat SLA', style: NText.bodyStrong.copyWith(color: NColors.danger)),
            subtitle: Text('${b.courier(o.courierId!).name} · ${b.now.difference(o.acceptedAt!).inMinutes} menit', style: NText.caption),
            onTap: () => AdminHost.of(context).goTo(3),
          ),
        if (pending.isNotEmpty) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.verified_user_rounded, color: NColors.warning), title: Text('${pending.length} pendaftaran menunggu validasi', style: NText.bodyStrong), onTap: () => AdminHost.of(context).goTo(1)),
      ]),
    );

    return ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Ringkasan hari ini', style: NText.h1),
      Text('${Brand.campus} · diperbarui ${clock(b.now)}', style: NText.body),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (_, c) {
        final cols = c.maxWidth >= 1000 ? 3 : (c.maxWidth >= 560 ? 3 : 2);
        final w = (c.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(spacing: 12, runSpacing: 12, children: [for (final k in kpis) SizedBox(width: w, child: k)]);
      }),
      const SizedBox(height: 16),
      if (wide)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: Column(children: [chart, const SizedBox(height: 16), attention])), const SizedBox(width: 16), Expanded(flex: 2, child: feed)])
      else ...[attention, const SizedBox(height: 12), chart, const SizedBox(height: 12), feed],
    ]);
  }
}

class _HourChart extends StatelessWidget {
  const _HourChart({required this.data});
  final Map<int, int> data;

  @override
  Widget build(BuildContext context) {
    final maxY = (data.values.fold<int>(0, (a, v) => v > a ? v : a) + 2).toDouble();
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 2)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 6), child: Text(v.toInt().toString().padLeft(2, '0'), style: NText.caption.copyWith(fontSize: 10))))),
        ),
        barGroups: [
          for (final e in data.entries) BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: NColors.brand, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
        ],
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }
}

/// Dipakai halaman lain: tick tiap detik.
Widget live(WidgetBuilder b) => Ticking(builder: b);
