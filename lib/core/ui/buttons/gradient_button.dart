import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_gradients.dart';
import 'package:travel_planner/core/design/app_radii.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.leading,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final Widget? leading;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    final scale = _pressed ? 0.98 : 1.0;
    final opacity = enabled ? 1.0 : 0.55;
    final gradient =
        brightness == Brightness.dark
            ? AppGradients.heroDark
            : AppGradients.hero;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.r20),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.r20),
                onTap: enabled ? widget.onPressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ] else if (widget.leading != null) ...[
                        IconTheme(
                          data: IconThemeData(color: cs.onPrimary),
                          child: widget.leading!,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
