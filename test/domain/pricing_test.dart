import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/domain/models/models.dart';
import 'package:nitip/domain/pricing.dart';

Product p(String id, int price) => Product(id: id, canteenId: 'a', name: id, price: price, category: ProductCategory.snack);

void main() {
  tearDown(() => Pricing.feeIncludesShipping = false);

  final pisang = p('pisang', 10000);
  final kopi = p('kopi', 5000);

  test('kasus 1: 2 pisang + 3 kopi = 40.700', () {
    final b = Pricing.breakdown([CartLine(product: pisang, qty: 2), CartLine(product: kopi, qty: 3)]);
    expect(b.qty, 5);
    expect(b.subtotal, 35000);
    expect(b.shipping, 5000);
    expect(b.fee, 700);
    expect(b.total, 40700);
  });

  test('kasus 2: 6 item = 48.800', () {
    final b = Pricing.breakdown([CartLine(product: pisang, qty: 2), CartLine(product: kopi, qty: 4)]);
    expect(b.qty, 6);
    expect(b.subtotal, 40000);
    expect(b.shipping, 8000);
    expect(b.fee, 800);
    expect(b.total, 48800);
    expect(b.courierEarning, 48000);
  });

  test('tier ongkir pada batas', () {
    expect(Pricing.shipping(1), 5000);
    expect(Pricing.shipping(5), 5000);
    expect(Pricing.shipping(6), 8000);
    expect(Pricing.shipping(10), 8000);
    expect(Pricing.shipping(11), 12000);
    expect(Pricing.shipping(20), 12000);
  });

  test('qty di luar 1..20 ditolak', () {
    expect(() => Pricing.shipping(0), throwsRangeError);
    expect(() => Pricing.shipping(21), throwsRangeError);
    expect(Pricing.canAdd(20), isFalse);
    expect(Pricing.canAdd(19), isTrue);
  });

  test('fee dibulatkan setengah ke atas', () {
    expect(Pricing.fee(12345), 247); // 246,9
    expect(Pricing.fee(12325), 247); // 246,5 -> naik
    expect(Pricing.fee(12324), 246); // 246,48
    expect(Pricing.fee(0), 0);
  });

  test('feeBase = subtotal + ongkir (asumsi A1 alternatif)', () {
    Pricing.feeIncludesShipping = true;
    final b = Pricing.breakdown([CartLine(product: pisang, qty: 2), CartLine(product: kopi, qty: 3)]);
    expect(b.fee, 800);
    expect(b.total, 40800);
  });

  test('keranjang kosong -> semua nol', () {
    final b = Pricing.breakdown(const []);
    expect(b.total, 0);
  });
}
