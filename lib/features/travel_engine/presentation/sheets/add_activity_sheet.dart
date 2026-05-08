import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/ui/category_ui.dart';

Future<void> showAddActivitySheet(BuildContext context, Trip trip) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddActivitySheet(trip: trip),
  );
}

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet({required this.trip});
  final Trip trip;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _titleCtrl = TextEditingController();
  late ActivityCategory _category = ActivityCategory.sightseeing;
  late DateTime _startAt = DateTime(
    widget.trip.startDate.year,
    widget.trip.startDate.month,
    widget.trip.startDate.day,
    10,
  );
  int _durationMinutes = 90;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await context.read<TripsCubit>().addActivity(
      tripId: widget.trip.id,
      title: _titleCtrl.text,
      category: _category,
      startAt: _startAt,
      durationMinutes: _durationMinutes,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Add activity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Fort visit',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ActivityCategory>(
            value: _category,
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
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: widget.trip.startDate.subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: widget.trip.endDate.add(
                        const Duration(days: 1),
                      ),
                      initialDate: _startAt,
                    );
                    if (date == null) return;
                    if (!mounted) return;
                    setState(() {
                      _startAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _startAt.hour,
                        _startAt.minute,
                      );
                    });
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(DateFormat('d MMM yyyy').format(_startAt)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startAt),
                    );
                    if (time == null) return;
                    if (!mounted) return;
                    setState(() {
                      _startAt = DateTime(
                        _startAt.year,
                        _startAt.month,
                        _startAt.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: Text(DateFormat('h:mm a').format(_startAt)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Duration'),
              Expanded(
                child: Slider(
                  value: _durationMinutes.toDouble(),
                  min: 15,
                  max: 6 * 60,
                  divisions: 23,
                  label: '$_durationMinutes min',
                  onChanged:
                      (v) => setState(() => _durationMinutes = v.round()),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text('${_durationMinutes}m', textAlign: TextAlign.right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save activity'),
          ),
        ],
      ),
    );
  }
}
