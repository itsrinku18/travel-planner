import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trip_extras_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/sheets/add_activity_sheet.dart';
import 'package:travel_planner/features/travel_engine/presentation/sheets/add_expense_sheet.dart';
import 'package:travel_planner/features/travel_engine/presentation/ui/category_ui.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key, required this.tripId});
  final String tripId;

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripExtrasCubit>().loadFor(widget.tripId);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.select<TripsCubit, Trip?>(
      (c) => c.byId(widget.tripId),
    );

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip')),
        body: const Center(child: Text('Trip not found')),
      );
    }

    final fmt = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.destination),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Itinerary'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Budget'),
            Tab(icon: Icon(Icons.checklist_rtl), text: 'Packing'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share trip summary',
            onPressed: () => _copyShareSummary(context, trip),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (context, _) {
          switch (_tabs.index) {
            case 0:
              return FloatingActionButton.extended(
                heroTag: 'fab-activity',
                onPressed: () => showAddActivitySheet(context, trip),
                icon: const Icon(Icons.add),
                label: const Text('Activity'),
              );
            case 1:
              return FloatingActionButton.extended(
                heroTag: 'fab-expense',
                onPressed: () => showAddExpenseSheet(context, tripId: trip.id),
                icon: const Icon(Icons.add),
                label: const Text('Expense'),
              );
            default:
              return FloatingActionButton.extended(
                heroTag: 'fab-pack',
                onPressed: () => _showAddPackingItem(context, trip.id),
                icon: const Icon(Icons.add),
                label: const Text('Item'),
              );
          }
        },
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ItineraryTab(trip: trip, fmt: fmt),
          _BudgetTab(tripId: trip.id),
          _PackingTab(tripId: trip.id),
        ],
      ),
    );
  }

  Future<void> _showAddPackingItem(BuildContext context, String tripId) async {
    final controller = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Add packing item'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  hintText: 'e.g. Sunscreen, Passport',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add'),
                ),
              ],
            ),
      );
      if (ok != true) return;
      if (!context.mounted) return;
      await context.read<TripExtrasCubit>().addPackingItem(
        tripId: tripId,
        label: controller.text,
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _copyShareSummary(BuildContext context, Trip trip) async {
    final fmt = DateFormat('d MMM yyyy');
    final lines = <String>[
      '✈ Trip to ${trip.destination}',
      '${fmt.format(trip.startDate)} → ${fmt.format(trip.endDate)} '
          '(${trip.totalDays} day${trip.totalDays == 1 ? '' : 's'})',
      '',
      'Itinerary:',
      ...(trip.activities.toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt)))
          .map(
            (a) =>
                '  • ${DateFormat('d MMM, h:mm a').format(a.startAt)} — ${a.title} (${CategoryUi.label(a.category)})',
          ),
    ];
    if (trip.activities.isEmpty) lines.add('  (no activities yet)');
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip summary copied to clipboard')),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.trip, required this.fmt});
  final Trip trip;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    final byDay = <DateTime, List<Activity>>{};
    for (final a in trip.activities) {
      final key = DateTime(a.startAt.year, a.startAt.month, a.startAt.day);
      byDay.putIfAbsent(key, () => []).add(a);
    }
    final days = byDay.keys.toList()..sort();
    for (final d in days) {
      byDay[d]!.sort((a, b) => a.startAt.compareTo(b.startAt));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip overview',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${fmt.format(trip.startDate)} → ${fmt.format(trip.endDate)}',
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.totalDays} day(s) · ${trip.activities.length} activity(ies)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (days.isEmpty)
          const _EmptyActivities()
        else
          ...days.map((day) => _DayBlock(day: day, activities: byDay[day]!)),
      ],
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({required this.day, required this.activities});
  final DateTime day;
  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dayLabel = DateFormat('EEE, d MMM').format(day);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              dayLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...activities.map((a) => _TimelineTile(activity: a)),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = DateFormat('h:mm a').format(activity.startAt);
    final end = DateFormat('h:mm a').format(activity.endAt);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(time, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
              ),
              Expanded(child: Container(width: 2, color: cs.outlineVariant)),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(CategoryUi.icon(activity.category)),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(
                    '${CategoryUi.label(activity.category)} • $time → $end',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.r20),
      ),
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
            'Add activities with a time and category. The engine groups them by day.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BudgetTab extends StatelessWidget {
  const _BudgetTab({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripExtrasCubit, TripExtrasState>(
      builder: (context, s) {
        if (s.tripId != tripId) {
          return const Center(child: CircularProgressIndicator());
        }
        final byCat = s.spentByCategory;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total spent',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${s.totalSpent.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          byCat.entries.map((e) {
                            return Chip(
                              avatar: Icon(_categoryIcon(e.key), size: 16),
                              label: Text(
                                '${_categoryLabel(e.key)} • \$${e.value.toStringAsFixed(0)}',
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (s.expenses.isEmpty)
              const _EmptyExpenses()
            else
              ...s.expenses.map(
                (e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_categoryIcon(e.category)),
                    ),
                    title: Text(e.title),
                    subtitle: Text(
                      '${_categoryLabel(e.category)} • ${DateFormat('d MMM, h:mm a').format(e.createdAt)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${e.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed:
                              () =>
                                  context.read<TripExtrasCubit>().removeExpense(
                                    tripId: tripId,
                                    expenseId: e.id,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

IconData _categoryIcon(ExpenseCategory c) => switch (c) {
  ExpenseCategory.transport => Icons.directions_bus_outlined,
  ExpenseCategory.stay => Icons.hotel_outlined,
  ExpenseCategory.food => Icons.restaurant_outlined,
  ExpenseCategory.activities => Icons.local_activity_outlined,
  ExpenseCategory.shopping => Icons.shopping_bag_outlined,
  ExpenseCategory.other => Icons.more_horiz,
};

String _categoryLabel(ExpenseCategory c) => switch (c) {
  ExpenseCategory.transport => 'Transport',
  ExpenseCategory.stay => 'Stay',
  ExpenseCategory.food => 'Food',
  ExpenseCategory.activities => 'Activities',
  ExpenseCategory.shopping => 'Shopping',
  ExpenseCategory.other => 'Other',
};

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.r20),
      ),
      child: Column(
        children: [
          Icon(Icons.payments_outlined, size: 40, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Track your trip spend by category and stay on budget.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PackingTab extends StatelessWidget {
  const _PackingTab({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripExtrasCubit, TripExtrasState>(
      builder: (context, s) {
        if (s.tripId != tripId) {
          return const Center(child: CircularProgressIndicator());
        }
        final progress =
            s.packing.isEmpty ? 0.0 : s.packedCount / s.packing.length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packing progress',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.packedCount} / ${s.packing.length} packed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (s.packing.isEmpty)
              const _EmptyPacking()
            else
              ...s.packing.map(
                (i) => Card(
                  child: CheckboxListTile(
                    value: i.checked,
                    onChanged:
                        (_) => context
                            .read<TripExtrasCubit>()
                            .togglePackingItem(tripId: tripId, itemId: i.id),
                    title: Text(
                      i.label,
                      style: TextStyle(
                        decoration:
                            i.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed:
                          () => context
                              .read<TripExtrasCubit>()
                              .removePackingItem(tripId: tripId, itemId: i.id),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyPacking extends StatelessWidget {
  const _EmptyPacking();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.r20),
      ),
      child: Column(
        children: [
          Icon(Icons.checklist_rtl, size: 40, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            'Build your packing list',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Add items so nothing is forgotten on the day of departure.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
