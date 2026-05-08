import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/packing_item.dart';

abstract interface class TripExtrasRepository {
  // Budget
  Future<List<Expense>> listExpenses(String tripId);
  Future<void> addExpense(String tripId, Expense expense);
  Future<void> removeExpense(String tripId, String expenseId);

  // Packing
  Future<List<PackingItem>> listPacking(String tripId);
  Future<void> addPackingItem(String tripId, PackingItem item);
  Future<void> togglePackingItem(String tripId, String itemId);
  Future<void> removePackingItem(String tripId, String itemId);
}
