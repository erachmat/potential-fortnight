import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/contact.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/format/format.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/ticking.dart';
import '../../data/backend.dart';
import '../../data/scope.dart';
import '../../data/seed/seed.dart';
import '../../domain/models/models.dart';
import 'report.dart';

Widget _title(String t, [String? sub]) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t, style: NText.h1),
      if (sub != null) Text(sub, style: NText.body),
    ],
  ),
);

// ============================ Validasi (A-03) ============================

/// Kaca pembesar mengikuti kursor/jari di atas KTM (M-36).
class Magnifier extends StatefulWidget {
  const Magnifier({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });
  final double width, height;
  final Widget child;

  @override
  State<Magnifier> createState() => _MagnifierState();
}

class _MagnifierState extends State<Magnifier> {
  Offset? _pos;
  static const _z = 2.5;
  static const _r = 65.0;

  void _set(Offset p) => setState(
    () => _pos = Offset(
      p.dx.clamp(0, widget.width),
      p.dy.clamp(0, widget.height),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _set(e.localPosition),
      onExit: (_) => setState(() => _pos = null),
      child: GestureDetector(
        onPanStart: (d) => _set(d.localPosition),
        onPanUpdate: (d) => _set(d.localPosition),
        onPanEnd: (_) => setState(() => _pos = null),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: widget.width,
                height: widget.height,
                child: widget.child,
              ),
              if (_pos != null)
                Positioned(
                  left: _pos!.dx - _r,
                  top: _pos!.dy - _r,
                  child: IgnorePointer(
                    child: Container(
                      width: _r * 2,
                      height: _r * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: NColors.brand, width: 3),
                        boxShadow: NShadow.float,
                      ),
                      child: ClipOval(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Transform.translate(
                            offset: Offset(
                              _r - _pos!.dx * _z,
                              _r - _pos!.dy * _z,
                            ),
                            child: Transform.scale(
                              scale: _z,
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: widget.width,
                                height: widget.height,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  String? _selId;
  String? _stamp;

  Future<void> _decide(
    Backend b,
    Customer c,
    bool approve, {
    String? reason,
  }) async {
    setState(() => _stamp = approve ? 'DISETUJUI' : 'DITOLAK');
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    approve ? b.approveCustomer(c.id) : b.rejectCustomer(c.id, reason ?? '-');
    setState(() {
      _stamp = null;
      _selId = null;
    });
  }

  Future<void> _reject(Backend b, Customer c) async {
    final reasons = [
      'NIM tidak sesuai KTM',
      'Foto KTM buram',
      'Nama tidak sesuai KTM',
    ];
    final r = await showDialog<String>(
      context: context,
      builder: (d) => SimpleDialog(
        title: const Text('Alasan penolakan'),
        children: [
          for (final x in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(d, x),
              child: Text(x),
            ),
        ],
      ),
    );
    if (r != null) await _decide(b, c, false, reason: r);
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final pending = b.pendingCustomers;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final sel =
        pending.where((c) => c.id == _selId).firstOrNull ??
        (pending.isEmpty ? null : pending.first);

    final list = ListView(
      shrinkWrap: true,
      physics: wide ? null : const NeverScrollableScrollPhysics(),
      children: [
        for (final c in pending)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NCard(
              color: c.id == sel?.id ? NColors.brandSoft : NColors.surface,
              onTap: () => setState(() => _selId = c.id),
              child: Row(
                children: [
                  Avatar(c.name, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: NText.bodyStrong),
                        Text('NIM ${c.nim}', style: NText.caption),
                      ],
                    ),
                  ),
                  Text(
                    c.submittedAt == null
                        ? ''
                        : ago(b.now.difference(c.submittedAt!)),
                    style: NText.caption,
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    Widget detail(Customer c) {
      final ktmNim = Seed.ktmNim[c.id] ?? c.nim;
      final nimOk = ktmNim == c.nim;
      Widget cmp(String label, String input, String ktm, bool ok) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 56, child: Text(label, style: NText.caption)),
            Expanded(child: Text(input, style: NText.bodyStrong)),
            Expanded(
              child: Text(
                ktm,
                style: NText.bodyStrong.copyWith(
                  color: ok ? NColors.ink : NColors.danger,
                ),
              ),
            ),
            Icon(
              ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: ok ? NColors.success : NColors.danger,
              size: 22,
            ),
          ],
        ),
      );
      return Stack(
        children: [
          NCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: NText.h2),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (_, cs) {
                    final w = cs.maxWidth.clamp(280, 460).toDouble();
                    return Center(
                      child: Magnifier(
                        width: w,
                        height: w * .63,
                        child: KtmCard(name: c.name, nim: ktmNim, width: w),
                      ),
                    );
                  },
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Arahkan kursor / geser jari untuk memperbesar',
                      style: NText.caption,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 56),
                    Expanded(
                      child: Text(
                        'Data pendaftaran',
                        style: NText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Pada KTM',
                        style: NText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
                cmp('Nama', c.name, c.name, true),
                cmp('NIM', c.nim, ktmNim, nimOk),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Tolak',
                        danger: true,
                        onPressed: _stamp != null ? null : () => _reject(b, c),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: 'Setujui Akun',
                        onPressed: _stamp != null
                            ? null
                            : () => _decide(b, c, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_stamp != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child:
                      Transform.rotate(
                            angle: -.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _stamp == 'DISETUJUI'
                                      ? NColors.success
                                      : NColors.danger,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withValues(alpha: .9),
                              ),
                              child: Text(
                                _stamp!,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: _stamp == 'DISETUJUI'
                                      ? NColors.success
                                      : NColors.danger,
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(2.2, 2.2),
                            end: const Offset(1, 1),
                            duration: 300.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 150.ms),
                ),
              ),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _title(
          'Validasi pendaftaran',
          'Cocokkan data yang diinput dengan foto KTM.',
        ),
        if (sel == null)
          const SizedBox(
            height: 300,
            child: EmptyState(
              icon: Icons.verified_rounded,
              title: 'Semua sudah divalidasi',
              message: 'Pendaftaran baru akan muncul di sini.',
            ),
          )
        else if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 320, child: list),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: KeyedSubtree(
                    key: ValueKey(sel.id),
                    child: detail(sel),
                  ),
                ),
              ),
            ],
          )
        else ...[
          list,
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: KeyedSubtree(key: ValueKey(sel.id), child: detail(sel)),
          ),
        ],
      ],
    );
  }
}

// ============================ Pesanan (A-04) ============================

Color statusColor(OrderStatus s) => switch (s) {
  OrderStatus.completed || OrderStatus.delivered => NColors.success,
  OrderStatus.expired => NColors.ink400,
  OrderStatus.noCourierFound => NColors.danger,
  OrderStatus.searchingCourier ||
  OrderStatus.paid ||
  OrderStatus.awaitingPayment => NColors.warning,
  _ => NColors.info,
};

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _f = 0;
  static const _filters = ['Semua', 'Belum diantar', 'Selesai', 'Telat'];

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    var list = [...b.orders]
      ..sort((a, c) => c.createdAt.compareTo(a.createdAt));
    list = switch (_f) {
      1 => list.where((o) => o.status.isUndelivered).toList(),
      2 =>
        list
            .where(
              (o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.delivered,
            )
            .toList(),
      3 => list.where(b.isLate).toList(),
      _ => list,
    };
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _title('Status pesanan', '${b.undeliveredCount} pesanan belum diantar'),
        CategoryChips(
          items: _filters,
          selected: _f,
          onSelected: (i) => setState(() => _f = i),
        ),
        const SizedBox(height: 16),
        Ticking(
          builder: (_) => Column(
            children: [
              for (final o in list.take(40))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _OrderRow(order: o, late: b.isLate(o)),
                ),
              if (list.isEmpty)
                const SizedBox(
                  height: 240,
                  child: EmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'Tidak ada pesanan',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.late});
  final Order order;
  final bool late;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final o = order;
    final dur = o.acceptedAt != null && o.status.isActiveDelivery
        ? mmss(b.now.difference(o.acceptedAt!))
        : '';
    Widget row = NCard(
      color: late ? const Color(0xFFFFF1F0) : NColors.surface,
      onTap: () => _detail(context, o),
      child: Row(
        children: [
          SizedBox(width: 84, child: Text(o.id, style: NText.bodyStrong)),
          Expanded(
            flex: 2,
            child: Text(
              o.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NText.body,
            ),
          ),
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              children: [
                for (final k in o.canteenIds) CanteenAvatar(k, size: 22),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 700)
            Expanded(
              flex: 2,
              child: Text(
                o.courierId == null ? '-' : b.courier(o.courierId!).name,
                style: NText.body,
              ),
            ),
          SizedBox(
            width: 92,
            child: Text(
              rupiah(o.total),
              textAlign: TextAlign.right,
              style: NText.number(14),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusBadge(
                o.status.label,
                color: late ? NColors.danger : statusColor(o.status),
              ),
            ),
          ),
          SizedBox(
            width: 58,
            child: Text(
              dur,
              textAlign: TextAlign.right,
              style: NText.number(
                12,
                color: late ? NColors.danger : NColors.ink600,
              ),
            ),
          ),
        ],
      ),
    );
    if (late) {
      row = row
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .custom(
            duration: 900.ms,
            builder: (_, v, w) => DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: NRadius.cardBr,
                border: Border.all(
                  color: NColors.danger.withValues(alpha: .2 + .6 * v),
                  width: 2,
                ),
              ),
              child: w,
            ),
          );
    }
    return row;
  }

  void _detail(BuildContext context, Order o) {
    final b = context.api;
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('${o.id} · ${o.status.label}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${o.destination.building.name}\n${o.destination.label}',
                style: NText.body,
              ),
              const SizedBox(height: 12),
              for (final l in o.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${l.qty}× ${l.name}', style: NText.body),
                      ),
                      Text(rupiah(l.total), style: NText.number(13)),
                    ],
                  ),
                ),
              const Divider(),
              Text(
                'Ongkir ${rupiah(o.shipping)} · Layanan ${rupiah(o.fee)} · Total ${rupiah(o.total)}',
                style: NText.bodyStrong,
              ),
              if (o.courierId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Kurir: ${b.courier(o.courierId!).name}',
                    style: NText.body,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// ============================ Kurir (A-05, A-06) ============================

class CouriersPage extends StatelessWidget {
  const CouriersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final active = b.orders
        .where((o) => o.status.isActiveDelivery && o.courierId != null)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _title('Kurir', 'Pantau kurir yang sedang mengantar.'),
        const Text('Sedang mengantar', style: NText.h2),
        const SizedBox(height: 10),
        if (active.isEmpty)
          const NCard(
            child: Text(
              'Tidak ada kurir yang sedang mengantar.',
              style: NText.body,
            ),
          ),
        Ticking(
          builder: (_) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final o in active)
                SizedBox(width: 420, child: _OnProgressCard(order: o)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Semua kurir', style: NText.h2),
        const SizedBox(height: 10),
        for (final c in b.couriers)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NCard(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => BackendScope(
                  backend: b,
                  child: _CourierDetailDialog(courierId: c.id),
                ),
              ),
              child: Row(
                children: [
                  Avatar(c.name, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: NText.bodyStrong),
                        Text(
                          'NIM ${c.nim} · ★${c.rating.toStringAsFixed(1)}',
                          style: NText.caption,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    c.busy ? 'Mengantar' : (c.online ? 'Online' : 'Offline'),
                    color: c.busy
                        ? NColors.info
                        : (c.online ? NColors.success : NColors.ink400),
                  ),
                  const SizedBox(width: 8),
                  Text('${b.recap(c.id).count} pesanan', style: NText.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _OnProgressCard extends StatelessWidget {
  const _OnProgressCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final b = context.api;
    final o = order;
    final c = b.courier(o.courierId!);
    final late = b.isLate(o);
    final elapsed = o.acceptedAt == null
        ? Duration.zero
        : b.now.difference(o.acceptedAt!);
    return NCard(
      color: late ? const Color(0xFFFFF1F0) : NColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(c.name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: NText.title),
                    Text('${o.id} · ${o.status.label}', style: NText.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mmss(elapsed),
                    style: NText.number(
                      20,
                      color: late ? NColors.danger : NColors.ink,
                    ),
                  ),
                  Text(
                    late ? 'LEWAT SLA' : 'berjalan',
                    style: NText.caption.copyWith(
                      color: late ? NColors.danger : NColors.ink600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tujuan: ${o.destination.building.name.split('·').first.trim()} · ${o.destination.room}',
            style: NText.caption,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_rounded,
                  height: 44,
                  onPressed: () => openWhatsApp(
                    c.phone,
                    text:
                        'Halo ${c.name.split(' ').first}, status pesanan ${o.id} gimana?',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryButton(
                  label: 'Telepon',
                  icon: Icons.call_rounded,
                  height: 44,
                  onPressed: () => callPhone(c.phone),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryButton(
                  label: 'Batalkan',
                  danger: true,
                  height: 44,
                  onPressed: () => _cancel(context, o, c),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, Order o, Courier c) async {
    final b = context.api;
    String reason = 'Terlalu lama';
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: Text('Batalkan ${c.name.split(' ').first} dari ${o.id}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesanan akan dicarikan kurir lain. Jika kurir sudah membeli makanan, uangnya perlu diurus manual.',
                style: NText.body,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in const [
                    'Terlalu lama',
                    'Tidak bisa dihubungi',
                    'Atas permintaan kurir',
                  ])
                    ChoiceChip(
                      label: Text(r),
                      selected: reason == r,
                      onSelected: (_) => set(() => reason = r),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Kembali'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: NColors.danger),
              onPressed: () => Navigator.pop(d, true),
              child: Text('Batalkan ${c.name.split(' ').first}'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) b.adminCancelCourier(o.id, reason);
  }
}

/// A-06 — detail kurir persis format brief.
class _CourierDetailDialog extends StatelessWidget {
  const _CourierDetailDialog({required this.courierId});
  final String courierId;

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final c = b.courier(courierId);
    final r = b.recap(courierId);
    Widget row(String l, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: Text(l, style: bold ? NText.bodyStrong : NText.body),
          ),
          const Text(': ', style: NText.body),
          Expanded(
            child: Text(
              v,
              style: bold
                  ? NText.number(16, weight: FontWeight.w800)
                  : NText.number(14, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return AlertDialog(
      title: Row(
        children: [
          Avatar(c.name, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(c.name)),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('NIM', c.nim),
            row('Nama Kurir', c.name),
            row('Jumlah Pesanan Hari Ini', '${r.count}'),
            row('Jumlah Rupiah Pesanan', rupiah(r.orderTotal)),
            row('Nominal Ongkir yang Didapat', rupiah(r.shipping)),
            const Divider(),
            row(
              'Total Uang yang Harus Dikasih ke Kurir',
              rupiah(r.toPay),
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Rating ★${c.rating.toStringAsFixed(1)} (${c.reviews} ulasan)',
              style: NText.caption,
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => openWhatsApp(c.phone),
          icon: const Icon(Icons.chat_rounded),
          label: const Text('WhatsApp'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

// ============================ Tukar saldo (A-07) ============================

class WithdrawalsPage extends StatelessWidget {
  const WithdrawalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _title(
          'Permintaan tukar saldo',
          'Setujui, lalu tandai sudah dibayar setelah transfer.',
        ),
        if (b.withdrawals.isEmpty)
          const SizedBox(
            height: 260,
            child: EmptyState(
              icon: Icons.payments_outlined,
              title: 'Belum ada pengajuan',
              message: 'Pengajuan kurir akan muncul di sini.',
            ),
          ),
        for (final w in b.withdrawals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NCard(
              child: Row(
                children: [
                  Avatar(b.courier(w.courierId).name, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.courier(w.courierId).name, style: NText.title),
                        Text(
                          '${rupiah(w.amount)} → ${w.destination} · ${clock(w.at)}',
                          style: NText.caption,
                        ),
                      ],
                    ),
                  ),
                  switch (w.status) {
                    WithdrawalStatus.requested => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SecondaryButton(
                          label: 'Tolak',
                          danger: true,
                          height: 40,
                          onPressed: () => b.rejectWithdrawal(w.id),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: PrimaryButton(
                            label: 'Setujui',
                            onPressed: () => b.approveWithdrawal(w.id),
                          ),
                        ),
                      ],
                    ),
                    WithdrawalStatus.approved => SizedBox(
                      width: 190,
                      child: PrimaryButton(
                        label: 'Tandai Sudah Dibayar',
                        onPressed: () => b.markWithdrawalPaid(w.id),
                      ),
                    ),
                    WithdrawalStatus.paid => const StatusBadge(
                      'Sudah dibayar',
                      color: NColors.success,
                    ),
                    WithdrawalStatus.rejected => const StatusBadge(
                      'Ditolak',
                      color: NColors.danger,
                    ),
                  },
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ============================ Laporan (A-08) ============================

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _range = 0;
  double _progress = 0;
  bool _busy = false;
  bool _done = false;

  Future<void> _download(Backend b) async {
    setState(() {
      _busy = true;
      _done = false;
      _progress = 0;
    });
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    String? err;
    try {
      await downloadReport(b);
    } catch (e) {
      err = 'Gagal membuat file: $e';
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = err == null;
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(err ?? 'Laporan berhasil diunduh ✓'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final rows = [...b.paidToday]
      ..sort(
        (a, c) => (c.timestamps[OrderStatus.paid] ?? c.createdAt).compareTo(
          a.timestamps[OrderStatus.paid] ?? a.createdAt,
        ),
      );
    Widget sum(String l, String v) => Expanded(
      child: NCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l, style: NText.caption),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(v, style: NText.number(20, weight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _title('Laporan keuangan', 'Data demo mencakup hari ini saja.'),
        CategoryChips(
          items: const ['Hari ini', '7 hari', 'Bulan ini'],
          selected: _range,
          onSelected: (i) => setState(() => _range = i),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            sum('Transaksi', '${b.transactionsToday}'),
            const SizedBox(width: 10),
            sum('Nilai belanja', rupiah(b.gmvToday)),
            const SizedBox(width: 10),
            sum('Pendapatan (2%)', rupiah(b.feeToday)),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: Dur.base,
          child: PrimaryButton(
            label: _done ? 'Unduh Lagi (.xlsx)' : 'Unduh Excel (.xlsx)',
            icon: _done ? Icons.check_rounded : Icons.download_rounded,
            loading: _busy,
            onPressed: () => _download(b),
          ),
        ),
        if (_busy)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: NRadius.pillBr,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                color: NColors.brand,
                backgroundColor: NColors.line,
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text('Transaksi', style: NText.h2),
        const SizedBox(height: 8),
        NCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(width: 84, child: Text('ID', style: NText.caption)),
                  SizedBox(width: 56, child: Text('Jam', style: NText.caption)),
                  Expanded(child: Text('Kurir', style: NText.caption)),
                  SizedBox(
                    width: 90,
                    child: Text(
                      'Subtotal',
                      textAlign: TextAlign.right,
                      style: NText.caption,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Layanan',
                      textAlign: TextAlign.right,
                      style: NText.caption,
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              for (final o in rows.take(15))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(o.id, style: NText.bodyStrong),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          clock(o.timestamps[OrderStatus.paid] ?? o.createdAt),
                          style: NText.body,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          o.courierId == null
                              ? '-'
                              : b.courier(o.courierId!).name,
                          style: NText.body,
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          rupiah(o.subtotal),
                          textAlign: TextAlign.right,
                          style: NText.number(13),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          rupiah(o.fee),
                          textAlign: TextAlign.right,
                          style: NText.number(13),
                        ),
                      ),
                    ],
                  ),
                ),
              if (rows.length > 15)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${rows.length - 15} transaksi lain ada di file Excel',
                    style: NText.caption,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
