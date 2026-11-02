import 'models/models.dart';

/// Saldo kurir = Σ ledger (PLAN §6.3). Pengajuan menahan saldo.
class Wallet {
  const Wallet._();

  static const minWithdrawal = 10000;

  static int balance(Iterable<LedgerEntry> ledger, String courierId) =>
      ledger.where((e) => e.courierId == courierId).fold(0, (a, e) => a + e.amount);

  static int held(Iterable<Withdrawal> withdrawals, String courierId) =>
      withdrawals.where((w) => w.courierId == courierId && w.holdsBalance).fold(0, (a, w) => a + w.amount);

  static int available(Iterable<LedgerEntry> ledger, Iterable<Withdrawal> withdrawals, String courierId) =>
      balance(ledger, courierId) - held(withdrawals, courierId);

  /// null = valid, selain itu pesan error.
  static String? validateWithdrawal(int amount, int available) {
    if (amount < minWithdrawal) return 'Minimal tukar saldo Rp10.000';
    if (amount > available) return 'Saldo tersedia tidak cukup';
    return null;
  }
}
