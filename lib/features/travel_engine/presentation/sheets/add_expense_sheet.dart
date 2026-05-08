import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trip_extras_cubit.dart';

Future<void> showAddExpenseSheet(
  BuildContext context, {
  required String tripId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddExpenseSheet(tripId: tripId),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet({required this.tripId});
  final String tripId;

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;
    await context.read<TripExtrasCubit>().addExpense(
      tripId: widget.tripId,
      title: _titleCtrl.text,
      amount: amount,
      category: _category,
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
          Text('Add expense', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'What was it?',
              hintText: 'e.g. Train ticket',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExpenseCategory>(
            value: _category,
            items:
                ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem(value: c, child: Text(_label(c))),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save expense'),
          ),
        ],
      ),
    );
  }

  String _label(ExpenseCategory c) => switch (c) {
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.stay => 'Stay',
    ExpenseCategory.food => 'Food',
    ExpenseCategory.activities => 'Activities',
    ExpenseCategory.shopping => 'Shopping',
    ExpenseCategory.other => 'Other',
  };
}
