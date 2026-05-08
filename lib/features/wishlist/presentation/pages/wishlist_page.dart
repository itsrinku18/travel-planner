import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_cubit.dart';
import 'package:travel_planner/features/discovery/presentation/ui/destination_card.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, w) {
          if (w.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (w.ids.isEmpty) {
            return const _EmptyWishlist();
          }
          final all = context.select<DiscoveryCubit, List<Destination>>(
            (c) => c.state.recommended,
          );
          final saved = all.where((d) => w.ids.contains(d.id)).toList();

          if (saved.isEmpty) {
            return const _EmptyWishlist();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: saved.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, i) => SizedBox(
                  height: 160,
                  child: DestinationCard(destination: saved[i]),
                ),
          );
        },
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                color: cs.onPrimaryContainer,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Your wishlist is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart on any destination card to save it for later.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
