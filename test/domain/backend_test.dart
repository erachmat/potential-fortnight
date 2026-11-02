import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/domain/models/models.dart';

void main() {
  late ManualClock clock;
  late Backend b;

  setUp(() {
    clock = ManualClock(DateTime(2026, 11, 2, 13, 20));
    b = Backend(clock: clock, autoTick: false);
  });

  Order newOrder({int pisang = 2, int kopi = 4}) {
    b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: pisang);
    b.addToCart(b.products.firstWhere((p) => p.id == 'b1'), qty: kopi);
    return b.placeOrder(Destination(building: b.buildings.first, room: 'Lt. 3', landmark: 'x'));
  }

  void pass(int s) {
    clock.advance(Duration(seconds: s));
    b.tick();
  }

  test('seed: 27 transaksi hari ini (26 selesai + 1 sedang jalan)', () {
    expect(b.transactionsToday, 27);
    expect(b.undeliveredCount, 1);
    expect(b.isLate(b.orderById('NTP-0398')!), isTrue);
    expect(b.balanceOf('sari'), 126500);
  });

  test('keranjang menolak > 20 item', () {
    expect(b.addToCart(b.products.first, qty: 20), isTrue);
    expect(b.addToCart(b.products.first), isFalse);
    expect(b.cartQty, 20);
  });

  test('dispatch: Budi (rating tertinggi, abaikan) timeout -> pindah ke Sari', () {
    final o = newOrder();
    expect(o.total, 48800);
    b.simulatePayment(o.id);
    expect(b.offerFor(o.id)!.courierId, 'budi');
    pass(14);
    expect(b.offerFor(o.id)!.courierId, 'budi');
    pass(2);
    expect(b.offerFor(o.id)!.courierId, 'sari');
    b.acceptOffer(o.id, 'sari');
    expect(o.status, OrderStatus.courierAssigned);
    expect(b.courier('sari').busy, isTrue);
  });

  test('semua kurir habis -> noCourierFound; coba lagi mengulang', () {
    final o = newOrder();
    b.simulatePayment(o.id);
    pass(16);
    pass(16);
    expect(o.status, OrderStatus.noCourierFound);
    b.retrySearch(o.id);
    expect(o.status, OrderStatus.searchingCourier);
    expect(b.offerFor(o.id)!.courierId, 'budi');
  });

  test('tolak -> langsung ke kurir berikutnya', () {
    final o = newOrder();
    b.simulatePayment(o.id);
    b.rejectOffer(o.id, 'budi');
    expect(b.offerFor(o.id)!.courierId, 'sari');
  });

  test('alur penuh: saldo kurir +48.000, fee 800 jadi pendapatan platform', () {
    final fee0 = b.feeToday;
    final o = newOrder();
    b.simulatePayment(o.id);
    b.rejectOffer(o.id, 'budi');
    b.acceptOffer(o.id, 'sari');
    b.markCanteenPurchased(o.id, 'A');
    expect(o.status, OrderStatus.purchasing);
    b.markCanteenPurchased(o.id, 'B');
    expect(o.status, OrderStatus.delivering);
    final before = b.balanceOf('sari');
    b.deliver(o.id);
    expect(b.balanceOf('sari') - before, 48000);
    expect(b.feeToday - fee0, 800);
    expect(b.transactionsToday, 28);
    expect(b.courier('sari').busy, isFalse);
    b.confirmReceived(o.id, stars: 5);
    expect(o.status, OrderStatus.completed);
  });

  test('admin batal kurir: order kembali mencari, kurir lama dikecualikan', () {
    final late = b.orderById('NTP-0398')!;
    b.adminCancelCourier(late.id, 'terlalu lama');
    expect(b.courier('andi').busy, isFalse);
    expect(late.status, OrderStatus.searchingCourier);
    expect(b.offerFor(late.id)!.courierId, isNot('andi'));
  });

  test('tukar saldo menahan lalu mencairkan', () {
    expect(b.requestWithdrawal('sari', 5000, 'GoPay'), isNotNull);
    expect(b.requestWithdrawal('sari', 100000, 'GoPay'), isNull);
    expect(b.availableOf('sari'), 26500);
    final w = b.withdrawals.first;
    b.approveWithdrawal(w.id);
    b.markWithdrawalPaid(w.id);
    expect(b.balanceOf('sari'), 26500);
    expect(b.heldOf('sari'), 0);
  });

  test('rekap kurir sesuai format brief', () {
    final r = b.recap('sari');
    expect(r.toPay, r.orderTotal + r.shipping);
    expect(r.count, greaterThan(0));
  });

  test('reset mengembalikan seed', () {
    newOrder();
    b.reset();
    expect(b.orders.length, 27);
    expect(b.cart, isEmpty);
  });
}
