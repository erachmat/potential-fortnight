import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: NColors.brand,
    brightness: Brightness.light,
  ).copyWith(
    primary: NColors.ink,
    onPrimary: Colors.white,
    secondary: NColors.brand,
    onSecondary: NColors.ink,
    surface: NColors.surface,
    error: NColors.danger,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    colorScheme: scheme,
    scaffoldBackgroundColor: NColors.surfaceAlt,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      bodyMedium: NText.body,
      bodyLarge: NText.body,
      titleMedium: NText.title,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: NRadius.inputBr, borderSide: const BorderSide(color: NColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: NRadius.inputBr, borderSide: const BorderSide(color: NColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: NRadius.inputBr, borderSide: const BorderSide(color: NColors.ink, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: NRadius.inputBr, borderSide: const BorderSide(color: NColors.danger)),
      hintStyle: NText.body.copyWith(color: NColors.ink400),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
