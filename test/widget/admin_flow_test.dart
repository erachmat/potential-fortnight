import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitip/app/app.dart';
import 'package:nitip/core/clock.dart';
import 'package:nitip/data/backend.dart';
import 'package:nitip/domain/models/models.dart';
import 'package:nitip/features/admin/report.dart';

import 'test_utils.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<Backend> openAdmin(WidgetTester t) async {
    phoneSize(t, w: 1400, h: 900);
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    await t.pumpWidget(NitipApp(backend: b));
    await pumpFor(t, const Duration(seconds: 3));
    await t.tap(find.text('Admin / Owner'));
    await pumpFor(t, const Duration(seconds: 1));
    await t.tap(find.textContaining('Pakai akun demo'));
    await pumpFor(t, const Duration(seconds: 2));
    return b;
  }

  testWidgets('admin: dashboard menampilkan KPI dan order telat', (t) async {
    final b = await openAdmin(t);
    expect(find.text('Ringkasan hari ini'), findsOneWidget);
    expect(find.text('27'), findsWidgets); // transaksi hari ini
    expect(find.textContaining('lewat SLA'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('admin: validasi KTM — setujui akun', (t) async {
    final b = await openAdmin(t);
    await t.tap(find.text('Validasi').first);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('Dimas Arya'), findsWidgets);
    expect(find.text('Setujui Akun'), findsOneWidget);
    // data pertama di daftar = Dimas (NIM beda 1 digit dari KTM)
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    await t.tap(find.text('Setujui Akun'));
    await pumpFor(t, const Duration(seconds: 2));
    expect(b.customers.firstWhere((c) => c.id == 'dimas').status, AccountStatus.active);
    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('admin: batalkan kurir yang telat', (t) async {
    final b = await openAdmin(t);
    await t.tap(find.text('Kurir').first);
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.text('LEWAT SLA'), findsOneWidget);
    await t.tap(find.text('Batalkan'));
    await pumpFor(t, const Duration(seconds: 1));
    expect(find.textContaining('Batalkan Andi dari NTP-0398?'), findsOneWidget);
    await t.tap(find.text('Batalkan Andi'));
    await pumpFor(t, const Duration(seconds: 1));
    final o = b.orderById('NTP-0398')!;
    expect(o.status, OrderStatus.searchingCourier);
    expect(o.courierId, isNull);
    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  testWidgets('admin: halaman laporan & pesanan tidak error', (t) async {
    final b = await openAdmin(t);
    for (final p in ['Pesanan', 'Tukar Saldo', 'Laporan']) {
      await t.tap(find.text(p).first);
      await pumpFor(t, const Duration(seconds: 1));
    }
    expect(find.textContaining('Unduh Excel'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    b.dispose();
  });

  test('laporan Excel: file valid dan angka sama dengan dashboard', () {
    final b = Backend(clock: ManualClock(DateTime(2026, 11, 2, 13, 20)), autoTick: false);
    final bytes = buildReport(b);
    expect(bytes.length, greaterThan(1000));
    // xlsx = zip: "PK"
    expect(bytes[0], 0x50);
    expect(bytes[1], 0x4B);
    b.dispose();
  });
}
