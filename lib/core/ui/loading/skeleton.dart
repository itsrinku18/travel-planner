import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_radii.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = AppRadii.r16,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceContainerHighest.withValues(alpha: 0.55);
    final highlight = cs.onSurface.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
