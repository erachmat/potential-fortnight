/// Format uang & waktu. Uang selalu int rupiah.
String rupiah(int value, {bool sign = false}) {
  final neg = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  final prefix = neg ? '-' : (sign ? '+' : '');
  return '${prefix}Rp$buf';
}

/// 125 detik -> "02:05"
String mmss(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final m = (s ~/ 60).toString().padLeft(2, '0');
  final r = (s % 60).toString().padLeft(2, '0');
  return '$m:$r';
}

String clock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

String ago(Duration d) {
  if (d.inMinutes < 1) return 'baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
  return '${d.inHours} jam lalu';
}
