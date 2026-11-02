import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/app/app.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/domain/models/models.dart';

import 'test_utils.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('kurir: login -> order masuk -> terima -> belanja -> serahkan -> saldo', (t) async {
    phoneSize(t);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));
    await t.tap(find.text('Kurir'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.textContaining('Pakai akun demo'));
    await t.pump();
    await t.tap(find.text('Masuk').last);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.textContaining('Halo, Sari'), findsOneWidget);
    final saldo0 = b.availableOf('sari');

    // pesanan masuk: Budi menolak -> Sari ditawari
    b.addToCart(b.products.firstWhere((p) => p.id == 'a1'), qty: 2);
    b.addToCart(b.products.firstWhere((p) => p.id == 'b1'), qty: 4);
    final o = b.placeOrder(Destination(building: b.buildings.first, room: 'Lt. 3', landmark: 'x'));
    b.simulatePayment(o.id);
    b.rejectOffer(o.id, 'budi');
    await pumpFor(t, const Duration(seconds: 2));
    expect(find.text('PESANAN BARU'), findsOneWidget);
    expect(find.text('Rp48.000'), findsWidgets);

    await t.drag(find.byIcon(Icons.chevron_right_rounded), const Offset(400, 0));
    await pumpFor(t, const Duration(seconds: 2));
    expect(o.status, OrderStatus.courierAssigned);

    await t.tap(find.text(o.id).first);
    await pumpFor(t, const Duration(seconds: 1));
    // detail per kantin
    expect(find.textContaining('Kantin A'), findsWidgets);
    expect(find.textContaining('Siapkan uang Rp20.000'), findsNWidgets(2));

    Future<void> shop(String canteenCode, List<String> items) async {
      for (final i in items) {
        await t.tap(find.textContaining(i).first);
        await t.pump(const Duration(milliseconds: 300));
      }
      await t.tap(find.textContaining('Selesai belanja di Kantin $canteenCode'));
      await pumpFor(t, const Duration(seconds: 1));
    }

    await shop('A', ['Pisang Goreng']);
    expect(o.purchasedCanteens, {'A'});
    await shop('B', ['Kopi Hitam']);
    expect(o.status, OrderStatus.delivering);

    await t.drag(find.byIcon(Icons.chevron_right_rounded), const Offset(400, 0));
    await pumpFor(t, const Duration(seconds: 3));
    expect(o.status, OrderStatus.delivered);
    expect(find.text('+Rp48.000'), findsOneWidget);
    expect(b.availableOf('sari') - saldo0, 48000);

    await t.pumpWidget(const SizedBox());
    b.dispose();
  });
}
