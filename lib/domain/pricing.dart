import 'models/models.dart';

/// Aturan harga persis brief (PLAN §6.1). Semua uang int rupiah.
class Pricing {
  const Pricing._();

  static const maxQty = 20;
  static const feePercent = 2;

  /// Asumsi A1: fee dihitung dari subtotal. Ubah ke true untuk subtotal + ongkir.
  static bool feeIncludesShipping = false;

  static int totalQty(Iterable<CartLine> lines) => lines.fold(0, (a, l) => a + l.qty);

  static int subtotal(Iterable<CartLine> lines) => lines.fold(0, (a, l) => a + l.product.price * l.qty);

  /// 1–5 -> 5.000; 6–10 -> 8.000; 11–20 -> 12.000. Di luar 1..20 melempar.
  static int shipping(int qty) {
    if (qty < 1 || qty > maxQty) throw RangeError.range(qty, 1, maxQty, 'qty');
    if (qty <= 5) return 5000;
    if (qty <= 10) return 8000;
    return 12000;
  }

  static String shippingTierLabel(int qty) {
    if (qty <= 5) return '1–5 item';
    if (qty <= 10) return '6–10 item';
    return '11–20 item';
  }

  /// 2% dibulatkan setengah ke atas, murni integer (tanpa floating point).
  static int fee(int base) => (base * feePercent + 50) ~/ 100;

  static bool canAdd(int currentQty, [int add = 1]) => currentQty + add <= maxQty;

  static PriceBreakdown breakdown(Iterable<CartLine> lines) {
    final qty = totalQty(lines);
    final sub = subtotal(lines);
    if (qty == 0) return const PriceBreakdown(qty: 0, subtotal: 0, shipping: 0, fee: 0);
    final ship = shipping(qty);
    final f = fee(feeIncludesShipping ? sub + ship : sub);
    return PriceBreakdown(qty: qty, subtotal: sub, shipping: ship, fee: f);
  }
}

class PriceBreakdown {
  const PriceBreakdown({required this.qty, required this.subtotal, required this.shipping, required this.fee});

  final int qty;
  final int subtotal;
  final int shipping;
  final int fee;

  int get total => subtotal + shipping + fee;
  int get courierEarning => subtotal + shipping;
}
