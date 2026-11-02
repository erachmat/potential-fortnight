import 'models/models.dart';

/// State machine pesanan (PLAN §5.2). Transisi tak sah ditolak.
class OrderMachine {
  const OrderMachine._();

  static const _allowed = <OrderStatus, Set<OrderStatus>>{
    OrderStatus.awaitingPayment: {OrderStatus.paid, OrderStatus.expired},
    OrderStatus.paid: {OrderStatus.searchingCourier},
    OrderStatus.searchingCourier: {OrderStatus.courierAssigned, OrderStatus.noCourierFound},
    OrderStatus.noCourierFound: {OrderStatus.searchingCourier},
    OrderStatus.courierAssigned: {OrderStatus.purchasing, OrderStatus.searchingCourier},
    OrderStatus.purchasing: {OrderStatus.delivering, OrderStatus.searchingCourier},
    OrderStatus.delivering: {OrderStatus.delivered, OrderStatus.searchingCourier},
    OrderStatus.delivered: {OrderStatus.completed},
    OrderStatus.completed: {},
    OrderStatus.expired: {},
  };

  static bool canTransition(OrderStatus from, OrderStatus to) => _allowed[from]!.contains(to);

  static void transition(Order order, OrderStatus to, DateTime now) {
    if (!canTransition(order.status, to)) {
      throw StateError('Transisi tidak sah: ${order.status.name} -> ${to.name}');
    }
    order.status = to;
    order.timestamps[to] = now;
  }
}
