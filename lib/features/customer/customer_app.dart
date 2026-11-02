import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../demo/notifications/banner.dart';
import '../../demo/sound.dart';
import '../../domain/models/models.dart';
import 'auth_screens.dart';

/// Target animasi terbang ke keranjang. Tiap layar yang punya FAB mendaftarkan key-nya sendiri
/// (satu GlobalKey tidak boleh dipakai dua widget sekaligus); yang aktif = layar paling atas.
class CartAnchors {
  final GlobalKey shell = GlobalKey(debugLabel: 'cart-shell');
  GlobalKey? screen;

  GlobalKey get active => screen ?? shell;
}

/// Konteks bersama untuk aplikasi Customer.
class CustomerHost extends InheritedWidget {
  const CustomerHost({super.key, required this.onExit, required this.cart, required super.child});

  final VoidCallback onExit;
  final CartAnchors cart;

  static CustomerHost of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<CustomerHost>()!;

  @override
  bool updateShouldNotify(CustomerHost old) => false;
}

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  final _cart = CartAnchors();
  final _nav = GlobalKey<NavigatorState>();
  int _epoch = 0;

  @override
  Widget build(BuildContext context) {
    return CustomerHost(
      onExit: () => setState(() { _epoch++; widget.onExit(); }),
      cart: _cart,
      child: RoleBanner(
        role: AppRole.customer,
        child: Navigator(
          key: _nav,
          onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => LoginScreen(key: ValueKey(_epoch))),
        ),
      ),
    );
  }
}

/// Terbang ke keranjang (M-14): thumbnail melengkung ke FAB keranjang.
void flyToCart(BuildContext button, GlobalKey cartKey, String emoji) {
  final overlay = Overlay.maybeOf(button);
  final cartCtx = cartKey.currentContext;
  final btnBox = button.findRenderObject();
  if (overlay == null || cartCtx == null || btnBox is! RenderBox || reduceMotion(button)) return;
  final ob = overlay.context.findRenderObject() as RenderBox;
  final cb = cartCtx.findRenderObject() as RenderBox;
  final from = ob.globalToLocal(btnBox.localToGlobal(btnBox.size.center(Offset.zero)));
  final to = ob.globalToLocal(cb.localToGlobal(cb.size.center(Offset.zero)));
  late OverlayEntry e;
  e = OverlayEntry(builder: (_) => _FlyDot(from: from, to: to, emoji: emoji, onDone: () { e.remove(); Sound.pop(); }));
  overlay.insert(e);
}

class _FlyDot extends StatelessWidget {
  const _FlyDot({required this.from, required this.to, required this.emoji, required this.onDone});

  final Offset from;
  final Offset to;
  final String emoji;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final ctrl = Offset((from.dx + to.dx) / 2, (from.dy < to.dy ? from.dy : to.dy) - 120);
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        onEnd: onDone,
        builder: (_, t, _) {
          final u = 1 - t;
          final p = from * (u * u) + ctrl * (2 * u * t) + to * (t * t);
          final scale = 1 - 0.65 * t;
          return Stack(children: [
            Positioned(
              left: p.dx - 20,
              top: p.dy - 20,
              child: Opacity(
                opacity: t > .9 ? (1 - t) * 10 : 1,
                child: Transform.scale(
                  scale: scale,
                  child: Container(width: 40, height: 40, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 10)]), child: Text(emoji, style: const TextStyle(fontSize: 22, decoration: TextDecoration.none))),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
