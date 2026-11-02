import 'dart:math';

import '../../domain/models/models.dart';

class Seed {
  const Seed._();

  static const canteens = [
    Canteen(id: 'A', name: 'Kantin A · Gorengan Bu Sri', code: 'A', hours: '07.00–16.00', mapX: .22, mapY: .30),
    Canteen(id: 'B', name: 'Kantin B · Kopi Pojok', code: 'B', hours: '07.00–21.00', mapX: .50, mapY: .22),
    Canteen(id: 'C', name: 'Kantin C · Penyetan Mas Joko', code: 'C', hours: '10.00–20.00', mapX: .70, mapY: .45),
    Canteen(id: 'D', name: 'Kantin D · Es & Jus Segar', code: 'D', hours: '08.00–18.00', mapX: .40, mapY: .55),
  ];

  static const products = [
    Product(id: 'a1', canteenId: 'A', name: 'Pisang Goreng', price: 10000, category: ProductCategory.snack, popular: true, emoji: '🍌'),
    Product(id: 'a2', canteenId: 'A', name: 'Tahu Isi (3 pcs)', price: 6000, category: ProductCategory.snack, emoji: '🥟'),
    Product(id: 'a3', canteenId: 'A', name: 'Bakwan Jagung (3 pcs)', price: 6000, category: ProductCategory.snack, emoji: '🌽'),
    Product(id: 'a4', canteenId: 'A', name: 'Cireng Rujak', price: 8000, category: ProductCategory.snack, popular: true, emoji: '🍡'),
    Product(id: 'a5', canteenId: 'A', name: 'Risol Mayo', price: 5000, category: ProductCategory.snack, emoji: '🥐'),
    Product(id: 'b1', canteenId: 'B', name: 'Kopi Hitam', price: 5000, category: ProductCategory.minuman, popular: true, emoji: '☕'),
    Product(id: 'b2', canteenId: 'B', name: 'Es Kopi Susu Gula Aren', price: 12000, category: ProductCategory.minuman, popular: true, emoji: '🧋'),
    Product(id: 'b3', canteenId: 'B', name: 'Es Teh Manis', price: 4000, category: ProductCategory.minuman, emoji: '🥤'),
    Product(id: 'b4', canteenId: 'B', name: 'Teh Tarik', price: 8000, category: ProductCategory.minuman, emoji: '🍵'),
    Product(id: 'b5', canteenId: 'B', name: 'Matcha Latte', price: 15000, category: ProductCategory.minuman, emoji: '🍃'),
    Product(id: 'c1', canteenId: 'C', name: 'Nasi Ayam Penyet', price: 18000, category: ProductCategory.makanan, popular: true, emoji: '🍗'),
    Product(id: 'c2', canteenId: 'C', name: 'Nasi Lele Penyet', price: 16000, category: ProductCategory.makanan, emoji: '🐟'),
    Product(id: 'c3', canteenId: 'C', name: 'Tempe Penyet', price: 12000, category: ProductCategory.makanan, emoji: '🌶️'),
    Product(id: 'c4', canteenId: 'C', name: 'Nasi Telur Balado', price: 13000, category: ProductCategory.makanan, emoji: '🍳'),
    Product(id: 'd1', canteenId: 'D', name: 'Jus Alpukat', price: 12000, category: ProductCategory.minuman, popular: true, emoji: '🥑'),
    Product(id: 'd2', canteenId: 'D', name: 'Es Campur', price: 10000, category: ProductCategory.minuman, emoji: '🍧'),
    Product(id: 'd3', canteenId: 'D', name: 'Jus Jeruk', price: 9000, category: ProductCategory.minuman, emoji: '🍊'),
    Product(id: 'd4', canteenId: 'D', name: 'Es Kelapa Muda', price: 10000, category: ProductCategory.minuman, emoji: '🥥'),
  ];

  static const buildings = [
    Building(id: 'ga', name: 'Gedung A · Fakultas Teknik', mapX: .15, mapY: .62),
    Building(id: 'gb', name: 'Gedung B · Fakultas Ekonomi & Bisnis', mapX: .30, mapY: .80),
    Building(id: 'gc', name: 'Gedung C · FISIP', mapX: .55, mapY: .78),
    Building(id: 'lib', name: 'Perpustakaan Pusat', mapX: .78, mapY: .70),
    Building(id: 'rek', name: 'Gedung Rektorat', mapX: .82, mapY: .25),
    Building(id: 'msj', name: 'Masjid Kampus', mapX: .62, mapY: .12),
    Building(id: 'asr', name: 'Asrama Mahasiswa', mapX: .10, mapY: .15),
    Building(id: 'gor', name: 'GOR Kampus', mapX: .90, mapY: .50),
  ];

  static Customer rina() => Customer(id: 'rina', name: 'Rina Ayu Lestari', nim: '2023010145', email: 'rina.ayu@unc.ac.id', phone: '081234567890', status: AccountStatus.active, ktmAsset: 'rina');

  /// Pemilik pesanan seed yang telat (NTP-0398).
  static Customer rafi() => Customer(id: 'rafi', name: 'Rafi Hidayat', nim: '2022010077', email: 'rafi.h@unc.ac.id', phone: '081355577788', status: AccountStatus.active, ktmAsset: 'rafi');

  static List<Customer> pendingCustomers() => [
        Customer(id: 'dimas', name: 'Dimas Arya', nim: '2023010388', email: 'dimas.arya@unc.ac.id', phone: '081298765432', status: AccountStatus.pending, ktmAsset: 'dimas', submittedAt: null),
        Customer(id: 'putri', name: 'Putri Maharani', nim: '2023010412', email: 'putri.m@unc.ac.id', phone: '082111223344', status: AccountStatus.pending, ktmAsset: 'putri'),
      ];

  /// Nomor di KTM (beda 1 digit dari data input untuk Dimas -> contoh penolakan).
  static const ktmNim = {'rina': '2023010145', 'dimas': '2023010338', 'putri': '2023010412'};

  static List<Courier> couriers() => [
        Courier(id: 'budi', name: 'Budi Santoso', nim: '2021010087', phone: '081300000001', rating: 4.9, reviews: 212, behavior: BotBehavior.ignore),
        Courier(id: 'sari', name: 'Sari Wulandari', nim: '2022010211', phone: '081300000002', rating: 4.8, reviews: 187, behavior: BotBehavior.manual),
        Courier(id: 'andi', name: 'Andi Pratama', nim: '2021010132', phone: '081300000003', rating: 4.5, reviews: 96, busy: true),
        Courier(id: 'fajar', name: 'Fajar Nugroho', nim: '2022010098', phone: '081300000004', rating: 4.6, reviews: 64, online: false),
      ];

  /// Riwayat 27 pesanan selesai hari ini (07.00 .. sekarang), pola jam makan. Deterministik.
  static List<HistoryOrder> history(DateTime now) {
    final rng = Random(42);
    final day = DateTime(now.year, now.month, now.day);
    // jumlah per jam 07..13 (total 26): puncak 09.30–10.00 dan 12.00–13.00
    const perHour = {7: 1, 8: 3, 9: 6, 10: 5, 11: 3, 12: 7, 13: 1};
    final out = <HistoryOrder>[];
    var n = 0;
    perHour.forEach((h, count) {
      for (var i = 0; i < count; i++) {
        final minute = (h == 13 ? 2 + i * 7 : (i * 60 ~/ count) + rng.nextInt(8)).clamp(0, 59);
        final at = day.add(Duration(hours: h, minutes: minute));
        final lines = <OrderLine>[];
        final k = 1 + rng.nextInt(3);
        for (var j = 0; j < k; j++) {
          final p = products[rng.nextInt(products.length)];
          lines.add(OrderLine(productId: p.id, name: p.name, canteenId: p.canteenId, price: p.price, qty: 1 + rng.nextInt(3)));
        }
        const couriers = ['budi', 'sari', 'andi'];
        out.add(HistoryOrder(id: 'NTP-${(300 + n).toString().padLeft(4, '0')}', at: at, lines: lines, courierId: couriers[n % 3]));
        n++;
      }
    });
    return out;
  }
}

class HistoryOrder {
  const HistoryOrder({required this.id, required this.at, required this.lines, required this.courierId});

  final String id;
  final DateTime at;
  final List<OrderLine> lines;
  final String courierId;
}
