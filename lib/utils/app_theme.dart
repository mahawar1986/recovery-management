import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary      = Color(0xFF4F5F9F);
  static const primaryDark  = Color(0xFF3A4A80);
  static const primaryLight = Color(0xFFEEF0FF);
  static const teal         = Color(0xFF0D9488);
  static const tealLight    = Color(0xFFCCFBF1);
  static const success      = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning      = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const danger       = Color(0xFFEF4444);
  static const dangerLight  = Color(0xFFFEE2E2);
  static const purple       = Color(0xFF8B5CF6);
  static const purpleLight  = Color(0xFFEDE9FE);
  static const bg           = Color(0xFFF5F7FA);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFEEF2F8);
  static const border       = Color(0xFFE2E8F0);
  static const text         = Color(0xFF1E293B);
  static const textMid      = Color(0xFF475569);
  static const textMuted    = Color(0xFF94A3B8);
  static const sidebar      = Color(0xFF1E293B);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    ),
  );
}
