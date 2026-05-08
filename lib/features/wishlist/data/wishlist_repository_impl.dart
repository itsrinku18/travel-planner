import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/core/storage/prefs_keys.dart';
import 'package:travel_planner/features/wishlist/domain/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({required this.prefs});

  final SharedPreferences prefs;

  @override
  Future<Set<String>> load() async {
    final ids = prefs.getStringList(PrefsKeys.wishlist) ?? const <String>[];
    return ids.toSet();
  }

  @override
  Future<void> add(String destinationId) async {
    final current =
        await load()
          ..add(destinationId);
    await prefs.setStringList(PrefsKeys.wishlist, current.toList());
  }

  @override
  Future<void> remove(String destinationId) async {
    final current =
        await load()
          ..remove(destinationId);
    await prefs.setStringList(PrefsKeys.wishlist, current.toList());
  }

  @override
  Future<void> toggle(String destinationId) async {
    final current = await load();
    if (!current.add(destinationId)) {
      current.remove(destinationId);
    }
    await prefs.setStringList(PrefsKeys.wishlist, current.toList());
  }
}
