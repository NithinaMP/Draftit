import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark palette ───────────────────────────────────────────────────────────
  static const Color bg              = Color(0xFF0A0A0F);
  static const Color surface         = Color(0xFF13131A);
  static const Color surfaceElevated = Color(0xFF1C1C26);
  static const Color accent          = Color(0xFF6C63FF);
  static const Color accentLight     = Color(0xFF9D97FF);
  static const Color amber           = Color(0xFFFFB830);
  static const Color success         = Color(0xFF4CAF82);
  static const Color error           = Color(0xFFFF5252);
  static const Color textPrimary     = Color(0xFFF0F0FF);
  static const Color textSecondary   = Color(0xFF8888AA);
  static const Color border          = Color(0xFF2A2A3A);

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color bgLight              = Color(0xFFF8F8FF);
  static const Color surfaceLight         = Color(0xFFFFFFFF);
  static const Color surfaceElevLight     = Color(0xFFF0F0FF);
  static const Color textPrimaryLight     = Color(0xFF1A1A2E);
  static const Color textSecondaryLight   = Color(0xFF6B6B90);
  static const Color borderLight          = Color(0xFFE0E0F0);

  // ── Context helpers — use these in widgets ─────────────────────────────────
  static Color bgOf(BuildContext ctx)              => Theme.of(ctx).scaffoldBackgroundColor;
  static Color surfaceOf(BuildContext ctx)         => Theme.of(ctx).colorScheme.surface;
  static Color surfaceElevOf(BuildContext ctx)     => Theme.of(ctx).colorScheme.surfaceVariant;
  static Color textPrimaryOf(BuildContext ctx)     => Theme.of(ctx).colorScheme.onSurface;
  static Color textSecondaryOf(BuildContext ctx)   => Theme.of(ctx).colorScheme.onSurfaceVariant;
  static Color borderOf(BuildContext ctx)          => Theme.of(ctx).dividerColor;
  static bool  isDark(BuildContext ctx)            => Theme.of(ctx).brightness == Brightness.dark;

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: amber,
        surface: surface,
        surfaceVariant: surfaceElevated,
        background: bg,
        error: error,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onBackground: textPrimary,
      ),
      textTheme: _textTheme(textPrimary, textSecondary),
      appBarTheme: _appBar(bg, textPrimary),
      elevatedButtonTheme: _elevatedBtn(),
      inputDecorationTheme: _inputDeco(surface, border, textSecondary),
      cardTheme: _card(surface, border),
      pageTransitionsTheme: _transitions(),
    );
  }

  // ── Light theme ─────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      dividerColor: borderLight,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: amber,
        surface: surfaceLight,
        surfaceVariant: surfaceElevLight,
        background: bgLight,
        error: error,
        onSurface: textPrimaryLight,
        onSurfaceVariant: textSecondaryLight,
        onBackground: textPrimaryLight,
      ),
      textTheme: _textTheme(textPrimaryLight, textSecondaryLight),
      appBarTheme: _appBar(bgLight, textPrimaryLight),
      elevatedButtonTheme: _elevatedBtn(),
      inputDecorationTheme: _inputDeco(surfaceLight, borderLight, textSecondaryLight),
      cardTheme: _card(surfaceLight, borderLight),
      pageTransitionsTheme: _transitions(),
    );
  }

  // ── Shared builders ────────────────────────────────────────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge:  GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.w700, color: primary),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w700, color: primary),
    headlineLarge: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: primary),
    headlineMedium:GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
    titleLarge:    GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
    titleMedium:   GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
    bodyLarge:     GoogleFonts.dmSans(fontSize: 16, color: primary, height: 1.6),
    bodyMedium:    GoogleFonts.dmSans(fontSize: 14, color: secondary, height: 1.5),
    labelLarge:    GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    labelMedium:   GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
  );

  static AppBarTheme _appBar(Color bg, Color fg) => AppBarTheme(
    backgroundColor: bg,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: fg),
    iconTheme: IconThemeData(color: fg),
  );

  static ElevatedButtonThemeData _elevatedBtn() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _inputDeco(Color fill, Color border, Color label) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: error)),
        labelStyle: GoogleFonts.dmSans(color: label),
        hintStyle: GoogleFonts.dmSans(color: label),
      );

  static CardTheme _card(Color color, Color border) => CardTheme(
    color: color,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: border),
    ),
  );

  static PageTransitionsTheme _transitions() => const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}