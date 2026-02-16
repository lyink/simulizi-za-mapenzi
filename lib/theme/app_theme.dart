import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Shared accent colours (same in both themes) ──────────────────────────
  static const Color accent = Color(0xFFE94560);
  static const Color gold = Color(0xFFF5A623);
  static const Color success = Color(0xFF4CAF50);

  // ── Dark theme palette ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF16213E);
  static const Color cardBg = Color(0xFF0F3460);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFFB0B0C8);
  static const Color gradientStart = Color(0xFF1A1A2E);
  static const Color gradientEnd = Color(0xFF16213E);

  // ── Light theme palette ──────────────────────────────────────────────────
  static const Color lightPrimary = Color(0xFFF8F4EF);
  static const Color lightSecondary = Color(0xFFEDE8E0);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F4EF);
  static const Color lightTextPrimary = Color(0xFF1C1208);
  static const Color lightTextMuted = Color(0xFF6B6560);

  // ── Dark ThemeData ────────────────────────────────────────────────────────
  static ThemeData get theme => _buildTheme(Brightness.dark);

  // ── Light ThemeData ───────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? primary : lightPrimary;
    final appBarBg = isDark ? secondary : lightSecondary;
    final card = isDark ? cardBg : lightCardBg;
    final textPrimary = isDark ? textLight : lightTextPrimary;
    final textSub = isDark ? textMuted : lightTextMuted;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFDDD8D0);
    final inputBorder = isDark ? Colors.white12 : const Color(0xFFCCC8C0);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: accent,
              secondary: gold,
              surface: surface,
              onPrimary: textLight,
              onSecondary: primary,
              onSurface: textLight,
            )
          : ColorScheme.light(
              primary: accent,
              secondary: gold,
              surface: lightSurface,
              onPrimary: Colors.white,
              onSecondary: lightPrimary,
              onSurface: lightTextPrimary,
            ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
          displayMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
          headlineLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
          headlineMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          titleMedium: TextStyle(
              color: textSub, fontWeight: FontWeight.w500, fontSize: 14),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSub, fontSize: 14),
          labelLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: appBarBg,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 8 : 3,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(color: textSub),
        hintStyle: TextStyle(color: textSub),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: textSub,
        textColor: textPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        labelStyle: TextStyle(color: textPrimary, fontSize: 12),
        side: BorderSide(color: inputBorder),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardBg, Color(0xFF1A2A5E)],
      );

  static LinearGradient coverGradient(Color dominantColor) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          dominantColor.withValues(alpha: 0.0),
          dominantColor.withValues(alpha: 0.8),
          Colors.black87,
        ],
        stops: const [0.4, 0.7, 1.0],
      );
}
