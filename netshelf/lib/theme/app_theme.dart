// theme/app_theme.dart
// NetShelf design system — cyber/networking aesthetic with blue-purple gradients

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color primaryPurple = Color(0xFF7C4DFF);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF1744);

  // Dark theme surface colors
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF0F1627);
  static const Color darkCard = Color(0xFF141D35);
  static const Color darkCardElevated = Color(0xFF1A2540);
  static const Color darkBorder = Color(0xFF1E2D4A);
  static const Color darkText = Color(0xFFE8EDF5);
  static const Color darkTextSecondary = Color(0xFF7A8BAA);
  static const Color darkTextMuted = Color(0xFF3D4F6B);

  // Light theme surface colors
  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDDE3F0);
  static const Color lightText = Color(0xFF0D1B3E);
  static const Color lightTextSecondary = Color(0xFF5A6B8A);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient cyberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF0C1220)],
  );

  // Category card gradients
  static const Map<String, List<Color>> categoryGradients = {
    'cat_networking': [Color(0xFF1565C0), Color(0xFF1976D2)],
    'cat_ccna': [Color(0xFF0D47A1), Color(0xFF1565C0)],
    'cat_cybersecurity': [Color(0xFFB71C1C), Color(0xFFC62828)],
    'cat_linux': [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    'cat_databases': [Color(0xFFE65100), Color(0xFFEF6C00)],
    'cat_programming': [Color(0xFF4A148C), Color(0xFF6A1B9A)],
  };

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryPurple,
        tertiary: accentCyan,
        surface: darkSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
      ),
      textTheme: _buildTextTheme(darkText, darkTextSecondary),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.spaceMono(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: primaryBlue.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue);
          }
          return const IconThemeData(color: darkTextSecondary);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCardElevated,
        selectedColor: primaryBlue.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(fontSize: 12),
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primaryBlue : darkTextSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primaryBlue.withOpacity(0.3) : darkBorder),
      ),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryPurple,
        tertiary: accentCyan,
        surface: lightSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
      ),
      textTheme: _buildTextTheme(lightText, lightTextSecondary),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.spaceMono(
          color: lightText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: lightText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primaryBlue.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFFADB5C8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightBg,
        selectedColor: primaryBlue.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(fontSize: 12),
        side: const BorderSide(color: lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.spaceMono(color: primary, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.spaceMono(color: primary, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.spaceMono(color: primary, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(color: primary),
      bodyMedium: GoogleFonts.inter(color: secondary),
      bodySmall: GoogleFonts.inter(color: secondary, fontSize: 12),
      labelLarge: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(color: secondary, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(color: secondary, fontSize: 10),
    );
  }
}

// ─── Design Tokens ────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;
}

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF2979FF).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];
}
