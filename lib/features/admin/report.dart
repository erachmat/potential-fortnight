import 'package:excel/excel.dart';

import '../../data/backend.dart';
import '../../domain/models/models.dart';
import 'export_stub.dart'
    if (dart.library.js_interop) 'export_web.dart'
    if (dart.library.io) 'export_io.dart' as exporter;

/// Laporan keuangan -> .xlsx (Ringkasan, Transaksi, Rekap Kurir). Angka sama dengan dashboard.
List<int> buildReport(Backend b) {
  final x = Excel.createExcel();
  final sum = x['Ringkasan'];
  final trx = x['Transaksi'];
  final rec = x['Rekap Kurir'];
  x.delete('Sheet1');

  CellValue t(String s) => TextCellValue(s);
  CellValue n(int v) => IntCellValue(v);

  sum.appendRow([t('Laporan Keuangan Nitip'), t('${b.now.day}/${b.now.month}/${b.now.year}')]);
  sum.appendRow([t('Transaksi hari ini'), n(b.transactionsToday)]);
  sum.appendRow([t('Nilai belanja (GMV)'), n(b.gmvToday)]);
  sum.appendRow([t('Ongkir untuk kurir'), n(b.shippingToday)]);
  sum.appendRow([t('Pendapatan platform (biaya layanan 2%)'), n(b.feeToday)]);
  sum.appendRow([t('Total uang masuk dari customer'), n(b.gmvToday + b.shippingToday + b.feeToday)]);
  sum.appendRow([t('Pesanan belum diantar'), n(b.undeliveredCount)]);

  trx.appendRow([t('ID'), t('Waktu bayar'), t('Customer'), t('Kurir'), t('Item'), t('Subtotal'), t('Ongkir'), t('Biaya layanan'), t('Total'), t('Status')]);
  final list = [...b.paidToday]..sort((a, c) => (a.timestamps[OrderStatus.paid] ?? a.createdAt).compareTo(c.timestamps[OrderStatus.paid] ?? c.createdAt));
  for (final o in list) {
    final at = o.timestamps[OrderStatus.paid] ?? o.createdAt;
    trx.appendRow([
      t(o.id), t('${at.hour.toString().padLeft(2, '0')}.${at.minute.toString().padLeft(2, '0')}'), t(o.customerName),
      t(o.courierId == null ? '-' : b.courier(o.courierId!).name), n(o.totalQty), n(o.subtotal), n(o.shipping), n(o.fee), n(o.total), t(o.status.label),
    ]);
  }

  rec.appendRow([t('NIM'), t('Nama Kurir'), t('Jumlah Pesanan Hari Ini'), t('Jumlah Rupiah Pesanan'), t('Nominal Ongkir yang Didapat'), t('Total Uang yang Harus Dikasih ke Kurir')]);
  for (final c in b.couriers) {
    final r = b.recap(c.id);
    rec.appendRow([t(c.nim), t(c.name), n(r.count), n(r.orderTotal), n(r.shipping), n(r.toPay)]);
  }
  return x.encode() ?? <int>[];
}

Future<void> downloadReport(Backend b) {
  final d = b.now;
  final name = 'laporan-nitip-${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}.xlsx';
  return exporter.saveFile(buildReport(b), name, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
}
