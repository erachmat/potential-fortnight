import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Android/iOS: bagikan file lewat share sheet (simpan ke Drive/WhatsApp/dll).
Future<void> saveFile(List<int> bytes, String name, String mime) async {
  await SharePlus.instance.share(ShareParams(files: [XFile.fromData(Uint8List.fromList(bytes), name: name, mimeType: mime)], fileNameOverrides: [name]));
}
