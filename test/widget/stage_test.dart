import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/core/design_system/theme.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/data/scope.dart';
import 'package:nitip/demo/stage/stage_screen.dart';
import 'package:nitip/domain/models/models.dart';

import 'test_utils.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Mode Panggung: 3 panel berbagi state + spotlight', (t) async {
    phoneSize(t, w: 1920, h: 1080);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const StageScreen())]);
    await t.pumpWidget(BackendScope(backend: b, child: MaterialApp.router(theme: buildTheme(), routerConfig: router)));
    await pumpFor(t, const Duration(seconds: 1));

    expect(find.text('Customer · Rina'), findsOneWidget);
    expect(find.text('Kurir · Sari'), findsOneWidget);
    expect(find.text('Admin · Nitip Console'), findsOneWidget);

    // login semua panel
    await t.tap(find.text('Pakai akun demo').first); // customer
    await t.pump();
    await t.tap(find.text('Masuk').first);
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.textContaining('Pakai akun demo (Sari)'));
    await t.pump();
    await t.tap(find.text('Masuk').first); // customer sudah masuk -> sisa: kurir, admin
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.text('Pakai akun demo')); // tinggal admin
    await pumpFor(t, const Duration(seconds: 2));
    expect(find.text('Ringkasan hari ini'), findsOneWidget);
    expect(find.textContaining('Halo, Sari'), findsOneWidget);

    // customer memesan -> kurir (Sari) dapat tawaran -> panel kurir menyala
    b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: 2);
    b.addToCart(b.products.firstWhere((p) => p.id == 'b1'), qty: 4);
    final o = b.placeOrder(Destination(building: b.buildings.first, room: 'Lt. 3', landmark: 'x'));
    b.simulatePayment(o.id);
    b.rejectOffer(o.id, 'budi');
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('PESANAN BARU'), findsOneWidget);
    expect(find.text('Pesanan baru'), findsWidgets); // caption spotlight/banner

    // admin dashboard ikut berubah (28 transaksi)
    b.acceptOffer(o.id, 'sari');
    await pumpFor(t, const Duration(seconds: 2));
    expect(find.text('28'), findsWidgets);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });
}
