import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_colors.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/core/design/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.travelBlue,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.travelBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF0B1220),
    ).copyWith(
      secondary: AppColors.oceanTeal,
      tertiary: AppColors.sunsetGold,
      error: AppColors.error,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final brightness = scheme.brightness;
    final isDark = brightness == Brightness.dark;

    final radius = BorderRadius.circular(AppRadii.r20);

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme.copyWith(
        secondary: AppColors.oceanTeal,
        tertiary: AppColors.sunsetGold,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      useMaterial3: true,
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.r24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        filled: true,
        fillColor:
            isDark
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.35)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.8),
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.85 : 0.92),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    );
  }
}
