import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App colour palette - Light glassmorphism theme
class AppColors {
  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xB3FFFFFF);
  static const Color surfaceGlass = Color(0xCCFFFFFF);
  static const Color surfaceSolid = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF7C3AED);

  static const Color accent = Color(0xFF7C3AED);
  static const Color accentMedium = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentVeryLight = Color(0xFFEDE9FE);
  static const Color accentUltraLight = Color(0xFFF5F3FF);
  static const Color accentDeep = Color(0xFF8B5CF6);
  static const Color accentGlow = Color(0x337C3AED);

  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0x1F7C3AED);
  static const Color borderLight = Color(0x0F7C3AED);
  static const Color borderActive = Color(0x997C3AED);

  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0x1ADC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color surfaceWarm = Color(0xFFF5F3FF);
  static const Color heroBgTop = Color(0xFFEDE9F6);

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEDE9F6),
      Color(0xFFF5F3FF),
      Color(0xFFEEF2FF),
      Color(0xFFFAF8FF),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const Gradient editorialGradient = backgroundGradient;

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
  );

  static BoxDecoration glassCard({double borderRadius = 24}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.65),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7C3AED).withOpacity(0.06),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
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
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static final TextStyle h1 = _base(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final TextStyle h2 = _base(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static final TextStyle h3 = _base(
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
    BoxShadow(
      color: Color(0x147C3AED),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x66FFFFFF),
      blurRadius: 0,
      offset: Offset(0, 0),
    ),
  ];
  
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1A7C3AED),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
  
  static const List<BoxShadow> hover = [
    BoxShadow(
      color: Color(0x267C3AED),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentLight,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.accentLight,
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.accentUltraLight,
        side: const BorderSide(color: Color(0x4D7C3AED), width: 1),
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xCCFFFFFF),
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
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 14),
      labelStyle: AppTextStyles.label.copyWith(fontSize: 13),
      prefixIconColor: AppColors.accentLight,
      suffixIconColor: AppColors.accentLight,
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error, fontSize: 12),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xB3FFFFFF),
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
      backgroundColor: AppColors.accentVeryLight,
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x147C3AED),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      actionTextColor: AppColors.accentLight,
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

