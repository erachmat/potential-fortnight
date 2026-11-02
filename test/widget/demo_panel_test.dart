import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/app/app.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/domain/models/models.dart';

import 'test_utils.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<Backend> boot(WidgetTester t) async {
    phoneSize(t);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));
    return b;
  }

  testWidgets('Panel Demo: tekan lama badge -> picu order masuk', (t) async {
    final b = await boot(t);
    await t.longPress(find.text('MODE DEMO'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Panel Demo'), findsOneWidget);

    final before = b.orders.length;
    await t.ensureVisible(find.text('Picu order masuk'));
    await t.pump();
    await t.tap(find.text('Picu order masuk'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(b.orders.length, before + 1);
    expect(b.orders.first.status, OrderStatus.searchingCourier);
    expect(b.offerFor(b.orders.first.id), isNotNull);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('Panel Demo: reset mengembalikan data seed', (t) async {
    final b = await boot(t);
    b.addToCart(b.products.first);
    b.placeOrder(Destination(building: b.buildings.first, room: 'x', landmark: 'y'));
    expect(b.orders.length, 28);

    await t.longPress(find.text('MODE DEMO'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.text('Reset semua data'));
    await pumpFor(t, const Duration(milliseconds: 500));
    await t.tap(find.text('Reset'));
    await pumpFor(t, const Duration(milliseconds: 500));
    expect(b.orders.length, 27);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('reduce motion: alur utama tetap jalan tanpa error', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final b = await boot(t);
    await t.tap(find.text('Customer'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.text('Pakai akun demo'));
    await t.pump();
    await t.tap(find.widgetWithText(GestureDetector, 'Masuk').first);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.textContaining('jajan', findRichText: true), findsWidgets);

    // bayar -> layar sukses (centang digambar langsung penuh) -> radar
    b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: 2);
    final o = b.placeOrder(Destination(building: b.buildings.first, room: 'Lt. 3', landmark: 'x'));
    await t.tap(find.text('Lihat kantin').evaluate().isEmpty ? find.byType(Scaffold).first : find.text('Lihat kantin'), warnIfMissed: false);
    b.simulatePayment(o.id);
    await pumpFor(t, const Duration(seconds: 3));
    expect(t.takeException(), isNull);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });
}
