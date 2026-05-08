import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/ui/category_ui.dart';

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context) {
    final trip = context.select<TripsCubit, Trip?>((c) => c.byId(tripId));

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip')),
        body: const Center(child: Text('Trip not found')),
      );
    }

    final fmt = DateFormat('d MMM yyyy');

    final activities = [...trip.activities]
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Scaffold(
      appBar: AppBar(title: Text(trip.destination)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(context, trip),
        icon: const Icon(Icons.add),
        label: const Text('Add activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dates', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    '${fmt.format(trip.startDate)} → ${fmt.format(trip.endDate)}',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Itinerary',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activities.isEmpty
                        ? 'No activities yet. Add your first activity to generate a simple day plan.'
                        : 'Activities sorted by start time.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const _EmptyActivities()
          else
            ...activities.map((a) => _ActivityTile(activity: a)),
        ],
      ),
    );
  }

  Future<void> _showAddActivityDialog(BuildContext context, Trip trip) async {
    final titleCtrl = TextEditingController();
    ActivityCategory category = ActivityCategory.sightseeing;
    DateTime startAt = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
      10,
      0,
    );
    int durationMinutes = 90;

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add activity'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g. Fort visit',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ActivityCategory>(
                        value: category,
                        items:
                            ActivityCategory.values
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Row(
                                      children: [
                                        Icon(CategoryUi.icon(c), size: 18),
                                        const SizedBox(width: 8),
                                        Text(CategoryUi.label(c)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (v) => setState(() => category = v ?? category),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Start time'),
                        subtitle: Text(
                          DateFormat('d MMM, h:mm a').format(startAt),
                        ),
                        trailing: const Icon(Icons.schedule),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startAt),
                          );
                          if (time == null) return;
                          setState(() {
                            startAt = DateTime(
                              startAt.year,
                              startAt.month,
                              startAt.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: durationMinutes.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed == null) return;
                          durationMinutes = parsed.clamp(15, 24 * 60);
                        },
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (saved != true) return;
    if (!context.mounted) return;
    await context.read<TripsCubit>().addActivity(
      tripId: trip.id,
      title: titleCtrl.text,
      category: category,
      startAt: startAt,
      durationMinutes: durationMinutes,
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(activity.startAt);
    final end = DateFormat('h:mm a').format(activity.endAt);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(CategoryUi.icon(activity.category))),
        title: Text(activity.title),
        subtitle: Text('${CategoryUi.label(activity.category)} • $time → $end'),
      ),
    );
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Start building your itinerary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Add activities with a time and category. The engine keeps them ordered so your day stays readable.',
          ),
        ],
      ),
    );
  }
}
