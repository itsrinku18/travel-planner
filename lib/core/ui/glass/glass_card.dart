import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_gradients.dart';
import 'package:travel_planner/core/design/app_radii.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppRadii.r20,
    this.blurSigma = 18,
    this.borderOpacity = 0.18,
    this.tintOpacity = 0.65,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final double borderOpacity;
  final double tintOpacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.subtleSurfaceTint(brightness),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: cs.onSurface.withValues(alpha: borderOpacity),
              width: 1,
            ),
          ),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: tintOpacity),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
