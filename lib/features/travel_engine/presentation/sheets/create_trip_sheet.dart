import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';

Future<void> showCreateTripSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CreateTripSheet(),
  );
}

class _CreateTripSheet extends StatefulWidget {
  const _CreateTripSheet();

  @override
  State<_CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends State<_CreateTripSheet> {
  final _destinationCtrl = TextEditingController();
  DateTimeRange? _range;

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _range,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _range = picked);
  }

  Future<void> _save() async {
    if (_destinationCtrl.text.trim().isEmpty || _range == null) return;
    await context.read<TripsCubit>().create(
      destination: _destinationCtrl.text,
      startDate: _range!.start,
      endDate: _range!.end,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New trip', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _destinationCtrl,
            decoration: const InputDecoration(
              labelText: 'Destination',
              hintText: 'e.g. Goa, Paris, Tokyo',
              prefixIcon: Icon(Icons.flight_takeoff_outlined),
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              _range == null
                  ? 'Pick start and end dates'
                  : '${fmt.format(_range!.start)} → ${fmt.format(_range!.end)}',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed:
                (_destinationCtrl.text.trim().isEmpty || _range == null)
                    ? null
                    : _save,
            icon: const Icon(Icons.check),
            label: const Text('Create trip'),
          ),
        ],
      ),
    );
  }
}
