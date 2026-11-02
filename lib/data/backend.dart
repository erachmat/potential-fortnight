import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../domain/dispatch.dart';
import '../domain/models/models.dart';
import '../domain/order_state.dart';
import '../domain/pricing.dart';
import '../domain/wallet.dart';
import 'seed/seed.dart';

/// Backend palsu in-memory. Seluruh app (3 peran) membaca state yang sama,
/// sehingga aksi di satu peran langsung terlihat di peran lain.
/// Nanti diganti implementasi API sungguhan dengan method publik yang sama.
class Backend extends ChangeNotifier {
  Backend({Clock? clock, bool autoTick = true}) : clock = clock ?? SimClock(_simStart()) {
    _seed();
    if (autoTick) _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
  }

  final Clock clock;
  Timer? _timer;

  static DateTime _simStart() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, 13, 20);
  }

  // ---- konfigurasi demo ----
  Duration offerTimeout = const Duration(seconds: 15);
  String? autoPilotCourierId;
  int _orderSeq = 412;
  int _idSeq = 0;
  Duration slaLimit = const Duration(minutes: 30);

  // ---- data ----
  late List<Customer> customers;
  late List<Courier> couriers;
  late List<Order> orders;
  late List<CourierOffer> offers;
  late List<LedgerEntry> ledger;
  late List<Withdrawal> withdrawals;
  late List<AppNotification> notifications;
  late List<ActivityItem> activity;
  final List<CartLine> cart = [];
  Destination? lastDestination;

  final canteens = Seed.canteens;
  final products = Seed.products;
  final buildings = Seed.buildings;

  String customerId = 'rina';
  String courierId = 'sari';

  /// Akun customer yang sedang dipakai di UI customer (bisa akun baru dari pendaftaran).
  Customer get me => customers.firstWhere((c) => c.id == customerId);
  Courier courier(String id) => couriers.firstWhere((c) => c.id == id);
  Courier get meCourier => courier(courierId);
  Canteen canteen(String id) => canteens.firstWhere((c) => c.id == id);
  Order? orderById(String id) => orders.where((o) => o.id == id).firstOrNull;

  DateTime get now => clock.now();

  // ================= seed / reset =================
  void _seed() {
    final t = now;
    customers = [Seed.rina(), ...Seed.pendingCustomers().map((c) => c..submittedAt = t.subtract(const Duration(minutes: 25)))];
    couriers = Seed.couriers();
    orders = [];
    offers = [];
    ledger = [];
    withdrawals = [];
    notifications = [];
    activity = [];
    cart.clear();
    lastDestination = null;
    customerId = 'rina';
    courierId = 'sari';
    autoPilotCourierId = null;
    offerTimeout = const Duration(seconds: 15);
    _orderSeq = 412;

    for (final h in Seed.history(t)) {
      final sub = h.lines.fold<int>(0, (a, l) => a + l.total);
      final qty = h.lines.fold<int>(0, (a, l) => a + l.qty).clamp(1, Pricing.maxQty);
      final ship = Pricing.shipping(qty);
      final o = Order(
        id: h.id, customerId: 'rina', customerName: 'Mahasiswa', lines: h.lines,
        destination: Destination(building: buildings[h.at.minute % buildings.length], room: 'Lt. 2', landmark: '-'),
        subtotal: sub, shipping: ship, fee: Pricing.fee(sub), createdAt: h.at, status: OrderStatus.completed,
      )
        ..courierId = h.courierId
        ..acceptedAt = h.at.add(const Duration(minutes: 1))
        ..deliveredAt = h.at.add(const Duration(minutes: 16))
        ..rating = 5;
      orders.add(o);
      ledger.add(LedgerEntry(id: _id('l'), courierId: h.courierId, type: LedgerType.earning, amount: o.courierEarning, at: o.deliveredAt!, note: 'Pesanan ${o.id}', orderId: o.id));
    }
    // saldo awal Sari + 1 penarikan lama
    ledger.add(LedgerEntry(id: _id('l'), courierId: 'sari', type: LedgerType.earning, amount: 126500 - _balanceOf('sari'), at: t.subtract(const Duration(days: 1)), note: 'Saldo awal'));
    // order telat 45 menit milik Andi (masih diantar)
    final late = _makeOrder(
      id: 'NTP-0398',
      lines: const [OrderLine(productId: 'c1', name: 'Nasi Ayam Penyet', canteenId: 'C', price: 18000, qty: 2)],
      dest: Destination(building: buildings[3], room: 'Lt. 1, Ruang Baca', landmark: 'Dekat mesin fotokopi'),
      at: t.subtract(const Duration(minutes: 50)),
    )
      ..status = OrderStatus.delivering
      ..courierId = 'andi'
      ..acceptedAt = t.subtract(const Duration(minutes: 45));
    late.purchasedCanteens.add('C');
    orders.add(late);
    _log('Sistem siap. Data demo dimuat.');
    notifyListeners();
  }

  int _balanceOf(String id) => Wallet.balance(ledger, id);
  String _id(String p) => '$p${_idSeq++}';

  void reset() {
    if (clock is SimClock) (clock as SimClock).reset(_simStart());
    _seed();
  }

  // ================= util =================
  void _log(String text) {
    activity.insert(0, ActivityItem(text, now));
    if (activity.length > 40) activity.removeLast();
  }

  void _notify(AppRole role, String title, String body) {
    notifications.insert(0, AppNotification(id: _id('n'), role: role, title: title, body: body, at: now));
    lastNotification = notifications.first;
  }

  /// Notifikasi terbaru (dipakai jembatan banner/notifikasi sistem).
  AppNotification? lastNotification;

  Order _makeOrder({required String id, required List<OrderLine> lines, required Destination dest, required DateTime at}) {
    final cl = lines.map((l) => CartLine(product: Seed.products.firstWhere((p) => p.id == l.productId), qty: l.qty));
    final b = Pricing.breakdown(cl);
    return Order(id: id, customerId: 'rina', customerName: 'Rina Ayu Lestari', lines: lines, destination: dest, subtotal: b.subtotal, shipping: b.shipping, fee: b.fee, createdAt: at);
  }

  // ================= auth / pendaftaran =================
  Customer register({required String name, required String nim, required String email, required String phone, String? ktmAsset}) {
    final c = Customer(id: 'u${_idSeq++}', name: name, nim: nim, email: email, phone: phone, ktmAsset: ktmAsset ?? 'rina', submittedAt: now);
    customers.insert(0, c);
    customerId = c.id;
    _log('Pendaftaran baru: $name ($nim)');
    _notify(AppRole.admin, 'Pendaftaran baru', '$name menunggu validasi KTM');
    notifyListeners();
    return c;
  }

  List<Customer> get pendingCustomers => customers.where((c) => c.status == AccountStatus.pending).toList();

  void approveCustomer(String id) {
    final c = customers.firstWhere((c) => c.id == id);
    c.status = AccountStatus.active;
    c.rejectReason = null;
    _log('Admin menyetujui akun ${c.name}');
    if (c.id == customerId) _notify(AppRole.customer, 'Akun kamu aktif', 'Halo ${c.name.split(' ').first}, akun Nitip kamu sudah aktif. Selamat jajan!');
    notifyListeners();
  }

  void rejectCustomer(String id, String reason) {
    final c = customers.firstWhere((c) => c.id == id);
    c.status = AccountStatus.rejected;
    c.rejectReason = reason;
    _log('Admin menolak akun ${c.name}: $reason');
    notifyListeners();
  }

  void resubmitCustomer(String id) {
    final c = customers.firstWhere((c) => c.id == id);
    c.status = AccountStatus.pending;
    c.rejectReason = null;
    notifyListeners();
  }

  // ================= keranjang =================
  int get cartQty => Pricing.totalQty(cart);
  PriceBreakdown get cartPrice => Pricing.breakdown(cart);
  int qtyOf(String productId) => cart.where((l) => l.product.id == productId).fold(0, (a, l) => a + l.qty);

  /// false jika melebihi batas 20 item.
  bool addToCart(Product p, {int qty = 1, String? note}) {
    if (!Pricing.canAdd(cartQty, qty)) return false;
    final i = cart.indexWhere((l) => l.product.id == p.id);
    if (i >= 0) {
      cart[i] = cart[i].copyWith(qty: cart[i].qty + qty, note: note);
    } else {
      cart.add(CartLine(product: p, qty: qty, note: note));
    }
    notifyListeners();
    return true;
  }

  void decFromCart(String productId) {
    final i = cart.indexWhere((l) => l.product.id == productId);
    if (i < 0) return;
    if (cart[i].qty <= 1) {
      cart.removeAt(i);
    } else {
      cart[i] = cart[i].copyWith(qty: cart[i].qty - 1);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    cart.removeWhere((l) => l.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ================= pesanan customer =================
  Order placeOrder(Destination dest) {
    assert(cart.isNotEmpty);
    final b = cartPrice;
    final lines = cart.map((l) => OrderLine(productId: l.product.id, name: l.product.name, canteenId: l.product.canteenId, price: l.product.price, qty: l.qty, note: l.note)).toList();
    final o = Order(id: 'NTP-${(_orderSeq++).toString().padLeft(4, '0')}', customerId: customerId, customerName: me.name, lines: lines, destination: dest, subtotal: b.subtotal, shipping: b.shipping, fee: b.fee, createdAt: now);
    o.timestamps[OrderStatus.awaitingPayment] = now;
    orders.insert(0, o);
    lastDestination = dest;
    cart.clear();
    notifyListeners();
    return o;
  }

  void cancelUnpaid(String orderId) {
    final o = orderById(orderId)!;
    if (o.status == OrderStatus.awaitingPayment) OrderMachine.transition(o, OrderStatus.expired, now);
    notifyListeners();
  }

  /// Simulasi pembayaran QRIS berhasil (webhook palsu).
  void simulatePayment(String orderId) {
    final o = orderById(orderId)!;
    OrderMachine.transition(o, OrderStatus.paid, now);
    _log('${o.customerName} membayar ${o.id}');
    _notify(AppRole.admin, 'Pesanan baru', '${o.id} dibayar.');
    OrderMachine.transition(o, OrderStatus.searchingCourier, now);
    _offerNext(o);
    notifyListeners();
  }

  void retrySearch(String orderId) {
    final o = orderById(orderId)!;
    if (o.status != OrderStatus.noCourierFound) return;
    o.excludedCouriers.clear();
    OrderMachine.transition(o, OrderStatus.searchingCourier, now);
    _offerNext(o);
    notifyListeners();
  }

  void confirmReceived(String orderId, {int? stars}) {
    final o = orderById(orderId)!;
    if (o.status == OrderStatus.delivered) OrderMachine.transition(o, OrderStatus.completed, now);
    if (stars != null && o.courierId != null) {
      o.rating = stars;
      courier(o.courierId!).addRating(stars);
    }
    notifyListeners();
  }

  Order? get activeCustomerOrder => orders.where((o) => o.customerId == customerId && o.status != OrderStatus.completed && o.status != OrderStatus.expired).firstOrNull;

  // ================= dispatch =================
  CourierOffer? offerFor(String orderId) => offers.where((o) => o.orderId == orderId && o.result == OfferResult.pending).firstOrNull;
  CourierOffer? pendingOfferForCourier(String cid) => offers.where((o) => o.courierId == cid && o.result == OfferResult.pending).firstOrNull;

  void _offerNext(Order o) {
    final next = Dispatch.pick(couriers, o);
    if (next == null) {
      OrderMachine.transition(o, OrderStatus.noCourierFound, now);
      _log('Tidak ada kurir tersedia untuk ${o.id}');
      return;
    }
    o.excludedCouriers.add(next.id);
    final t = now;
    offers.add(CourierOffer(orderId: o.id, courierId: next.id, createdAt: t, expiresAt: t.add(offerTimeout)));
    _log('${o.id} ditawarkan ke ${next.name} ★${next.rating.toStringAsFixed(1)}');
    _notify(AppRole.courier, 'Pesanan baru', '${o.id} · Kamu terima ${_rp(o.courierEarning)}');
  }

  String _rp(int v) => 'Rp${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  void acceptOffer(String orderId, String cid) {
    final of = offers.firstWhere((x) => x.orderId == orderId && x.courierId == cid && x.result == OfferResult.pending);
    final o = orderById(orderId)!;
    of.result = OfferResult.accepted;
    final c = courier(cid);
    c.busy = true;
    o.courierId = cid;
    o.acceptedAt = now;
    OrderMachine.transition(o, OrderStatus.courierAssigned, now);
    _log('${c.name} menerima ${o.id}');
    _notify(AppRole.customer, 'Kurir ditemukan', '${c.name} menuju kantin.');
    notifyListeners();
  }

  void rejectOffer(String orderId, String cid) {
    final of = offers.firstWhere((x) => x.orderId == orderId && x.courierId == cid && x.result == OfferResult.pending);
    of.result = OfferResult.rejected;
    _log('${courier(cid).name} menolak $orderId');
    _offerNext(orderById(orderId)!);
    notifyListeners();
  }

  // ================= progres kurir =================
  void startPurchasing(String orderId) {
    final o = orderById(orderId)!;
    if (o.status == OrderStatus.courierAssigned) OrderMachine.transition(o, OrderStatus.purchasing, now);
    notifyListeners();
  }

  /// Centang satu kantin selesai dibeli; jika semua selesai -> delivering.
  void markCanteenPurchased(String orderId, String canteenId) {
    final o = orderById(orderId)!;
    if (o.status == OrderStatus.courierAssigned) OrderMachine.transition(o, OrderStatus.purchasing, now);
    o.purchasedCanteens.add(canteenId);
    if (o.purchasedCanteens.containsAll(o.canteenIds) && o.status == OrderStatus.purchasing) {
      OrderMachine.transition(o, OrderStatus.delivering, now);
      _notify(AppRole.customer, 'Pesananmu diantar', 'Kurir sudah membeli semua pesanan dan menuju lokasimu.');
    }
    notifyListeners();
  }

  void deliver(String orderId) {
    final o = orderById(orderId)!;
    OrderMachine.transition(o, OrderStatus.delivered, now);
    o.deliveredAt = now;
    final cid = o.courierId!;
    courier(cid).busy = false;
    ledger.add(LedgerEntry(id: _id('l'), courierId: cid, type: LedgerType.earning, amount: o.courierEarning, at: now, note: 'Pesanan ${o.id}', orderId: o.id));
    _log('${courier(cid).name} menyelesaikan ${o.id}');
    _notify(AppRole.customer, 'Pesanan sampai', 'Selamat menikmati!');
    notifyListeners();
  }

  void setCourierOnline(String cid, bool v) {
    courier(cid).online = v;
    notifyListeners();
  }

  // ================= admin =================
  bool isLate(Order o) => o.status.isActiveDelivery && o.acceptedAt != null && now.difference(o.acceptedAt!) > slaLimit;

  void adminCancelCourier(String orderId, String reason) {
    final o = orderById(orderId)!;
    final cid = o.courierId;
    if (cid == null) return;
    courier(cid).busy = false;
    o.excludedCouriers.add(cid);
    o.courierId = null;
    o.acceptedAt = null;
    o.purchasedCanteens.clear();
    OrderMachine.transition(o, OrderStatus.searchingCourier, now);
    _log('Admin membatalkan ${courier(cid).name} dari $orderId ($reason)');
    _notify(AppRole.courier, 'Pesanan dibatalkan', '$orderId dibatalkan admin.');
    _offerNext(o);
    notifyListeners();
  }

  // ================= saldo =================
  int balanceOf(String cid) => Wallet.balance(ledger, cid);
  int availableOf(String cid) => Wallet.available(ledger, withdrawals, cid);
  int heldOf(String cid) => Wallet.held(withdrawals, cid);

  String? requestWithdrawal(String cid, int amount, String destination) {
    final err = Wallet.validateWithdrawal(amount, availableOf(cid));
    if (err != null) return err;
    withdrawals.insert(0, Withdrawal(id: _id('w'), courierId: cid, amount: amount, destination: destination, at: now));
    _log('${courier(cid).name} mengajukan tukar saldo ${_rp(amount)}');
    _notify(AppRole.admin, 'Tukar saldo', '${courier(cid).name} mengajukan ${_rp(amount)}');
    notifyListeners();
    return null;
  }

  void approveWithdrawal(String id) {
    withdrawals.firstWhere((w) => w.id == id).status = WithdrawalStatus.approved;
    notifyListeners();
  }

  void rejectWithdrawal(String id) {
    withdrawals.firstWhere((w) => w.id == id).status = WithdrawalStatus.rejected;
    notifyListeners();
  }

  void markWithdrawalPaid(String id) {
    final w = withdrawals.firstWhere((w) => w.id == id);
    w.status = WithdrawalStatus.paid;
    ledger.add(LedgerEntry(id: _id('l'), courierId: w.courierId, type: LedgerType.withdrawal, amount: -w.amount, at: now, note: 'Tukar saldo ke ${w.destination}'));
    notifyListeners();
  }

  // ================= statistik admin =================
  bool _today(DateTime t) => t.year == now.year && t.month == now.month && t.day == now.day;

  List<Order> get paidToday => orders.where((o) => o.status.index >= OrderStatus.paid.index && o.status != OrderStatus.expired && _today(o.timestamps[OrderStatus.paid] ?? o.createdAt)).toList();
  int get transactionsToday => paidToday.length;
  int get feeToday => paidToday.fold(0, (a, o) => a + o.fee);
  int get gmvToday => paidToday.fold(0, (a, o) => a + o.subtotal);
  int get shippingToday => paidToday.fold(0, (a, o) => a + o.shipping);
  int get undeliveredCount => orders.where((o) => o.status.isUndelivered).length;
  int get activeCouriers => couriers.where((c) => c.online).length;

  /// Rekap kurir hari ini sesuai format brief.
  CourierRecap recap(String cid) {
    final list = orders.where((o) => o.courierId == cid && o.status.index >= OrderStatus.delivered.index && o.status != OrderStatus.expired && _today(o.deliveredAt ?? o.createdAt)).toList();
    final nominal = list.fold<int>(0, (a, o) => a + o.subtotal);
    final ship = list.fold<int>(0, (a, o) => a + o.shipping);
    return CourierRecap(count: list.length, orderTotal: nominal, shipping: ship);
  }

  /// transaksi per jam (07..21) untuk grafik.
  Map<int, int> get perHour {
    final m = {for (var h = 7; h <= 21; h++) h: 0};
    for (final o in paidToday) {
      final h = (o.timestamps[OrderStatus.paid] ?? o.createdAt).hour;
      if (m.containsKey(h)) m[h] = m[h]! + 1;
    }
    return m;
  }

  // ================= simulasi (dipanggil tiap 250 ms) =================
  final Map<String, DateTime> _autoPilotStep = {};

  void tick() {
    var changed = false;
    final t = now;

    for (final of in offers.where((o) => o.result == OfferResult.pending).toList()) {
      final o = orderById(of.orderId)!;
      final c = courier(of.courierId);
      if (!t.isBefore(of.expiresAt)) {
        of.result = OfferResult.expired;
        _log('Tawaran ${o.id} ke ${c.name} habis waktu');
        _offerNext(o);
        changed = true;
        continue;
      }
      final waited = t.difference(of.createdAt);
      final auto = autoPilotCourierId == c.id;
      if (auto || c.behavior == BotBehavior.acceptAfter && waited.inSeconds >= c.acceptAfterSeconds) {
        if (waited.inSeconds >= (auto ? 3 : c.acceptAfterSeconds)) {
          acceptOffer(o.id, c.id);
          changed = true;
          continue;
        }
      }
      if (c.behavior == BotBehavior.reject && waited.inSeconds >= 3) {
        rejectOffer(o.id, c.id);
        changed = true;
      }
    }

    // auto-pilot: kurir menyelesaikan pesanan bertahap
    if (autoPilotCourierId != null) {
      for (final o in orders.where((o) => o.courierId == autoPilotCourierId && o.status.isActiveDelivery).toList()) {
        final last = _autoPilotStep[o.id] ?? o.acceptedAt ?? t;
        if (t.difference(last).inSeconds < 4) continue;
        _autoPilotStep[o.id] = t;
        if (o.status == OrderStatus.courierAssigned) {
          startPurchasing(o.id);
        } else if (o.status == OrderStatus.purchasing) {
          final next = o.canteenIds.firstWhere((c) => !o.purchasedCanteens.contains(c));
          markCanteenPurchased(o.id, next);
        } else if (o.status == OrderStatus.delivering) {
          deliver(o.id);
        }
        changed = true;
      }
    }

    if (changed) notifyListeners();
    // timer UI (countdown, durasi) menggambar ulang sendiri lewat Ticker.
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class CourierRecap {
  const CourierRecap({required this.count, required this.orderTotal, required this.shipping});

  final int count;
  final int orderTotal;
  final int shipping;
  int get toPay => orderTotal + shipping;
}
