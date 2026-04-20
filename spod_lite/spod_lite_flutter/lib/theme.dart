import 'package:flutter/material.dart';

class Tokens {
  static const bg = Color(0xFF0B0F14);
  static const surface = Color(0xFF11161C);
  static const elevated = Color(0xFF151B23);
  static const hover = Color(0xFF1C242F);
  static const border = Color(0xFF232C38);
  static const borderSubtle = Color(0xFF1A2029);

  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B94A4);
  static const textMuted = Color(0xFF5A6573);

  static const accent = Color(0xFF38BDF8);
  static const accentSoft = Color(0xFF0C4A6E);
  static const danger = Color(0xFFF87171);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);

  static const monoFamily = 'monospace';

  static const radiusSm = 4.0;
  static const radiusMd = 6.0;
  static const radiusLg = 8.0;

  static const rowHeight = 44.0;
  static const headerHeight = 40.0;
  static const topbarHeight = 52.0;
  static const railWidth = 240.0;
}

ThemeData buildDarkTheme() {
  const textColor = Tokens.textPrimary;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Tokens.bg,
    canvasColor: Tokens.bg,
    dividerColor: Tokens.border,

    colorScheme: const ColorScheme.dark(
      surface: Tokens.surface,
      onSurface: Tokens.textPrimary,
      primary: Tokens.accent,
      onPrimary: Colors.black,
      secondary: Tokens.accent,
      onSecondary: Colors.black,
      error: Tokens.danger,
      onError: Colors.black,
      outline: Tokens.border,
      surfaceContainerHighest: Tokens.elevated,
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.2),
      titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor, letterSpacing: -0.1),
      titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textSecondary, letterSpacing: 0.4),
      bodyLarge: TextStyle(fontSize: 14, color: textColor, height: 1.4),
      bodyMedium: TextStyle(fontSize: 13, color: textColor, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: Tokens.textSecondary, height: 1.4),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
      labelMedium: TextStyle(fontSize: 12, color: Tokens.textSecondary),
      labelSmall: TextStyle(fontSize: 11, color: Tokens.textMuted, letterSpacing: 0.3),
    ),

    iconTheme: const IconThemeData(color: Tokens.textSecondary, size: 18),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Tokens.elevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      hintStyle: const TextStyle(color: Tokens.textMuted, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusMd),
        borderSide: const BorderSide(color: Tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusMd),
        borderSide: const BorderSide(color: Tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusMd),
        borderSide: const BorderSide(color: Tokens.accent, width: 1.2),
      ),
      isDense: true,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Tokens.accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusMd)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Tokens.textPrimary,
        side: const BorderSide(color: Tokens.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusMd)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Tokens.textSecondary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Tokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusLg),
        side: const BorderSide(color: Tokens.border),
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Tokens.elevated,
        borderRadius: BorderRadius.circular(Tokens.radiusSm),
        border: Border.all(color: Tokens.border),
      ),
      textStyle: const TextStyle(color: Tokens.textPrimary, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),

    dividerTheme: const DividerThemeData(
      color: Tokens.border,
      thickness: 1,
      space: 1,
    ),
  );
}
