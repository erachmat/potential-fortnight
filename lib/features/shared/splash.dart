import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand/brand.dart';
import '../../core/brand/logo.dart';
import '../../core/design_system/tokens.dart';
import '../../core/motion/motion.dart';

/// S-01 — logo digambar (M-01), lalu masuk ke pemilih peran.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/roles');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotion(context);
    if (reduce) _c.value = 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(animation: _c, builder: (_, _) => NitipMark(size: 120, progress: _c.value)),
          const SizedBox(height: 12),
          const NitipWordmark(size: 44)
              .animate(delay: 1100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: .3, curve: Crv.standard),
          const SizedBox(height: 8),
          const Text(Brand.tagline, style: NText.body).animate(delay: 1500.ms).fadeIn(duration: 400.ms),
        ]),
      ),
    );
  }
}
