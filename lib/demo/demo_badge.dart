import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/tokens.dart';
import 'demo_panel/demo_panel.dart';

/// Badge "MODE DEMO" di atas semua layar. Tekan lama 1 detik -> Panel Demo.
class DemoOverlay extends StatelessWidget {
  const DemoOverlay({super.key, required this.router, required this.child, this.showBadge = true});

  final GoRouter router;
  final Widget child;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (showBadge)
        Positioned(
          top: MediaQuery.paddingOf(context).top + 6,
          right: 10,
          child: DemoBadge(onLongPress: () {
            final ctx = router.routerDelegate.navigatorKey.currentContext;
            if (ctx != null) showDemoPanel(ctx, router: router);
          }),
        ),
    ]);
  }
}

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key, required this.onLongPress});
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Mode demo. Tekan lama untuk membuka panel demo.',
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: NColors.ink.withValues(alpha: .86), borderRadius: NRadius.pillBr),
            child: const Text('MODE DEMO', style: TextStyle(fontFamily: 'PlusJakartaSans', color: NColors.brand, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .6, decoration: TextDecoration.none)),
          ),
        ),
      );
}
