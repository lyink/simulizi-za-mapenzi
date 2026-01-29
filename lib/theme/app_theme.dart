import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8D4E27);
  static const Color primaryVariant = Color(0xFF5D2F19);
  static const Color secondaryColor = Color(0xFFA66B3C);
  static const Color accentColor = Color(0xFFD4A574);
  static const Color surfaceColor = Color(0xFFFAF7F2);
  static const Color backgroundColor = Color(0xFFFFFDF9);
  static const Color errorColor = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF3C2415);
  static const Color textSecondary = Color(0xFF8D6E47);
  static const Color textHint = Color(0xFFB8A082);

  static const Color cardShadow = Color(0x0D8D4E27);
  static const Color dividerColor = Color(0xFFE6D5C3);

  // Get dynamic primary color based on color scheme
  static Color getPrimaryColor(String colorScheme) {
    switch (colorScheme) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'default':
      default:
        return primaryColor;
    }
  }

  static TextTheme getTextTheme([double fontSizeMultiplier = 1.0]) => GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 32 * fontSizeMultiplier,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.25,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 22 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 14 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 12 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16 * fontSizeMultiplier,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14 * fontSizeMultiplier,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12 * fontSizeMultiplier,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
      color: textPrimary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
  );

  static ThemeData lightTheme({
    String colorScheme = 'default',
    double fontSizeMultiplier = 1.0,
  }) {
    final primary = getPrimaryColor(colorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
      ),
      textTheme: getTextTheme(fontSizeMultiplier),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 2,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: textHint,
          fontSize: 16 * fontSizeMultiplier,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        disabledColor: dividerColor,
        selectedColor: primary,
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(
          fontSize: 12 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
    );
  }

  static ThemeData darkTheme({
    String colorScheme = 'default',
    double fontSizeMultiplier = 1.0,
  }) {
    final primary = getPrimaryColor(colorScheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        surface: const Color(0xFF2D1B0F),
        onSurface: const Color(0xFFF5E6D3),
        error: errorColor,
      ),
      textTheme: getTextTheme(fontSizeMultiplier).apply(
        bodyColor: const Color(0xFFF5E6D3),
        displayColor: const Color(0xFFF5E6D3),
        decorationColor: const Color(0xFFF5E6D3),
      ),
      scaffoldBackgroundColor: const Color(0xFF1F1209),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D1B0F),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D1B0F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5D2F19)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5D2F19)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF8D6E47),
          fontSize: 16 * fontSizeMultiplier,
        ),
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFFF5E6D3),
          fontSize: 16 * fontSizeMultiplier,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D1B0F),
        disabledColor: const Color(0xFF5D2F19),
        selectedColor: primary,
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(
          fontSize: 12 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5E6D3),
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textColor: const Color(0xFFF5E6D3),
        iconColor: const Color(0xFFD4A574),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFD4A574),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF5D2F19),
        thickness: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1F1209),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2D1B0F),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF5E6D3),
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16 * fontSizeMultiplier,
          color: const Color(0xFFF5E6D3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2D1B0F),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14 * fontSizeMultiplier,
          color: const Color(0xFFF5E6D3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}