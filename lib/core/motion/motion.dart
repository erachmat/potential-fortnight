import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dur {
  const Dur._();

  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const signature = Duration(milliseconds: 900);
  static const stagger = Duration(milliseconds: 40);
}

class Crv {
  const Crv._();

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const pop = Curves.easeOutBack;
}

/// Reduce motion: durasi dipangkas, animasi besar diganti fade.
bool reduceMotion(BuildContext c) => MediaQuery.maybeOf(c)?.disableAnimations ?? false;

/// Pengaturan global haptik/suara (diubah dari Panel Demo).
class Feel {
  const Feel._();

  static bool haptics = true;

  static void select() { if (haptics) HapticFeedback.selectionClick(); }
  static void light() { if (haptics) HapticFeedback.lightImpact(); }
  static void medium() { if (haptics) HapticFeedback.mediumImpact(); }
  static void heavy() { if (haptics) HapticFeedback.heavyImpact(); }
}
