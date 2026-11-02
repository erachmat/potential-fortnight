enum AccountStatus { pending, active, rejected }

class Customer {
  Customer({required this.id, required this.name, required this.nim, required this.email, required this.phone, this.status = AccountStatus.pending, this.ktmAsset, this.rejectReason, this.submittedAt});

  final String id;
  String name;
  String nim;
  String email;
  String phone;
  AccountStatus status;
  String? ktmAsset;
  String? rejectReason;
  DateTime? submittedAt;
}

/// Perilaku kurir "bot" di demo.
enum BotBehavior { manual, ignore, reject, acceptAfter }

class Courier {
  Courier({required this.id, required this.name, required this.nim, required this.phone, required this.rating, required this.reviews, this.online = true, this.busy = false, this.behavior = BotBehavior.manual, this.acceptAfterSeconds = 5});

  final String id;
  final String name;
  final String nim;
  final String phone;
  double rating;
  int reviews;
  bool online;
  bool busy;
  BotBehavior behavior;
  int acceptAfterSeconds;

  void addRating(int stars) {
    rating = ((rating * reviews) + stars) / (reviews + 1);
    reviews += 1;
  }
}

class Canteen {
  const Canteen({required this.id, required this.name, required this.code, required this.hours, required this.mapX, required this.mapY});

  final String id;
  final String name;
  final String code;
  final String hours;
  final double mapX; // 0..1 posisi di peta kampus
  final double mapY;
}

enum ProductCategory { makanan, minuman, snack }

class Product {
  const Product({required this.id, required this.canteenId, required this.name, required this.price, required this.category, this.popular = false, this.emoji = '🍽️', this.available = true});

  final String id;
  final String canteenId;
  final String name;
  final int price;
  final ProductCategory category;
  final bool popular;
  final String emoji;
  final bool available;
}

class Building {
  const Building({required this.id, required this.name, required this.mapX, required this.mapY});

  final String id;
  final String name;
  final double mapX;
  final double mapY;
}

class CartLine {
  const CartLine({required this.product, required this.qty, this.note});

  final Product product;
  final int qty;
  final String? note;

  CartLine copyWith({int? qty, String? note}) => CartLine(product: product, qty: qty ?? this.qty, note: note ?? this.note);
}

class OrderLine {
  const OrderLine({required this.productId, required this.name, required this.canteenId, required this.price, required this.qty, this.note});

  final String productId;
  final String name;
  final String canteenId;
  final int price;
  final int qty;
  final String? note;

  int get total => price * qty;
}

class Destination {
  const Destination({required this.building, required this.room, required this.landmark});

  final Building building;
  final String room;
  final String landmark;

  /// "Lt. 3, R. 305 · Depan lab" (patokan kosong = '-' disembunyikan).
  String get label => landmark == '-' || landmark.isEmpty ? room : '$room · $landmark';
}

enum OrderStatus { awaitingPayment, paid, searchingCourier, noCourierFound, courierAssigned, purchasing, delivering, delivered, completed, expired }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.awaitingPayment => 'Menunggu bayar',
        OrderStatus.paid => 'Dibayar',
        OrderStatus.searchingCourier => 'Mencari kurir',
        OrderStatus.noCourierFound => 'Belum ada kurir',
        OrderStatus.courierAssigned => 'Kurir menuju kantin',
        OrderStatus.purchasing => 'Sedang dibelanjakan',
        OrderStatus.delivering => 'Diantar',
        OrderStatus.delivered => 'Sampai',
        OrderStatus.completed => 'Selesai',
        OrderStatus.expired => 'Kedaluwarsa',
      };

  bool get isActiveDelivery => this == OrderStatus.courierAssigned || this == OrderStatus.purchasing || this == OrderStatus.delivering;
  bool get isUndelivered => index < OrderStatus.delivered.index && this != OrderStatus.awaitingPayment;
}

class Order {
  Order({required this.id, required this.customerId, required this.customerName, required this.lines, required this.destination, required this.subtotal, required this.shipping, required this.fee, required this.createdAt, this.status = OrderStatus.awaitingPayment});

  final String id;
  final String customerId;
  final String customerName;
  final List<OrderLine> lines;
  final Destination destination;
  final int subtotal;
  final int shipping;
  final int fee;
  final DateTime createdAt;
  OrderStatus status;
  String? courierId;
  final Set<String> excludedCouriers = {};
  final Set<String> purchasedCanteens = {};
  final Map<OrderStatus, DateTime> timestamps = {};
  DateTime? acceptedAt;
  DateTime? deliveredAt;
  int? rating;

  int get total => subtotal + shipping + fee;
  int get courierEarning => subtotal + shipping;
  int get totalQty => lines.fold(0, (a, l) => a + l.qty);
  List<String> get canteenIds => lines.map((l) => l.canteenId).toSet().toList();
}

enum OfferResult { pending, accepted, rejected, expired }

class CourierOffer {
  CourierOffer({required this.orderId, required this.courierId, required this.createdAt, required this.expiresAt, this.result = OfferResult.pending});

  final String orderId;
  final String courierId;
  final DateTime createdAt;
  final DateTime expiresAt;
  OfferResult result;
}

enum LedgerType { earning, withdrawal }

class LedgerEntry {
  const LedgerEntry({required this.id, required this.courierId, required this.type, required this.amount, required this.at, required this.note, this.orderId});

  final String id;
  final String courierId;
  final LedgerType type;
  final int amount; // + masuk, - keluar
  final DateTime at;
  final String note;
  final String? orderId;
}

enum WithdrawalStatus { requested, approved, paid, rejected }

class Withdrawal {
  Withdrawal({required this.id, required this.courierId, required this.amount, required this.destination, required this.at, this.status = WithdrawalStatus.requested});

  final String id;
  final String courierId;
  final int amount;
  final String destination;
  final DateTime at;
  WithdrawalStatus status;

  bool get holdsBalance => status == WithdrawalStatus.requested || status == WithdrawalStatus.approved;
}

enum AppRole { customer, courier, admin }

class AppNotification {
  AppNotification({required this.id, required this.role, required this.title, required this.body, required this.at, this.read = false});

  final String id;
  final AppRole role;
  final String title;
  final String body;
  final DateTime at;
  bool read;
}

class ActivityItem {
  const ActivityItem(this.text, this.at);
  final String text;
  final DateTime at;
}
