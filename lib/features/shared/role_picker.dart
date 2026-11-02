import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand/brand.dart';
import '../../core/brand/logo.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/motion/motion.dart';

/// S-02 — pilih peran.
class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1280;
    final cards = <_RoleCard>[
      const _RoleCard(icon: Icons.shopping_bag_rounded, title: 'Customer', subtitle: 'Pesan jajanan dari banyak kantin', route: '/customer', color: NColors.brand),
      const _RoleCard(icon: Icons.two_wheeler_rounded, title: 'Kurir', subtitle: 'Terima order, belanja, antar', route: '/courier', color: NColors.ink, dark: true),
      const _RoleCard(icon: Icons.insights_rounded, title: 'Admin / Owner', subtitle: 'Pantau transaksi & kurir', route: '/admin', color: NColors.info),
      if (kIsWeb && wide) const _RoleCard(icon: Icons.devices_rounded, title: 'Mode Panggung', subtitle: 'Customer + Kurir + Admin sekaligus', route: '/stage', color: NColors.success),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(NSpace.gutter),
              children: [
                const SizedBox(height: 12),
                const Row(children: [NitipMark(size: 40), SizedBox(width: 8), NitipWordmark(size: 28)]),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 32, height: 1.2, color: NColors.ink600, fontWeight: FontWeight.w400), children: [
                    TextSpan(text: 'Mau masuk sebagai\n'),
                    TextSpan(text: 'siapa', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink)),
                    TextSpan(text: '?'),
                  ]),
                ).animate().fadeIn(duration: Dur.slow).slideY(begin: .1),
                const SizedBox(height: 8),
                const Text('Prototype ${Brand.name} — semua data simulasi.', style: NText.body),
                const SizedBox(height: 24),
                for (var i = 0; i < cards.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: cards[i].animate(delay: (160 + i * 60).ms).fadeIn(duration: Dur.base).slideY(begin: .12, curve: Crv.standard),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.route, required this.color, this.dark = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: NCard(
        onTap: () => context.go(route),
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: color == NColors.brand ? NColors.brandText : color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: NText.title), const SizedBox(height: 2), Text(subtitle, style: NText.body)])),
          const Icon(Icons.arrow_forward_rounded, color: NColors.ink400),
        ]),
      ),
    );
  }
}
