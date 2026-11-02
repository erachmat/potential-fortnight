import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design_system/tokens.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';

/// Banner notifikasi in-app gaya heads-up (M-40) untuk satu peran.
class RoleBanner extends StatefulWidget {
  const RoleBanner({super.key, required this.role, required this.child, this.onTap});

  final AppRole role;
  final Widget child;
  final void Function(AppNotification n)? onTap;

  @override
  State<RoleBanner> createState() => _RoleBannerState();
}

class _RoleBannerState extends State<RoleBanner> {
  AppNotification? _shown;
  String? _lastId;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.backend.lastNotification;
    if (n != null && n.id != _lastId && n.role == widget.role) {
      _lastId = n.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _shown = n);
        _t?.cancel();
        _t = Timer(const Duration(milliseconds: 3800), () { if (mounted) setState(() => _shown = null); });
      });
    } else if (n != null && n.id != _lastId) {
      _lastId = n.id;
    }
    return Stack(children: [
      widget.child,
      Positioned(
        left: 12,
        right: 12,
        top: MediaQuery.paddingOf(context).top + 8,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (w, a) => SlideTransition(position: Tween(begin: const Offset(0, -1.4), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: w)),
          child: _shown == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : Dismissible(
                  key: ValueKey(_shown!.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) => setState(() => _shown = null),
                  child: GestureDetector(
                    onTap: () { widget.onTap?.call(_shown!); setState(() => _shown = null); },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: NColors.ink, borderRadius: BorderRadius.circular(20), boxShadow: NShadow.float),
                      child: Row(children: [
                        Container(width: 36, height: 36, decoration: const BoxDecoration(color: NColors.brand, shape: BoxShape.circle), child: const Icon(Icons.notifications_rounded, size: 20, color: NColors.ink)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_shown!.title, style: NText.bodyStrong.copyWith(color: Colors.white, decoration: TextDecoration.none)),
                          Text(_shown!.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: NText.caption.copyWith(color: Colors.white70, decoration: TextDecoration.none)),
                        ])),
                      ]),
                    ),
                  ),
                ),
        ),
      ),
    ]);
  }
}
