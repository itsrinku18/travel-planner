import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/design/app_gradients.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/core/ui/glass/glass_card.dart';
import 'package:travel_planner/core/ui/loading/skeleton.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_cubit.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_state.dart';
import 'package:travel_planner/features/discovery/presentation/ui/destination_card.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 232,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppGradients.heroDark
                          : AppGradients.hero,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover your next trip',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Premium destinations, experiences, and AI-made itineraries.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const Spacer(),
                        _SearchBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 0, 6),
              child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                buildWhen: (a, b) => a.category != b.category,
                builder: (context, state) {
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      itemCount: DestinationCategory.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final c = DestinationCategory.values[i];
                        final selected = state.category == c;
                        return ChoiceChip(
                          selected: selected,
                          onSelected:
                              (_) =>
                                  context.read<DiscoveryCubit>().setCategory(c),
                          avatar: Icon(c.icon, size: 16),
                          label: Text(c.label),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                builder: (context, state) {
                  if (state.isLoading &&
                      state.trending.isEmpty &&
                      state.recommended.isEmpty) {
                    return _DiscoverySkeleton();
                  }
                  if (state.errorMessage != null) {
                    return GlassCard(
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline),
                          const SizedBox(width: 10),
                          Expanded(child: Text(state.errorMessage!)),
                          TextButton(
                            onPressed:
                                () => context.read<DiscoveryCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final showSearch = state.query.trim().isNotEmpty;
                  final list =
                      showSearch
                          ? state.searchResults
                          : (state.category == DestinationCategory.all
                              ? state.trending
                              : state.categoryResults);
                  final headerTitle =
                      showSearch
                          ? 'Search results'
                          : (state.category == DestinationCategory.all
                              ? 'Trending now'
                              : state.category.label);
                  final headerSubtitle =
                      showSearch
                          ? '${list.length} places'
                          : 'Handpicked for you';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: headerTitle,
                        subtitle: headerSubtitle,
                      ),
                      const SizedBox(height: 10),
                      if (list.isEmpty)
                        const _EmptyState(
                          icon: Icons.search_off,
                          message: 'No matches yet — try a different filter.',
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              return SizedBox(
                                width: 300,
                                child: DestinationCard(destination: list[i]),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 18),
                      const _SectionHeader(
                        title: 'Recommended trips',
                        subtitle: 'Shortlist-worthy, premium vibes',
                      ),
                      const SizedBox(height: 10),
                      ...state.recommended.take(3).map((d) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            height: 160,
                            child: DestinationCard(destination: d),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      GlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.r16,
                                ),
                                gradient:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppGradients.heroDark
                                        : AppGradients.hero,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Trip Planner',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Generate a complete itinerary in minutes.',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Open'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: AppRadii.r24,
      blurSigma: 16,
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => context.read<DiscoveryCubit>().setQuery(v),
              decoration: const InputDecoration(
                hintText: 'Search destinations, experiences, yatras…',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filters (coming soon)',
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.r20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DiscoverySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Skeleton(height: 22, width: 200, borderRadius: AppRadii.r16),
        SizedBox(height: 6),
        Skeleton(height: 14, width: 260, borderRadius: AppRadii.r16),
        SizedBox(height: 12),
        _SkeletonRow(),
        SizedBox(height: 18),
        Skeleton(height: 22, width: 220, borderRadius: AppRadii.r16),
        SizedBox(height: 10),
        Skeleton(height: 140, borderRadius: AppRadii.r24),
        SizedBox(height: 12),
        Skeleton(height: 140, borderRadius: AppRadii.r24),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        children: const [
          Expanded(child: Skeleton(height: 220, borderRadius: AppRadii.r24)),
          SizedBox(width: 12),
          Expanded(child: Skeleton(height: 220, borderRadius: AppRadii.r24)),
        ],
      ),
    );
  }
}
