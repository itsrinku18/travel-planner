import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/features/wishlist/data/wishlist_repository_impl.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggle adds id and persists, second toggle removes it', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = WishlistRepositoryImpl(prefs: prefs);
    final cubit = WishlistCubit(repo: repo);

    await cubit.load();
    expect(cubit.state.ids, isEmpty);

    await cubit.toggle('goa');
    expect(cubit.state.contains('goa'), isTrue);

    final reloaded = WishlistCubit(repo: repo);
    await reloaded.load();
    expect(
      reloaded.state.contains('goa'),
      isTrue,
      reason: 'wishlist should persist across cubit instances',
    );

    await cubit.toggle('goa');
    expect(cubit.state.contains('goa'), isFalse);
    await cubit.close();
    await reloaded.close();
  });

  test('multiple ids can coexist', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = WishlistRepositoryImpl(prefs: prefs);
    final cubit = WishlistCubit(repo: repo);

    await cubit.load();
    await cubit.toggle('goa');
    await cubit.toggle('tokyo');
    await cubit.toggle('bali');

    expect(cubit.state.ids, containsAll({'goa', 'tokyo', 'bali'}));
    await cubit.close();
  });
}
