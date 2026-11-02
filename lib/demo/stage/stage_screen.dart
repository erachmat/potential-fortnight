import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/tokens.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import '../../features/admin/admin_app.dart';
import '../../features/courier/courier_app.dart';
import '../../features/customer/customer_app.dart';
import '../demo_panel/demo_panel.dart';
import 'fullscreen_stub.dart' if (dart.library.js_interop) 'fullscreen_web.dart' as fs;

/// Mode Panggung: Customer + Kurir + Admin berdampingan, state dibagi live.
class StageScreen extends StatefulWidget {
  const StageScreen({super.key});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  int _focus = 0; // 0 = rata, 1..3 = fokus panel
  final _epochs = [0, 0, 0];

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    // jangan curi ketikan saat mengisi form
    final primary = FocusManager.instance.primaryFocus;
    if (primary?.context?.findAncestorWidgetOfExactType<EditableText>() != null) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.digit1) { setState(() => _focus = _focus == 1 ? 0 : 1); return KeyEventResult.handled; }
    if (k == LogicalKeyboardKey.digit2) { setState(() => _focus = _focus == 2 ? 0 : 2); return KeyEventResult.handled; }
    if (k == LogicalKeyboardKey.digit3) { setState(() => _focus = _focus == 3 ? 0 : 3); return KeyEventResult.handled; }
    if (k == LogicalKeyboardKey.keyD) { showDemoPanel(context, router: GoRouter.of(context)); return KeyEventResult.handled; }
    if (k == LogicalKeyboardKey.keyF) { fs.toggleFullscreen(); return KeyEventResult.handled; }
    if (k == LogicalKeyboardKey.keyR) { _confirmReset(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset semua data?'),
        content: const Text('Semua pesanan, saldo, dan pendaftaran kembali ke data awal demo.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset'))],
      ),
    );
    if (ok == true && mounted) {
      context.api.reset();
      setState(() { for (var i = 0; i < 3; i++) { _epochs[i]++; } });
    }
  }

  @override
  Widget build(BuildContext context) {
    double flex(int panel, double base) => _focus == 0 ? base : (_focus == panel ? base * 1.5 : base * .65);
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: NColors.ink,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(children: [
                const Text('MODE PANGGUNG', style: TextStyle(fontFamily: 'PlusJakartaSans', color: NColors.brand, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(width: 16),
                const Text('1·2·3 fokus   R reset   D panel demo   F layar penuh', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white38, fontSize: 12)),
                const Spacer(),
                TextButton(onPressed: () => context.go('/roles'), child: const Text('Keluar', style: TextStyle(color: Colors.white70))),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(flex: (flex(1, 414) * 10).round(), child: _Panel(role: AppRole.customer, label: 'Customer · Rina', logicalSize: const Size(390, 844), phone: true, child: CustomerApp(key: ValueKey('c${_epochs[0]}'), onExit: () => setState(() => _epochs[0]++)))),
                  const SizedBox(width: 16),
                  Expanded(flex: (flex(2, 414) * 10).round(), child: _Panel(role: AppRole.courier, label: 'Kurir · Sari', logicalSize: const Size(390, 844), phone: true, child: CourierApp(key: ValueKey('k${_epochs[1]}'), onExit: () => setState(() => _epochs[1]++)))),
                  const SizedBox(width: 16),
                  Expanded(flex: (flex(3, 1100) * 10).round(), child: _Panel(role: AppRole.admin, label: 'Admin · Nitip Console', logicalSize: const Size(1100, 760), phone: false, child: AdminApp(key: ValueKey('a${_epochs[2]}'), onExit: () => setState(() => _epochs[2]++)))),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Bingkai satu panel + spotlight oranye saat ada event untuk perannya (M-39).
class _Panel extends StatefulWidget {
  const _Panel({required this.role, required this.label, required this.logicalSize, required this.phone, required this.child});

  final AppRole role;
  final String label;
  final Size logicalSize;
  final bool phone;
  final Widget child;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  String? _lastId;
  String? _caption;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.backend.lastNotification;
    if (n != null && n.id != _lastId) {
      _lastId = n.id;
      if (n.role == widget.role) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _caption = n.title);
          _t?.cancel();
          _t = Timer(const Duration(seconds: 3), () { if (mounted) setState(() => _caption = null); });
        });
      }
    }
    final glow = _caption != null;
    final mq = MediaQuery.of(context);
    final inner = MediaQuery(
      data: mq.copyWith(size: widget.logicalSize, padding: EdgeInsets.only(top: widget.phone ? 28 : 0), viewPadding: EdgeInsets.zero, viewInsets: EdgeInsets.zero, textScaler: TextScaler.noScaling),
      child: widget.child,
    );
    final framed = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(widget.phone ? 10 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0A09),
        borderRadius: BorderRadius.circular(widget.phone ? 48 : 18),
        border: Border.all(color: glow ? NColors.brand : const Color(0xFF2B2623), width: glow ? 4 : 2),
        boxShadow: glow ? [BoxShadow(color: NColors.brand.withValues(alpha: .55), blurRadius: 40, spreadRadius: 6)] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.phone ? 38 : 12),
        child: SizedBox(
          width: widget.logicalSize.width,
          height: widget.logicalSize.height,
          child: Stack(children: [
            Positioned.fill(child: ScaffoldMessenger(child: inner)),
            if (widget.phone) Positioned(top: 8, left: 0, right: 0, child: Center(child: Container(width: 100, height: 22, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14))))),
          ]),
        ),
      ),
    );
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 28,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _caption == null
              ? const SizedBox.shrink()
              : Container(key: ValueKey(_caption), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: NColors.brand, borderRadius: NRadius.pillBr), child: Text(_caption!, style: const TextStyle(fontFamily: 'PlusJakartaSans', color: NColors.ink, fontWeight: FontWeight.w800, fontSize: 12))),
        ),
      ),
      Flexible(child: FittedBox(fit: BoxFit.contain, child: framed)),
      const SizedBox(height: 8),
      Text(widget.label, style: const TextStyle(fontFamily: 'PlusJakartaSans', color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}
