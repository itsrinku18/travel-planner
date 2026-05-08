import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/packing_item.dart';
import 'package:travel_planner/features/travel_engine/domain/trip_extras_repository.dart';

class TripExtrasState extends Equatable {
  const TripExtrasState({
    required this.tripId,
    required this.expenses,
    required this.packing,
  });

  final String? tripId;
  final List<Expense> expenses;
  final List<PackingItem> packing;

  static const initial = TripExtrasState(
    tripId: null,
    expenses: [],
    packing: [],
  );

  double get totalSpent => expenses.fold(0, (s, e) => s + e.amount);

  Map<ExpenseCategory, double> get spentByCategory {
    final map = <ExpenseCategory, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  int get packedCount => packing.where((p) => p.checked).length;

  TripExtrasState copyWith({
    String? tripId,
    List<Expense>? expenses,
    List<PackingItem>? packing,
  }) => TripExtrasState(
    tripId: tripId ?? this.tripId,
    expenses: expenses ?? this.expenses,
    packing: packing ?? this.packing,
  );

  @override
  List<Object?> get props => [tripId, expenses, packing];
}

class TripExtrasCubit extends Cubit<TripExtrasState> {
  TripExtrasCubit({required TripExtrasRepository repo})
    : _repo = repo,
      super(TripExtrasState.initial);

  final TripExtrasRepository _repo;
  final _uuid = const Uuid();

  Future<void> loadFor(String tripId) async {
    final expenses = await _repo.listExpenses(tripId);
    final packing = await _repo.listPacking(tripId);
    if (isClosed) return;
    emit(state.copyWith(tripId: tripId, expenses: expenses, packing: packing));
  }

  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required ExpenseCategory category,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? 'Expense' : title.trim(),
      amount: amount,
      category: category,
      createdAt: DateTime.now(),
    );
    await _repo.addExpense(tripId, expense);
    await loadFor(tripId);
  }

  Future<void> removeExpense({
    required String tripId,
    required String expenseId,
  }) async {
    await _repo.removeExpense(tripId, expenseId);
    await loadFor(tripId);
  }

  Future<void> addPackingItem({
    required String tripId,
    required String label,
  }) async {
    if (label.trim().isEmpty) return;
    await _repo.addPackingItem(
      tripId,
      PackingItem(id: _uuid.v4(), label: label.trim(), checked: false),
    );
    await loadFor(tripId);
  }

  Future<void> togglePackingItem({
    required String tripId,
    required String itemId,
  }) async {
    await _repo.togglePackingItem(tripId, itemId);
    await loadFor(tripId);
  }

  Future<void> removePackingItem({
    required String tripId,
    required String itemId,
  }) async {
    await _repo.removePackingItem(tripId, itemId);
    await loadFor(tripId);
  }
}
