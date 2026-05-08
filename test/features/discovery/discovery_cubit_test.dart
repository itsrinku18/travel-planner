import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';
import 'package:travel_planner/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_cubit.dart';

const _alpha = Destination(
  id: 'a',
  name: 'Alpha',
  country: 'AA',
  heroImageUrl: '',
  tags: ['x'],
  rating: 4.0,
  priceLevel: PriceLevel.mid,
  categories: [DestinationCategory.city],
);

const _goa = Destination(
  id: 'goa',
  name: 'Goa',
  country: 'India',
  heroImageUrl: '',
  tags: ['Beaches'],
  rating: 4.6,
  priceLevel: PriceLevel.mid,
  categories: [DestinationCategory.beach],
);

const _trend = Destination(
  id: 't',
  name: 'Trend',
  country: 'TT',
  heroImageUrl: '',
  tags: [],
  rating: 4.5,
  priceLevel: PriceLevel.mid,
  categories: [DestinationCategory.city],
);

class _FakeRepo implements DiscoveryRepository {
  int searchCalls = 0;
  int categoryCalls = 0;

  @override
  Future<Result<List<Destination>>> recommended() async => (
    data: const [_alpha],
    failure: null,
  );

  @override
  Future<Result<List<Destination>>> search(String query) async {
    searchCalls++;
    final q = query.toLowerCase();
    final all = const [_goa];
    return (
      data:
          all
              .where(
                (d) =>
                    d.name.toLowerCase().contains(q) ||
                    d.tags.any((t) => t.toLowerCase().contains(q)),
              )
              .toList(),
      failure: null,
    );
  }

  @override
  Future<Result<List<Destination>>> trending() async => (
    data: const [_trend],
    failure: null,
  );

  @override
  Future<Result<Destination?>> byId(String id) async => (
    data:
        id == _goa.id
            ? _goa
            : id == _trend.id
            ? _trend
            : id == _alpha.id
            ? _alpha
            : null,
    failure: null,
  );

  @override
  Future<Result<List<Destination>>> byCategory(
    DestinationCategory category,
  ) async {
    categoryCalls++;
    final all = const [_alpha, _goa, _trend];
    if (category == DestinationCategory.all) return (data: all, failure: null);
    return (
      data: all.where((d) => d.categories.contains(category)).toList(),
      failure: null,
    );
  }
}

void main() {
  test(
    'load() populates trending, recommended, and category results',
    () async {
      final cubit = DiscoveryCubit(repo: _FakeRepo());

      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.trending, isNotEmpty);
      expect(cubit.state.recommended, isNotEmpty);
      expect(cubit.state.categoryResults, isNotEmpty);
      await cubit.close();
    },
  );

  test('setCategory filters category results', () async {
    final repo = _FakeRepo();
    final cubit = DiscoveryCubit(repo: repo);

    await cubit.setCategory(DestinationCategory.beach);

    expect(cubit.state.category, DestinationCategory.beach);
    expect(cubit.state.categoryResults.map((d) => d.id), contains('goa'));
    expect(cubit.state.categoryResults.every((d) => d.id == 'goa'), isTrue);
    await cubit.close();
  });

  test('setQuery debounces and runs search exactly once', () async {
    final repo = _FakeRepo();
    final cubit = DiscoveryCubit(repo: repo);

    cubit.setQuery('g');
    cubit.setQuery('go');
    cubit.setQuery('goa');

    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(repo.searchCalls, 1);
    expect(cubit.state.searchResults, isNotEmpty);
    expect(cubit.state.searchResults.first.name, 'Goa');
    await cubit.close();
  });

  test('empty query clears search results without calling repo', () async {
    final repo = _FakeRepo();
    final cubit = DiscoveryCubit(repo: repo);

    cubit.setQuery('   ');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(repo.searchCalls, 0);
    expect(cubit.state.searchResults, isEmpty);
    await cubit.close();
  });

  test('close before debounce fires does not throw', () async {
    final cubit = DiscoveryCubit(repo: _FakeRepo());
    cubit.setQuery('any');
    await cubit.close();

    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
}
