// // lib/core/theme/app_theme.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class AppColors {
//   AppColors._();
//
//   // ── Palette ───────────────────────────────────────────────
//   // DraftIt visual identity: deep midnight base, electric teal accent,
//   // warm amber for skills, soft ivory text.
//   static const Color background    = Color(0xFF0A0D14);  // midnight
//   static const Color surface       = Color(0xFF131720);  // card bg
//   static const Color surfaceAlt    = Color(0xFF1B2030);  // elevated card
//   static const Color border        = Color(0xFF252D40);  // subtle border
//
//   static const Color accent        = Color(0xFF00E5C3);  // electric teal
//   static const Color accentDim     = Color(0xFF00B89C);  // pressed teal
//   static const Color accentGlow    = Color(0x2200E5C3);  // glow overlay
//
//   static const Color amber         = Color(0xFFFFB347);  // skill chips
//   static const Color amberDim      = Color(0x33FFB347);
//
//   static const Color coral         = Color(0xFFFF6B6B);  // error / danger
//   static const Color coralDim      = Color(0x33FF6B6B);
//
//   static const Color textPrimary   = Color(0xFFF0EDE8);  // warm ivory
//   static const Color textSecondary = Color(0xFF8B92A6);  // muted
//   static const Color textTertiary  = Color(0xFF4A5269);  // very muted
//
//   // Recording gradient
//   static const List<Color> recordGradient = [
//     Color(0xFFFF416C),
//     Color(0xFFFF4B2B),
//   ];
//
//   // Accent gradient
//   static const List<Color> accentGradient = [
//     Color(0xFF00E5C3),
//     Color(0xFF0094FF),
//   ];
// }
//
// class AppTheme {
//   AppTheme._();
//
//   static ThemeData get dark {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: AppColors.background,
//       colorScheme: const ColorScheme.dark(
//         background: AppColors.background,
//         surface: AppColors.surface,
//         primary: AppColors.accent,
//         secondary: AppColors.amber,
//         error: AppColors.coral,
//         onBackground: AppColors.textPrimary,
//         onSurface: AppColors.textPrimary,
//         onPrimary: AppColors.background,
//         outline: AppColors.border,
//       ),
//       textTheme: _textTheme,
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         iconTheme: const IconThemeData(color: AppColors.textPrimary),
//         titleTextStyle: _textTheme.titleLarge?.copyWith(
//           color: AppColors.textPrimary,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       cardTheme: CardTheme(
//         color: AppColors.surface,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: const BorderSide(color: AppColors.border, width: 0.5),
//         ),
//       ),
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.surfaceAlt,
//         selectedColor: AppColors.accentGlow,
//         labelStyle: _textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
//         side: const BorderSide(color: AppColors.border, width: 0.5),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.surfaceAlt,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.border, width: 0.5),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.border, width: 0.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.accent, width: 1),
//         ),
//         hintStyle: TextStyle(color: AppColors.textTertiary),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       ),
//     );
//   }
//
//   static TextTheme get _textTheme {
//     // ClashDisplay for headings (editorial), Inter for body (legibility)
//     final clashDisplay = const TextStyle(fontFamily: 'ClashDisplay');
//     final inter = GoogleFonts.inter();
//
//     return TextTheme(
//       displayLarge:  clashDisplay.copyWith(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -1.5),
//       displayMedium: clashDisplay.copyWith(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -1.0),
//       displaySmall:  clashDisplay.copyWith(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.5),
//       headlineLarge: clashDisplay.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.3),
//       headlineMedium:clashDisplay.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
//       headlineSmall: clashDisplay.copyWith(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
//       titleLarge:    inter.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
//       titleMedium:   inter.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
//       titleSmall:    inter.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
//       bodyLarge:     inter.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.7),
//       bodyMedium:    inter.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6),
//       bodySmall:     inter.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
//       labelLarge:    inter.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.2),
//       labelMedium:   inter.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.3),
//       labelSmall:    inter.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surfaceElevated = Color(0xFF1C1C26);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9D97FF);
  static const Color amber = Color(0xFFFFB830);
  static const Color success = Color(0xFF4CAF82);
  static const Color error = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color border = Color(0xFF2A2A3A);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: amber,
        surface: surface,
        background: bg,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.dmSans(color: textSecondary),
        hintStyle: GoogleFonts.dmSans(color: textSecondary),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Light theme ────────────────────────────────────────────────────────────
  static const Color bgLight           = Color(0xFFF8F8FF);
  static const Color surfaceLight      = Color(0xFFFFFFFF);
  static const Color surfaceElevLight  = Color(0xFFF0F0FF);
  static const Color textPrimaryLight  = Color(0xFF1A1A2E);
  static const Color textSecondaryLight= Color(0xFF6B6B90);
  static const Color borderLight       = Color(0xFFE0E0F0);

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: amber,
        surface: surfaceLight,
        background: bgLight,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineLarge: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimaryLight),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleMedium: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryLight),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: textPrimaryLight, height: 1.6),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: textSecondaryLight, height: 1.5),
        labelLarge: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryLight),
        labelMedium: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight, elevation: 0, centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryLight),
        iconTheme: const IconThemeData(color: textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 2)),
        labelStyle: GoogleFonts.dmSans(color: textSecondaryLight),
      ),
      cardTheme: CardTheme(
        color: surfaceLight, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: borderLight)),
      ),
      dividerColor: borderLight,
    );
  }

}