import 'package:flutter/material.dart';

class NColors {
  const NColors._();

  static const brand = Color(0xFFFF6A2B);
  static const brandPressed = Color(0xFFE5531A);
  static const brandSoft = Color(0xFFFFF1EA);
  static const brandText = Color(0xFFC2410C);
  static const ink = Color(0xFF14110F);
  static const ink600 = Color(0xFF5F5A55);
  static const ink400 = Color(0xFF9A948E);
  static const line = Color(0xFFECE8E4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7F5F3);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE5484D);
  static const info = Color(0xFF2F6FEB);
}

class NSpace {
  const NSpace._();

  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32, s40 = 40;
  static const double gutter = 20;
}

class NRadius {
  const NRadius._();

  static const double input = 12, card = 20, sheet = 28, pill = 999;
  static BorderRadius get cardBr => BorderRadius.circular(card);
  static BorderRadius get sheetBr => BorderRadius.circular(sheet);
  static BorderRadius get inputBr => BorderRadius.circular(input);
  static BorderRadius get pillBr => BorderRadius.circular(pill);
}

class NShadow {
  const NShadow._();

  static const card = [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4))];
  static const float = [BoxShadow(color: Color(0x1F000000), blurRadius: 30, offset: Offset(0, 10))];
}

const _tabular = [FontFeature.tabularFigures()];

class NText {
  const NText._();

  static const _f = 'PlusJakartaSans';
  static const display = TextStyle(fontFamily: _f, fontSize: 32, height: 38 / 32, fontWeight: FontWeight.w800, color: NColors.ink);
  static const h1 = TextStyle(fontFamily: _f, fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w700, color: NColors.ink);
  static const h2 = TextStyle(fontFamily: _f, fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700, color: NColors.ink);
  static const title = TextStyle(fontFamily: _f, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, color: NColors.ink);
  static const body = TextStyle(fontFamily: _f, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: NColors.ink600);
  static const bodyStrong = TextStyle(fontFamily: _f, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: NColors.ink);
  static const caption = TextStyle(fontFamily: _f, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: NColors.ink600);

  /// Angka (rupiah, timer) selalu tabular supaya odometer tidak bergoyang.
  static TextStyle number(double size, {FontWeight weight = FontWeight.w700, Color color = NColors.ink}) =>
      TextStyle(fontFamily: _f, fontSize: size, height: 1.2, fontWeight: weight, color: color, fontFeatures: _tabular);
}
