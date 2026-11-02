import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/format/format.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import 'cart_fx.dart';
import 'cart_screens.dart';
import 'customer_app.dart';
import 'order_flow.dart';

/// Kerangka Customer: tab + bottom nav pill + FAB keranjang.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final unread = b.notifications.where((n) => n.role == AppRole.customer && !n.read).length;
    final hasActive = b.activeCustomerOrder != null;
    final tabs = [const HomeTab(), const OrdersTab(), const NotificationsTab(), const ProfileTab()];
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: AnimatedSwitcher(duration: Dur.base, child: KeyedSubtree(key: ValueKey(_tab), child: tabs[_tab]))),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingPillNav(
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
            items: [
              const NavItem(Icons.home_rounded, 'Beranda'),
              NavItem(Icons.receipt_long_rounded, 'Pesanan', badge: hasActive ? 1 : 0),
              NavItem(Icons.notifications_rounded, 'Notifikasi', badge: unread),
              const NavItem(Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
        const Positioned(right: 20, bottom: 92, child: CartFab()),
      ]),
    );
  }
}

/// FAB keranjang. Anchor `cartKey` selalu ada supaya animasi terbang punya target.
class CartFab extends StatelessWidget {
  const CartFab({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final qty = b.cartQty;
    final price = b.cartPrice;
    return KeyedSubtree(
      key: CustomerHost.of(context).cartKey,
      child: AnimatedScale(
        scale: qty > 0 ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Crv.pop,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(qty),
          tween: Tween(begin: 1.18, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Crv.pop,
          builder: (_, s, child) => Transform.scale(scale: s, child: child),
          child: Semantics(
            button: true,
            label: 'Keranjang, $qty item',
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 6, right: 18),
                decoration: BoxDecoration(color: NColors.brand, borderRadius: NRadius.pillBr, boxShadow: NShadow.float),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 44, height: 44, decoration: const BoxDecoration(color: NColors.ink, shape: BoxShape.circle), alignment: Alignment.center, child: Text('$qty', style: NText.number(16, color: Colors.white))),
                  const SizedBox(width: 10),
                  RupiahText(price.subtotal, size: 15, color: NColors.ink),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _cat = 0;
  String _q = '';
  static const _cats = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final active = b.activeCustomerOrder;
    final loc = b.preferredBuilding ?? b.lastDestination?.building ?? b.buildings.first;
    var list = b.products.where((p) => p.available).toList();
    if (_cat > 0) list = list.where((p) => p.category.index == _cat - 1).toList();
    if (_q.isNotEmpty) list = list.where((p) => p.name.toLowerCase().contains(_q.toLowerCase())).toList();
    final canteens = _q.isEmpty ? b.canteens : b.canteens.where((c) => c.name.toLowerCase().contains(_q.toLowerCase())).toList();

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.only(bottom: 170), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(NSpace.gutter, 12, NSpace.gutter, 0),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickBuilding(context),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Antar ke', style: NText.caption),
                  Row(children: [Flexible(child: Text(loc.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NText.bodyStrong)), const Icon(Icons.keyboard_arrow_down_rounded, size: 20)]),
                ]),
              ),
            ),
            const SizedBox(width: 56), // ruang untuk badge MODE DEMO
            Avatar(b.me.name, size: 40),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(NSpace.gutter, 20, NSpace.gutter, 0),
          child: RichText(text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 28, height: 1.2, color: NColors.ink600), children: [TextSpan(text: 'Mau '), TextSpan(text: 'jajan', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink)), TextSpan(text: ' apa\nhari ini?')])),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(NSpace.gutter, 16, NSpace.gutter, 0),
          child: TextField(onChanged: (v) => setState(() => _q = v), decoration: const InputDecoration(hintText: 'Cari jajanan atau kantin', prefixIcon: Icon(Icons.search_rounded)), textInputAction: TextInputAction.search),
        ),
        if (active != null) Padding(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 16, NSpace.gutter, 0), child: _ActiveBanner(order: active)),
        const SizedBox(height: 16),
        const _PromoCarousel(),
        const SizedBox(height: 16),
        CategoryChips(items: _cats, selected: _cat, onSelected: (i) => setState(() => _cat = i)),
        const _SectionTitle('Kantin di sekitarmu'),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NSpace.gutter),
            itemCount: canteens.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _CanteenCard(canteens[i]).animate(delay: (i * 40).ms).fadeIn().slideX(begin: .1),
          ),
        ),
        const _SectionTitle('Lagi populer'),
        if (list.isEmpty)
          const SizedBox(height: 200, child: EmptyState(icon: Icons.search_off_rounded, title: 'Nggak ketemu', message: 'Coba kata kunci lain ya.'))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NSpace.gutter),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .78,
              children: [for (var i = 0; i < list.length; i++) ProductCard(list[i], index: i).animate(delay: Duration(milliseconds: 40 * (i < 8 ? i : 0))).fadeIn(duration: Dur.base).slideY(begin: .08)],
            ),
          ),
      ]),
    );
  }

  void _pickBuilding(BuildContext context) {
    final b = context.api;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.sheet))),
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(20), children: [
          const Text('Antar ke gedung mana?', style: NText.h2),
          const SizedBox(height: 8),
          for (final g in b.buildings) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.apartment_rounded), title: Text(g.name, style: NText.bodyStrong), onTap: () { b.preferredBuilding = g; b.refresh(); Navigator.pop(c); }),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.t);
  final String t;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 24, NSpace.gutter, 12), child: Text(t, style: NText.h2));
}

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => NCard(
        color: NColors.ink,
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrderFlowScreen(orderId: order.id))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: NColors.brand, shape: BoxShape.circle), child: const Icon(Icons.two_wheeler_rounded, color: NColors.ink)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pesanan ${order.id}', style: NText.bodyStrong.copyWith(color: Colors.white)), Text(order.status.label, style: NText.caption.copyWith(color: Colors.white70))])),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ]),
      );
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _c = PageController(viewportFraction: .9);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(() => setState(() => _page = _c.page ?? 0));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Ongkir mulai Rp5.000', 'Satu pesanan, banyak kantin 🍌☕', '🛵'),
      ('Kurir sesama mahasiswa', 'Cepat, ramah, dan hafal kampus', '🎒'),
    ];
    return SizedBox(
      height: 132,
      child: PageView.builder(
        controller: _c,
        itemCount: items.length,
        itemBuilder: (_, i) {
          final off = (i - _page) * 30;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: i == 0 ? NColors.brand : NColors.ink, borderRadius: NRadius.sheetBr),
              child: Stack(children: [
                Positioned(right: -10 + off, bottom: -10, child: Text(items[i].$3, style: const TextStyle(fontSize: 84))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(items[i].$1, style: NText.h2.copyWith(color: i == 0 ? NColors.ink : Colors.white)),
                  const SizedBox(height: 4),
                  SizedBox(width: 200, child: Text(items[i].$2, style: NText.body.copyWith(color: i == 0 ? NColors.ink : Colors.white70))),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _CanteenCard extends StatelessWidget {
  const _CanteenCard(this.k);
  final Canteen k;

  @override
  Widget build(BuildContext context) {
    final parts = k.name.split('·');
    return SizedBox(
      width: 200,
      child: NCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CanteenScreen(canteenId: k.id))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CanteenAvatar(k.code, size: 40),
          const Spacer(),
          Text(parts.length > 1 ? parts[1].trim() : k.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NText.title),
          Text('${parts.first.trim()} · ${k.hours}', style: NText.caption),
        ]),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard(this.p, {super.key, this.index = 0});
  final Product p;
  final int index;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final k = b.canteen(p.canteenId);
    final qty = b.qtyOf(p.id);
    return NCard(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: LayoutBuilder(builder: (_, c) => FoodThumb(emoji: p.emoji, size: c.maxWidth, radius: 16, seed: p.id.hashCode))),
        const SizedBox(height: 8),
        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NText.title.copyWith(fontSize: 14)),
        Text('Kantin ${k.code}', style: NText.caption),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: Text(rupiah(p.price), style: NText.number(14, color: NColors.brandText))),
          if (qty == 0)
            Builder(builder: (btn) => Semantics(button: true, label: 'Tambah ${p.name}', child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => addProductFx(btn, p), child: const SizedBox(width: 44, height: 44, child: Center(child: CircleAvatar(radius: 16, backgroundColor: NColors.brand, child: Icon(Icons.add_rounded, size: 20, color: NColors.ink)))))))
          else
            QtyStepper(qty: qty, compact: true, onInc: () => addProductFx(context, p), onDec: () => b.decFromCart(p.id)),
        ]),
      ]),
    );
  }
}

/// C-07 — detail kantin.
class CanteenScreen extends StatelessWidget {
  const CanteenScreen({super.key, required this.canteenId});
  final String canteenId;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final k = b.canteen(canteenId);
    final items = b.products.where((p) => p.canteenId == canteenId).toList();
    return Scaffold(
      body: Stack(children: [
        ListView(padding: const EdgeInsets.only(bottom: 120), children: [
          Container(
            padding: EdgeInsets.fromLTRB(NSpace.gutter, MediaQuery.paddingOf(context).top + 8, NSpace.gutter, 24),
            decoration: const BoxDecoration(color: NColors.ink, borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              const SizedBox(height: 8),
              Row(children: [CanteenAvatar(k.code, size: 56), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k.name.split('·').last.trim(), style: NText.h1.copyWith(color: Colors.white)), Text('Buka ${k.hours}', style: NText.body.copyWith(color: Colors.white70))]))]),
            ]),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(NSpace.gutter, 0, NSpace.gutter, 12),
              child: _MenuRow(items[i]).animate(delay: (i * 40).ms).fadeIn().slideY(begin: .08),
            ),
        ]),
        const Positioned(right: 20, bottom: 24, child: CartFab()),
      ]),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.p);
  final Product p;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final qty = b.qtyOf(p.id);
    return NCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        FoodThumb(emoji: p.emoji, size: 64, seed: p.id.hashCode),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: NText.title), const SizedBox(height: 2), Text(rupiah(p.price), style: NText.number(14, color: NColors.brandText))])),
        if (qty == 0)
          Builder(builder: (btn) => Semantics(button: true, label: 'Tambah ${p.name}', child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => addProductFx(btn, p), child: const SizedBox(width: 48, height: 48, child: Center(child: CircleAvatar(radius: 18, backgroundColor: NColors.brand, child: Icon(Icons.add_rounded, color: NColors.ink)))))))
        else
          QtyStepper(qty: qty, onInc: () => addProductFx(context, p), onDec: () => b.decFromCart(p.id)),
      ]),
    );
  }
}

/// C-17 — daftar pesanan (aktif / selesai).
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final mine = b.orders.where((o) => o.customerId == b.customerId).toList();
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.fromLTRB(NSpace.gutter, 16, NSpace.gutter, 12), child: Text('Pesanan', style: NText.h1)),
        Expanded(
          child: mine.isEmpty
              ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'Belum ada pesanan', message: 'Pesanan kamu akan muncul di sini.')
              : ListView(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 0, NSpace.gutter, 120), children: [
                  for (final o in mine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrderFlowScreen(orderId: o.id))),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(o.id, style: NText.title),
                            Text(o.lines.map((l) => '${l.qty}× ${l.name}').join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: NText.caption),
                            const SizedBox(height: 6),
                            StatusBadge(o.status.label, color: o.status == OrderStatus.completed || o.status == OrderStatus.delivered ? NColors.success : (o.status == OrderStatus.expired ? NColors.ink400 : NColors.brandText)),
                          ])),
                          Text(rupiah(o.total), style: NText.number(15)),
                        ]),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final list = b.notifications.where((n) => n.role == AppRole.customer).toList();
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 16, NSpace.gutter, 12), child: Row(children: [const Expanded(child: Text('Notifikasi', style: NText.h1)), if (list.any((n) => !n.read)) TextButton(onPressed: () { for (final n in list) { n.read = true; } b.refresh(); }, child: const Text('Tandai dibaca'))])),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(icon: Icons.notifications_none_rounded, title: 'Belum ada notifikasi')
              : ListView(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 0, NSpace.gutter, 120), children: [
                  for (final n in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NCard(
                        color: n.read ? NColors.surface : NColors.brandSoft,
                        child: Row(children: [
                          const CircleAvatar(backgroundColor: NColors.brand, child: Icon(Icons.notifications_rounded, color: NColors.ink)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n.title, style: NText.bodyStrong), Text(n.body, style: NText.caption)])),
                          Text(clock(n.at), style: NText.caption),
                        ]),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final me = b.me;
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(NSpace.gutter, 16, NSpace.gutter, 120), children: [
        const Text('Profil', style: NText.h1),
        const SizedBox(height: 16),
        NCard(child: Row(children: [
          Avatar(me.name, size: 60),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(me.name, style: NText.title), Text('NIM ${me.nim}', style: NText.caption), const SizedBox(height: 6), const StatusBadge('KTM terverifikasi', color: NColors.success)])),
        ])),
        const SizedBox(height: 12),
        NCard(child: Column(children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.mail_outline_rounded), title: Text(me.email, style: NText.body)),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.phone_outlined), title: Text(me.phone, style: NText.body)),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.help_outline_rounded), title: Text('Bantuan (WhatsApp admin)', style: NText.body)),
        ])),
        const SizedBox(height: 20),
        SecondaryButton(label: 'Keluar', icon: Icons.logout_rounded, danger: true, onPressed: CustomerHost.of(context).onExit),
      ]),
    );
  }
}
