import 'package:flutter/material.dart';

/// NEXORA visual identity: black / white / orange accent, soft shadows,
/// rounded cards, subtle gradients.
class NexColors {
  static const bg = Color(0xFF0B0C0F);
  static const surface = Color(0xFF14161B);
  static const surfaceHi = Color(0xFF1D2027);
  static const accent = Color(0xFFFF7A1A);
  static const accentSoft = Color(0xFFFFB067);
  static const text = Color(0xFFF5F6F8);
  static const textDim = Color(0xFF9AA0AB);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF30A46C);
  static const line = Color(0xFF262A32);
}

class NexTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: NexColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: NexColors.accent,
        secondary: NexColors.accentSoft,
        surface: NexColors.surface,
        error: NexColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NexColors.bg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: NexColors.text,
        titleTextStyle: TextStyle(
          color: NexColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: NexColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.black26,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexColors.surfaceHi,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NexColors.accent, width: 1.4),
        ),
        hintStyle: const TextStyle(color: NexColors.textDim),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NexColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexColors.text,
          side: const BorderSide(color: NexColors.line),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: NexColors.accent),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: NexColors.surfaceHi,
        contentTextStyle: TextStyle(color: NexColors.text),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: NexColors.line, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NexColors.bg,
        indicatorColor: NexColors.accent.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? NexColors.accent
                  : NexColors.textDim,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? NexColors.accent
                  : NexColors.textDim,
            )),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NexColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NexColors.surfaceHi,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NexColors.surfaceHi,
        labelStyle: const TextStyle(color: NexColors.text, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Subtle orange gradient used on accents (logo, story ring, buttons).
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NexColors.accent, NexColors.accentSoft],
  );
}
