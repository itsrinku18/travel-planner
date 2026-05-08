import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/trip_details_page.dart';

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
        onPressed: () => _showCreateTripDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New trip'),
      ),
      body: BlocBuilder<TripsCubit, TripsState>(
        builder: (context, state) {
          if (state.isLoading && state.trips.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No trips yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first trip and start building an itinerary.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _showCreateTripDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create trip'),
                    ),
                  ],
                ),
              ),
            );
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

  Future<void> _showCreateTripDialog(BuildContext context) async {
    final destinationCtrl = TextEditingController();
    DateTimeRange? range;

    final created = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create trip'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: destinationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'e.g. Goa, Paris, Tokyo',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dates'),
                  subtitle: Text(
                    range == null
                        ? 'Pick start and end date'
                        : _formatRange(range!),
                  ),
                  trailing: const Icon(Icons.date_range_outlined),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                      initialDateRange: range,
                    );
                    if (picked != null) {
                      range = picked;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (range == null) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );

    if (created != true) return;
    if (range == null) return;
    if (!context.mounted) return;
    await context.read<TripsCubit>().create(
      destination: destinationCtrl.text,
      startDate: range!.start,
      endDate: range!.end,
    );
  }

  static String _formatRange(DateTimeRange r) {
    final fmt = DateFormat('d MMM yyyy');
    return '${fmt.format(r.start)} → ${fmt.format(r.end)}';
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM');
    final dateStr =
        '${fmt.format(trip.startDate)} → ${fmt.format(trip.endDate)}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flight_takeoff,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
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
