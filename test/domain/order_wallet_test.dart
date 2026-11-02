import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/domain/models/models.dart';
import 'package:nitip/domain/order_state.dart';
import 'package:nitip/domain/wallet.dart';

Order order() => Order(
      id: 'NTP-1', customerId: 'u', customerName: 'U', lines: const [],
      destination: const Destination(building: Building(id: 'b', name: 'B', mapX: 0, mapY: 0), room: '1', landmark: 'x'),
      subtotal: 40000, shipping: 8000, fee: 800, createdAt: DateTime(2026),
    );

void main() {
  final now = DateTime(2026);

  test('jalur normal sampai completed', () {
    final o = order();
    for (final s in [OrderStatus.paid, OrderStatus.searchingCourier, OrderStatus.courierAssigned, OrderStatus.purchasing, OrderStatus.delivering, OrderStatus.delivered, OrderStatus.completed]) {
      OrderMachine.transition(o, s, now);
    }
    expect(o.status, OrderStatus.completed);
  });

  test('transisi tidak sah ditolak', () {
    final o = order();
    expect(() => OrderMachine.transition(o, OrderStatus.delivering, now), throwsStateError);
    OrderMachine.transition(o, OrderStatus.paid, now);
    expect(() => OrderMachine.transition(o, OrderStatus.completed, now), throwsStateError);
  });

  test('admin batal kurir -> kembali mencari; noCourierFound bisa coba lagi', () {
    expect(OrderMachine.canTransition(OrderStatus.delivering, OrderStatus.searchingCourier), isTrue);
    expect(OrderMachine.canTransition(OrderStatus.noCourierFound, OrderStatus.searchingCourier), isTrue);
    expect(OrderMachine.canTransition(OrderStatus.completed, OrderStatus.searchingCourier), isFalse);
  });

  test('pendapatan kurir = subtotal + ongkir; total termasuk fee', () {
    final o = order();
    expect(o.courierEarning, 48000);
    expect(o.total, 48800);
  });

  group('wallet', () {
    final ledger = [
      LedgerEntry(id: '1', courierId: 'k', type: LedgerType.earning, amount: 48000, at: DateTime(2026), note: ''),
      LedgerEntry(id: '2', courierId: 'k', type: LedgerType.earning, amount: 20000, at: DateTime(2026), note: ''),
      LedgerEntry(id: '3', courierId: 'x', type: LedgerType.earning, amount: 99999, at: DateTime(2026), note: ''),
    ];

    test('saldo = jumlah ledger milik kurir', () => expect(Wallet.balance(ledger, 'k'), 68000));

    test('pengajuan menahan saldo', () {
      final w = [Withdrawal(id: 'w', courierId: 'k', amount: 50000, destination: 'GoPay', at: DateTime(2026))];
      expect(Wallet.available(ledger, w, 'k'), 18000);
      w.first.status = WithdrawalStatus.rejected;
      expect(Wallet.available(ledger, w, 'k'), 68000);
    });

    test('validasi minimum & saldo', () {
      expect(Wallet.validateWithdrawal(5000, 68000), isNotNull);
      expect(Wallet.validateWithdrawal(70000, 68000), isNotNull);
      expect(Wallet.validateWithdrawal(68000, 68000), isNull);
    });
  });
}
