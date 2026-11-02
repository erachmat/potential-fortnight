import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_app.dart';
import '../features/courier/courier_app.dart';
import '../features/customer/customer_app.dart';
import '../features/shared/gallery.dart';
import '../features/shared/role_picker.dart';
import '../features/shared/splash.dart';
import '../demo/stage/stage_screen.dart';

CustomTransitionPage<void> _fade(GoRouterState s, Widget child) => CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: c),
    );

GoRouter buildRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', pageBuilder: (c, s) => _fade(s, const SplashScreen())),
        GoRoute(path: '/roles', pageBuilder: (c, s) => _fade(s, const RolePickerScreen())),
        GoRoute(path: '/customer', pageBuilder: (c, s) => _fade(s, CustomerApp(onExit: () => c.go('/roles')))),
        GoRoute(path: '/courier', pageBuilder: (c, s) => _fade(s, CourierApp(onExit: () => c.go('/roles')))),
        GoRoute(path: '/admin', pageBuilder: (c, s) => _fade(s, AdminApp(onExit: () => c.go('/roles')))),
        GoRoute(path: '/stage', pageBuilder: (c, s) => _fade(s, const StageScreen())),
        GoRoute(path: '/_gallery', pageBuilder: (c, s) => _fade(s, const GalleryScreen())),
      ],
    );
