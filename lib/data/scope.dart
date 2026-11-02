import 'package:flutter/widgets.dart';

import 'backend.dart';

/// Membagikan satu [Backend] ke seluruh pohon widget (juga ke 3 panel Mode Panggung).
/// `BackendScope.of(context)` otomatis rebuild saat data berubah.
class BackendScope extends InheritedNotifier<Backend> {
  const BackendScope({super.key, required Backend backend, required super.child}) : super(notifier: backend);

  static Backend of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<BackendScope>()!.notifier!;

  /// Tanpa subscribe (untuk aksi di callback).
  static Backend read(BuildContext context) => (context.getInheritedWidgetOfExactType<BackendScope>()!).notifier!;
}

extension BackendContext on BuildContext {
  Backend get backend => BackendScope.of(this);
  Backend get api => BackendScope.read(this);
}
