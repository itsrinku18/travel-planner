import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/core/ui/buttons/gradient_button.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';

class DestinationDetailsPage extends StatelessWidget {
  const DestinationDetailsPage({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, w) {
                  final saved = w.contains(destination.id);
                  return IconButton(
                    tooltip:
                        saved ? 'Remove from wishlist' : 'Save to wishlist',
                    onPressed:
                        () => context.read<WishlistCubit>().toggle(
                          destination.id,
                        ),
                    icon: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      color: saved ? Colors.redAccent : Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                destination.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Hero(
                tag: 'destination-${destination.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      destination.heroImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              Container(color: cs.surfaceContainerHighest),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                          stops: [0.55, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      destination.country,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text(destination.rating.toStringAsFixed(1)),
                    const SizedBox(width: 12),
                    _Pill(
                      icon: Icons.payments_outlined,
                      label: destination.priceLevel.symbol,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (destination.summary.isNotEmpty)
                  Text(
                    destination.summary,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 18),
                if (destination.bestSeason.isNotEmpty)
                  _InfoRow(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Best season',
                    value: destination.bestSeason,
                  ),
                _InfoRow(
                  icon: Icons.payments_outlined,
                  title: 'Budget level',
                  value: destination.priceLevel.label,
                ),
                _InfoRow(
                  icon: Icons.label_outline,
                  title: 'Tags',
                  value: destination.tags.join(' • '),
                ),
                const SizedBox(height: 18),
                Text(
                  'Highlights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      destination.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: cs.primaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Plan a trip here',
                        leading: const Icon(Icons.add, size: 18),
                        onPressed: () async {
                          final now = DateTime.now();
                          await context.read<TripsCubit>().create(
                            destination: destination.name,
                            startDate: now,
                            endDate: now.add(const Duration(days: 4)),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Trip to ${destination.name} created',
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
