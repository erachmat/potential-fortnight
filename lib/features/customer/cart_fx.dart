import 'package:flutter/material.dart';

import '../../core/design_system/tokens.dart';
import '../../core/motion/motion.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import 'customer_app.dart';

void toast(BuildContext context, String msg, {bool error = false}) {
  final m = ScaffoldMessenger.maybeOf(context);
  m?.hideCurrentSnackBar();
  m?.showSnackBar(SnackBar(
    content: Text(msg, style: NText.bodyStrong.copyWith(color: Colors.white)),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? NColors.danger : NColors.ink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
    duration: const Duration(milliseconds: 2200),
  ));
}

/// Tambah ke keranjang dengan efek terbang (M-14); batas 20 item ditolak (M-18).
/// [button] = context tombol yang ditekan (titik awal animasi).
bool addProductFx(BuildContext button, Product p) {
  final b = button.api;
  if (!b.addToCart(p)) {
    Feel.heavy();
    toast(button, 'Maksimal 20 item per pesanan. Kurangi dulu salah satu item ya.', error: true);
    return false;
  }
  Feel.light();
  flyToCart(button, CustomerHost.of(button).cartKey, p.emoji);
  return true;
}
