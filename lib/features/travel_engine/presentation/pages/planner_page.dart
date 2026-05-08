import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/trip_details_page.dart';
import 'package:travel_planner/features/travel_engine/presentation/sheets/create_trip_sheet.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Planner'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<TripsCubit>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateTripSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New trip'),
      ),
      body: BlocBuilder<TripsCubit, TripsState>(
        builder: (context, state) {
          if (state.isLoading && state.trips.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.trips.isEmpty) {
            return _PlannerEmpty(onCreate: () => showCreateTripSheet(context));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TripsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: state.trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _TripCard(trip: state.trips[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PlannerEmpty extends StatelessWidget {
  const _PlannerEmpty({required this.onCreate});
  final VoidCallback onCreate;

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
                Icons.flight_takeoff,
                color: cs.onPrimaryContainer,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Plan your first adventure',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a destination, set your dates and start building an itinerary.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create trip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM');
    final dateStr =
        '${fmt.format(trip.startDate)} → ${fmt.format(trip.endDate)}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.r20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TripDetailsPage(tripId: trip.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.r16),
                ),
                child: Icon(Icons.flight_takeoff, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: '${trip.totalDays} day(s)'),
                        _Chip(text: '${trip.activities.length} activity(ies)'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
