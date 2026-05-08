import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/design/app_gradients.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/core/ui/buttons/gradient_button.dart';
import 'package:travel_planner/features/settings/presentation/settings_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = <_Slide>[
    _Slide(
      icon: Icons.travel_explore,
      title: 'Discover places you’ll love',
      subtitle:
          'Trending destinations, curated experiences, and AI ideas — all in one place.',
    ),
    _Slide(
      icon: Icons.event_available_outlined,
      title: 'Plan day by day',
      subtitle:
          'Build itineraries, track budget, and organize a packing list before you fly.',
    ),
    _Slide(
      icon: Icons.auto_awesome,
      title: 'Tailor to your vibe',
      subtitle:
          'Tell us what you enjoy and we’ll recommend activities that fit your style.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SettingsCubit>().markOnboardingDone();
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: active ? 22 : 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: active ? 1 : 0.5),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (_index > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => _controller.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        label:
                            _index == _slides.length - 1
                                ? 'Get started'
                                : 'Next',
                        leading: const Icon(Icons.arrow_forward, size: 18),
                        onPressed: () {
                          if (_index == _slides.length - 1) {
                            _finish();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: Icon(slide.icon, size: 70, color: Colors.white),
        ),
        const SizedBox(height: 28),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          slide.subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ],
    );
  }
}
