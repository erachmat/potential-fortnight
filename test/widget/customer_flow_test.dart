import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/app/app.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/domain/models/models.dart';
import 'package:nitip/features/customer/shell.dart';

import 'test_utils.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('customer: login -> belanja multi-kantin -> bayar -> kurir -> selesai', (t) async {
    phoneSize(t);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));

    await t.tap(find.text('Customer'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Masuk'), findsWidgets);

    await t.tap(find.text('Pakai akun demo'));
    await t.pump();
    await t.tap(find.widgetWithText(GestureDetector, 'Masuk').first);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.textContaining('jajan', findRichText: true), findsWidgets);

    // tambah 2 pisang goreng + 4 kopi lewat backend (UI tap sudah diuji di bawah)
    b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: 2);
    b.addToCart(b.products.firstWhere((p) => p.id == 'b1'), qty: 4);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('6'), findsWidgets); // badge FAB

    // buka keranjang
    await t.tap(find.text('6').first);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.textContaining('6–10 item'), findsWidgets);
    expect(find.textContaining('48.800'), findsWidgets);

    await t.tap(find.textContaining('Lanjut'));
    await pumpFor(t, const Duration(seconds: 1));
    // pilih Gedung A di peta
    await t.tap(find.text('Gedung A'));
    await t.pump();
    await t.enterText(find.byType(TextField).first, 'Lt. 3, R. 305');
    await t.pump();
    await t.tap(find.text('Pakai Alamat Ini'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.textContaining('Bayar dengan QRIS'), findsOneWidget);

    await t.tap(find.textContaining('Bayar dengan QRIS'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Simulasi Bayar'), findsOneWidget);

    await t.tap(find.text('Simulasi Bayar'));
    await pumpFor(t, const Duration(seconds: 3));
    final o = b.orders.first;
    expect(o.status, OrderStatus.searchingCourier);
    expect(find.textContaining('Menawarkan ke'), findsOneWidget);

    // kurir menerima -> lacak
    b.rejectOffer(o.id, 'budi');
    b.acceptOffer(o.id, 'sari');
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Sari Wulandari'), findsWidgets);
    b.markCanteenPurchased(o.id, 'A');
    b.markCanteenPurchased(o.id, 'B');
    await pumpFor(t, const Duration(seconds: 1));
    b.deliver(o.id);
    await pumpFor(t, const Duration(seconds: 2));
    expect(find.textContaining('menikmati', findRichText: true), findsWidgets);

    await t.tap(find.byIcon(Icons.star_outline_rounded).at(4));
    await pumpFor(t, const Duration(milliseconds: 500));
    await t.tap(find.text('Kirim Penilaian'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(o.rating, 5);
    expect(o.status, OrderStatus.completed);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('customer: daftar + KTM -> menunggu -> admin setujui -> aktif', (t) async {
    phoneSize(t);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));
    await t.tap(find.text('Customer'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.textContaining('Belum punya akun'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.text('Isi data contoh'));
    await t.pump();
    await t.tap(find.text('Lanjut'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.textContaining('Pakai KTM contoh'));
    await pumpFor(t, const Duration(seconds: 5));
    await t.tap(find.text('Kirim Pendaftaran'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Menunggu verifikasi'), findsOneWidget);
    expect(b.me.status, AccountStatus.pending);

    b.approveCustomer(b.me.id);
    await pumpFor(t, const Duration(seconds: 2));
    expect(find.text('Mulai Jajan'), findsOneWidget);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('customer: layar kantin menampilkan FAB keranjang (tanpa GlobalKey ganda)', (t) async {
    phoneSize(t);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));
    await t.tap(find.text('Customer'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.text('Pakai akun demo'));
    await t.pump();
    await t.tap(find.widgetWithText(GestureDetector, 'Masuk').first);
    await pumpFor(t, const Duration(seconds: 1));

    await t.tap(find.text('Gorengan Bu Sri'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Pisang Goreng'), findsOneWidget);
    await t.tap(find.byIcon(Icons.add_rounded).first); // tombol + pada Pisang Goreng
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.byIcon(Icons.add_rounded).first); // stepper + (qty 2)
    await pumpFor(t, const Duration(seconds: 1));
    expect(b.cartQty, 2);
    // FAB di layar kantin (paling atas) harus terlihat: scale 1, bukan 0 / hilang karena key ganda
    final fabScale = find.descendant(of: find.byType(CartFab), matching: find.byType(AnimatedScale)).first;
    expect(t.widget<AnimatedScale>(fabScale).scale, 1);
    expect(find.byType(CartFab), findsOneWidget); // yang terlihat = milik layar kantin (beranda offstage)
    expect(t.takeException(), isNull);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });
}
