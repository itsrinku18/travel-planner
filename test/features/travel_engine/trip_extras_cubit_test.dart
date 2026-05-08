import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/travel_engine/data/trip_extras_repository_impl.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/expense.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trip_extras_cubit.dart';

void main() {
  late TripExtrasCubit cubit;

  setUp(() {
    cubit = TripExtrasCubit(repo: InMemoryTripExtrasRepository());
  });

  tearDown(() async => cubit.close());

  group('budget', () {
    test('addExpense increases total and groups by category', () async {
      const tripId = 't1';
      await cubit.loadFor(tripId);

      await cubit.addExpense(
        tripId: tripId,
        title: 'Train',
        amount: 24,
        category: ExpenseCategory.transport,
      );
      await cubit.addExpense(
        tripId: tripId,
        title: 'Lunch',
        amount: 16,
        category: ExpenseCategory.food,
      );
      await cubit.addExpense(
        tripId: tripId,
        title: 'Coffee',
        amount: 4,
        category: ExpenseCategory.food,
      );

      expect(cubit.state.totalSpent, 44);
      expect(cubit.state.spentByCategory[ExpenseCategory.transport], 24);
      expect(cubit.state.spentByCategory[ExpenseCategory.food], 20);
    });

    test('removeExpense reduces total', () async {
      const tripId = 't1';
      await cubit.loadFor(tripId);
      await cubit.addExpense(
        tripId: tripId,
        title: 'Hotel',
        amount: 120,
        category: ExpenseCategory.stay,
      );
      final id = cubit.state.expenses.first.id;

      await cubit.removeExpense(tripId: tripId, expenseId: id);

      expect(cubit.state.expenses, isEmpty);
      expect(cubit.state.totalSpent, 0);
    });
  });

  group('packing', () {
    test('addPackingItem ignores empty labels', () async {
      const tripId = 't2';
      await cubit.loadFor(tripId);
      await cubit.addPackingItem(tripId: tripId, label: '   ');
      expect(cubit.state.packing, isEmpty);
    });

    test('toggle flips checked state and updates packed count', () async {
      const tripId = 't2';
      await cubit.loadFor(tripId);
      await cubit.addPackingItem(tripId: tripId, label: 'Passport');
      await cubit.addPackingItem(tripId: tripId, label: 'Sunscreen');
      expect(cubit.state.packedCount, 0);

      final firstId = cubit.state.packing.first.id;
      await cubit.togglePackingItem(tripId: tripId, itemId: firstId);

      expect(cubit.state.packedCount, 1);
      expect(
        cubit.state.packing.firstWhere((i) => i.id == firstId).checked,
        isTrue,
      );
    });

    test('removePackingItem removes by id', () async {
      const tripId = 't2';
      await cubit.loadFor(tripId);
      await cubit.addPackingItem(tripId: tripId, label: 'Headphones');
      final id = cubit.state.packing.first.id;
      await cubit.removePackingItem(tripId: tripId, itemId: id);

      expect(cubit.state.packing, isEmpty);
    });
  });
}
