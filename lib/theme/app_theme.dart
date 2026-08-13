import 'package:flutter/material.dart';

class AppTheme {
  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.greenAccent,
    brightness: Brightness.light,
  );

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.greenAccent,
    brightness: Brightness.dark,
  );

  static final light = ThemeData(
    colorScheme: lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
    ),
  );

  static final dark = ThemeData(
    colorScheme: darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
    ),
  );
}
