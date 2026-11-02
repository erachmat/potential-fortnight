import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/domain/dispatch.dart';
import 'package:nitip/domain/models/models.dart';

Courier c(String id, double r, {bool online = true, bool busy = false}) =>
    Courier(id: id, name: id, nim: id, phone: '0', rating: r, reviews: 10, online: online, busy: busy);

Order order() => Order(
      id: 'NTP-1', customerId: 'u', customerName: 'U', lines: const [],
      destination: const Destination(building: Building(id: 'b', name: 'B', mapX: 0, mapY: 0), room: '1', landmark: 'x'),
      subtotal: 0, shipping: 0, fee: 0, createdAt: DateTime(2026),
    );

void main() {
  test('urut rating tertinggi', () {
    final list = Dispatch.candidates([c('a', 4.5), c('b', 4.9), c('d', 4.8)], order());
    expect(list.map((e) => e.id), ['b', 'd', 'a']);
  });

  test('seri deterministik dengan seed', () {
    final cs = [c('a', 4.8), c('b', 4.8), c('d', 4.8)];
    final x = Dispatch.candidates(cs, order()).map((e) => e.id).toList();
    final y = Dispatch.candidates(cs, order()).map((e) => e.id).toList();
    expect(x, y);
  });

  test('offline & sibuk tidak pernah ditawari', () {
    final list = Dispatch.candidates([c('a', 5, online: false), c('b', 5, busy: true), c('d', 4)], order());
    expect(list.map((e) => e.id), ['d']);
  });

  test('yang sudah menolak/timeout/dibatalkan dikecualikan', () {
    final o = order()..excludedCouriers.add('b');
    expect(Dispatch.pick([c('a', 4.5), c('b', 4.9)], o)!.id, 'a');
    o.excludedCouriers.add('a');
    expect(Dispatch.pick([c('a', 4.5), c('b', 4.9)], o), isNull);
  });
}
