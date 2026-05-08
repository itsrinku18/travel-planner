import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/presentation/pages/destination_details_page.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({super.key, required this.destination, this.onTap});

  final Destination destination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.r24),
      onTap:
          onTap ??
          () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (_, __, ___) =>
                        DestinationDetailsPage(destination: destination),
                transitionsBuilder:
                    (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
              ),
            );
          },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.r24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'destination-${destination.id}',
              child: _HeroImage(url: destination.heroImageUrl),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    cs.scrim.withValues(alpha: 0.78),
                  ],
                  stops: const [0.42, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, w) {
                  final saved = w.contains(destination.id);
                  return Material(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap:
                          () => context.read<WishlistCubit>().toggle(
                            destination.id,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          color: saved ? Colors.redAccent : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _CardContent(destination: destination),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            color: cs.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              color: cs.onSurface.withValues(alpha: 0.45),
              size: 40,
            ),
          ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(cs.primary),
          ),
        );
      },
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.destination});
  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Text(
                destination.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    destination.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          destination.country,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              destination.tags.take(3).map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    t,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
