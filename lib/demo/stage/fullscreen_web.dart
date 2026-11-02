import 'package:web/web.dart' as web;

void toggleFullscreen() {
  final doc = web.document;
  if (doc.fullscreenElement != null) {
    doc.exitFullscreen();
  } else {
    doc.documentElement?.requestFullscreen();
  }
}
