import 'package:flutter/material.dart';

import '../core/design_system/theme.dart';
import '../data/backend.dart';
import '../data/scope.dart';
import '../demo/demo_badge.dart';
import 'router.dart';

class NitipApp extends StatefulWidget {
  const NitipApp({super.key, this.backend});

  /// Untuk test; default membuat Backend baru.
  final Backend? backend;

  @override
  State<NitipApp> createState() => _NitipAppState();
}

class _NitipAppState extends State<NitipApp> {
  late final Backend _backend = widget.backend ?? Backend();
  late final _router = buildRouter();

  @override
  void dispose() {
    if (widget.backend == null) _backend.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackendScope(
      backend: _backend,
      child: MaterialApp.router(
        title: 'Nitip',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
        builder: (context, child) => DemoOverlay(router: _router, child: child ?? const SizedBox()),
      ),
    );
  }
}
