import 'package:url_launcher/url_launcher.dart';

/// 08xx -> 628xx untuk tautan wa.me.
String _intl(String phone) {
  final d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('0')) return '62${d.substring(1)}';
  return d;
}

Future<bool> openWhatsApp(String phone, {String text = ''}) async {
  try {
    final uri = Uri.parse('https://wa.me/${_intl(phone)}${text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}'}');
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<bool> callPhone(String phone) async {
  try {
    return await launchUrl(Uri.parse('tel:$phone'));
  } catch (_) {
    return false;
  }
}
