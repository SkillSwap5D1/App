import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App colour palette - soft editorial theme
class AppColors {
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xD8FFFFFF);
  static const Color surfaceGlass = Color(0xE6FFFFFF);
  static const Color surfaceSolid = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF064E3B);

  static const Color accent = Color(0xFF064E3B);
  static const Color accentMedium = Color(0xFF0A6A50);
  static const Color accentLight = Color(0xFFE3F4E9);
  static const Color accentVeryLight = Color(0xFFF4FBF6);
  static const Color accentUltraLight = Color(0xFFF8FFFC);
  static const Color accentDeep = Color(0xFF6FA888);
  static const Color accentGlow = Color(0x33064E3B);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0x14064E3B);
  static const Color borderLight = Color(0x0F064E3B);
  static const Color borderActive = Color(0x99064E3B);

  static const Color success = Color(0xFF059669);
  // Pastel green for softer accents
  static const Color pastelGreen = Color(0xFFDCEFE2);
  static const Color pastelGreenDeep = Color(0xFF86B894);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0x1ADC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color surfaceWarm = Color(0xFFF7FFFC);
  static const Color heroBgTop = Color(0xFFF0FBF7);

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEAF4ED),
      Color(0xFFF5F0F8),
      Color(0xFFFDF0EC),
      Color(0xFFF8FAFC),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const Gradient editorialGradient = backgroundGradient;

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF064E3B), Color(0xFFBFE7FF)],
  );

  static BoxDecoration glassCard({double borderRadius = 24}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.90),
          Color(0xFFBFEFE8).withValues(alpha: 0.24),
          Color(0xFFD1FAE5).withValues(alpha: 0.18),
          Color(0xFFF9DCCB).withValues(alpha: 0.18),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF064E3B).withValues(alpha: 0.10),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 0,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }
}

/// App text styles - Light editorial typography
class AppTextStyles {
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
    double height = 1.0,
  }) {
    // Body text uses a clean sans-serif for readability
    return GoogleFonts.sourceSans3(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static final TextStyle h1 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final TextStyle h2 = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static final TextStyle h3 = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Override headings with a more elegant serif for a professional feel
  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get heading3 => GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static final TextStyle bodyLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static final TextStyle bodyMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle bodySmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static final TextStyle label = _base(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static final TextStyle caption = _base(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  static final TextStyle button = _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double full = 999.0;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14064E3B), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1A064E3B), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> hover = [
    BoxShadow(color: Color(0x26064E3B), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: GoogleFonts.sourceSans3().fontFamily,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentLight,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    // Use Source Sans 3 for body text, but map heading/textual display styles
    // to Playfair Display to ensure headings across the app pick up the serif.
    textTheme: (() {
      final base = GoogleFonts.sourceSans3TextTheme();
      final withHeadings = base.copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
      return withHeadings.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
    })(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.surfaceGlass,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: Color(0x33064E3B), width: 1),
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0x33064E3B), width: 1),
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xF2FFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      labelStyle: AppTextStyles.label.copyWith(fontSize: 13),
      prefixIconColor: AppColors.accentLight,
      suffixIconColor: AppColors.accentLight,
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppColors.error,
        fontSize: 12,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xD8FFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: Colors.white),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xE6FFFFFF),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.pastelGreen,
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.pastelGreenDeep,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x14064E3B),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0x14064E3B),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      actionTextColor: AppColors.pastelGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}
