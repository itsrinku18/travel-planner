import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/packing_item.dart';
import 'package:travel_planner/features/travel_engine/domain/trip_extras_repository.dart';

/// In-memory store for per-trip extras (budget & packing).
/// Keeps things simple: rehydrates per-session, so itineraries persist
/// only inside the running app. Easy to swap for shared_preferences/json
/// without changing call-sites.
class InMemoryTripExtrasRepository implements TripExtrasRepository {
  final Map<String, List<Expense>> _expenses = {};
  final Map<String, List<PackingItem>> _packing = {};

  @override
  Future<void> addExpense(String tripId, Expense expense) async {
    _expenses.putIfAbsent(tripId, () => []).add(expense);
  }

  @override
  Future<void> removeExpense(String tripId, String expenseId) async {
    _expenses[tripId]?.removeWhere((e) => e.id == expenseId);
  }

  @override
  Future<List<Expense>> listExpenses(String tripId) async {
    final list = List<Expense>.from(_expenses[tripId] ?? const []);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> addPackingItem(String tripId, PackingItem item) async {
    _packing.putIfAbsent(tripId, () => []).add(item);
  }

  @override
  Future<List<PackingItem>> listPacking(String tripId) async {
    return List<PackingItem>.from(_packing[tripId] ?? const []);
  }

  @override
  Future<void> removePackingItem(String tripId, String itemId) async {
    _packing[tripId]?.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<void> togglePackingItem(String tripId, String itemId) async {
    final list = _packing[tripId];
    if (list == null) return;
    final idx = list.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    list[idx] = list[idx].copyWith(checked: !list[idx].checked);
  }
}
