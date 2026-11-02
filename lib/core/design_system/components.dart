import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../motion/motion.dart';
import 'tokens.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon, this.light = false});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// Varian terbalik (putih di atas gelap/oranye).
  final bool light;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final bg = widget.light ? Colors.white : NColors.ink;
    final fg = widget.light ? NColors.ink : Colors.white;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: enabled
            ? () {
                Feel.light();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: Dur.fast,
          child: AnimatedContainer(
            duration: Dur.base,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: enabled || widget.loading ? bg : bg.withValues(alpha: 0.35), borderRadius: NRadius.pillBr),
            child: widget.loading
                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 20), const SizedBox(width: 8)],
                    Text(widget.label, style: NText.title.copyWith(color: fg)),
                  ]),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.danger = false, this.height = 48});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = danger ? NColors.danger : NColors.ink;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: NRadius.pillBr,
        onTap: onPressed == null ? null : () { Feel.select(); onPressed!(); },
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: NRadius.pillBr, border: Border.all(color: danger ? NColors.danger.withValues(alpha: .4) : NColors.line, width: 1.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18, color: color), const SizedBox(width: 8)],
            Text(label, style: NText.bodyStrong.copyWith(color: color)),
          ]),
        ),
      ),
    );
  }
}

/// Geser untuk konfirmasi (terima order, serahkan pesanan, tukar saldo).
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({super.key, required this.label, required this.onConfirmed, this.color = NColors.ink});

  final String label;
  final VoidCallback onConfirmed;
  final Color color;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _done = false;
  static const _knob = 48.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final max = c.maxWidth - _knob - 8;
      final progress = max <= 0 ? 0.0 : (_dx / max).clamp(0.0, 1.0);
      return Semantics(
        button: true,
        label: widget.label,
        onTap: () { if (!_done) { setState(() => _done = true); widget.onConfirmed(); } },
        child: Container(
          height: 56,
          decoration: BoxDecoration(color: widget.color, borderRadius: NRadius.pillBr),
          child: Stack(alignment: Alignment.centerLeft, children: [
            Center(
              child: Opacity(
                opacity: 1 - progress,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(widget.label, style: NText.title.copyWith(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              left: 4 + _dx,
              child: GestureDetector(
                onHorizontalDragUpdate: _done ? null : (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(0.0, max)),
                onHorizontalDragEnd: _done
                    ? null
                    : (_) {
                        if (progress > 0.85) {
                          Feel.medium();
                          setState(() { _dx = max; _done = true; });
                          widget.onConfirmed();
                        } else {
                          setState(() => _dx = 0);
                        }
                      },
                child: Container(
                  width: _knob,
                  height: _knob,
                  decoration: const BoxDecoration(color: NColors.brand, shape: BoxShape.circle),
                  child: Icon(_done ? Icons.check_rounded : Icons.chevron_right_rounded, color: NColors.ink, size: 28),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

/// Stepper qty; angka di tengah beranimasi naik/turun.
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.qty, required this.onInc, required this.onDec, this.compact = false});

  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = compact ? 30.0 : 36.0;
    Widget btn(IconData i, VoidCallback f, bool filled, String label) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () { Feel.select(); f(); },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(color: filled ? NColors.brand : NColors.surfaceAlt, shape: BoxShape.circle),
                  child: Icon(i, size: 18, color: NColors.ink),
                ),
              ),
            ),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      btn(Icons.remove_rounded, onDec, false, 'Kurangi'),
      SizedBox(
        width: 24,
        child: AnimatedSwitcher(
          duration: Dur.fast,
          transitionBuilder: (w, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: w)),
          child: Text('$qty', key: ValueKey(qty), textAlign: TextAlign.center, style: NText.number(16)),
        ),
      ),
      btn(Icons.add_rounded, onInc, true, 'Tambah'),
    ]);
  }
}

/// Chip kategori; indikator pill oranye meluncur ke yang terpilih (M-11).
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key, required this.items, required this.selected, required this.onSelected});

  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const w = 92.0, h = 40.0, gap = 8.0;
    return SizedBox(
      height: h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: NSpace.gutter),
        children: [
          SizedBox(
            width: items.length * (w + gap),
            height: h,
            child: Stack(children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Crv.emphasized,
                left: selected * (w + gap),
                child: Container(width: w, height: h, decoration: BoxDecoration(color: NColors.brand, borderRadius: NRadius.pillBr)),
              ),
              for (var i = 0; i < items.length; i++)
                Positioned(
                  left: i * (w + gap),
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: items[i],
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () { Feel.select(); onSelected(i); },
                      child: Container(
                        width: w,
                        height: h,
                        alignment: Alignment.center,
                        decoration: i == selected ? null : BoxDecoration(borderRadius: NRadius.pillBr, border: Border.all(color: NColors.line), color: NColors.surface),
                        child: Text(items[i], style: NText.bodyStrong.copyWith(color: NColors.ink)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  const NavItem(this.icon, this.label, {this.badge = 0});
  final IconData icon;
  final String label;
  final int badge;
}

/// Bottom nav pill mengambang; blob oranye meluncur ke tab aktif (M-12).
class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({super.key, required this.items, required this.index, required this.onChanged});

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: NColors.ink, borderRadius: NRadius.pillBr, boxShadow: NShadow.float),
        child: LayoutBuilder(builder: (_, c) {
          final w = c.maxWidth / items.length;
          return Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Crv.emphasized,
              left: index * w + (w - 52) / 2,
              top: 6,
              child: Container(width: 52, height: 52, decoration: const BoxDecoration(color: NColors.brand, shape: BoxShape.circle)),
            ),
            Row(children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: items[i].label,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () { Feel.select(); onChanged(i); },
                      child: Center(
                        child: Badge(
                          isLabelVisible: items[i].badge > 0,
                          label: Text('${items[i].badge}'),
                          backgroundColor: NColors.brand,
                          textColor: NColors.ink,
                          child: AnimatedScale(
                            duration: Dur.base,
                            scale: i == index ? 1.1 : 1,
                            child: Icon(items[i].icon, color: i == index ? NColors.ink : Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ]);
        }),
      ),
    );
  }
}

class NCard extends StatelessWidget {
  const NCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = NColors.surface, this.onTap, this.border = false});

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: NRadius.cardBr, boxShadow: border ? null : NShadow.card, border: border ? Border.all(color: NColors.line) : null),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: () { Feel.select(); onTap!(); }, child: box);
  }
}

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final box = Container(width: width, height: height, decoration: BoxDecoration(color: NColors.line, borderRadius: BorderRadius.circular(radius)));
    if (reduceMotion(context)) return box;
    return box.animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: .7));
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 88, height: 88, decoration: const BoxDecoration(color: NColors.brandSoft, shape: BoxShape.circle), child: Icon(icon, size: 40, color: NColors.brandText)),
            const SizedBox(height: 16),
            Text(title, style: NText.h2, textAlign: TextAlign.center),
            if (message != null) ...[const SizedBox(height: 8), Text(message!, style: NText.body, textAlign: TextAlign.center)],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ]),
        ),
      );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.color = NColors.info});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: NRadius.pillBr),
        child: Text(label, style: NText.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}
