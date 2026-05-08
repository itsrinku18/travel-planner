import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B5FFF), Color(0xFF00C2A8)],
  );

  static const heroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A3FB0), Color(0xFF007B6B)],
  );

  static LinearGradient subtleSurfaceTint(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (isDark ? AppColors.glassTintDark : AppColors.glassTintLight),
        (isDark ? const Color(0x22000000) : const Color(0x55FFFFFF)),
      ],
    );
  }
}
