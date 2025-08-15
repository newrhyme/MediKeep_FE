import 'package:flutter/material.dart';

class AppTheme {
  // 배경색
  static const Color bg = Color(0xFFA1E3F7);

  static const Color text = Color(0xFF204567);

  static const Color primary = text;

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: text, primary: text),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: text,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: text,
            side: const BorderSide(color: text, width: 1.4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
