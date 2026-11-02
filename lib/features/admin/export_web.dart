import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Memicu unduhan file di browser lewat blob + anchor.
Future<void> saveFile(List<int> bytes, String name, String mime) async {
  final parts = <JSAny>[Uint8List.fromList(bytes).toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.append(a);
  a.click();
  a.remove();
  web.URL.revokeObjectURL(url);
}
