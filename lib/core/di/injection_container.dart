import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/features/discovery/data/datasources/discovery_local_datasource.dart';
import 'package:travel_planner/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:travel_planner/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_cubit.dart';
import 'package:travel_planner/features/settings/presentation/settings_cubit.dart';
import 'package:travel_planner/features/travel_engine/data/datasources/travel_engine_local_datasource.dart';
import 'package:travel_planner/features/travel_engine/data/repositories/travel_engine_repository_impl.dart';
import 'package:travel_planner/features/travel_engine/data/trip_extras_repository_impl.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';
import 'package:travel_planner/features/travel_engine/domain/trip_extras_repository.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/add_activity_to_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/create_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/get_recommendations.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/list_trips.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trip_extras_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/wishlist/data/wishlist_repository_impl.dart';
import 'package:travel_planner/features/wishlist/domain/wishlist_repository.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Platform / shared
  if (!sl.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(prefs);
  }

  // Settings — awaited so onboarding flag is hydrated before first frame.
  if (!sl.isRegistered<SettingsCubit>()) {
    final settings = SettingsCubit(prefs: sl());
    await settings.load();
    sl.registerSingleton<SettingsCubit>(settings);
  }

  // Wishlist
  sl
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(prefs: sl()),
    )
    ..registerLazySingleton(() => WishlistCubit(repo: sl())..load());

  // Discovery
  sl
    ..registerLazySingleton<DiscoveryLocalDataSource>(
      () => DiscoveryLocalDataSourceImpl(),
    )
    ..registerLazySingleton<DiscoveryRepository>(
      () => DiscoveryRepositoryImpl(local: sl()),
    )
    ..registerLazySingleton(() => DiscoveryCubit(repo: sl())..load());

  // Travel engine
  sl
    ..registerLazySingleton<TravelEngineLocalDataSource>(
      () => TravelEngineLocalDataSourceImpl(),
    )
    ..registerLazySingleton<TravelEngineRepository>(
      () => TravelEngineRepositoryImpl(local: sl()),
    )
    ..registerLazySingleton<TripExtrasRepository>(
      () => InMemoryTripExtrasRepository(),
    );

  sl
    ..registerLazySingleton(() => CreateTrip(sl()))
    ..registerLazySingleton(() => ListTrips(sl()))
    ..registerLazySingleton(() => AddActivityToTrip(sl()))
    ..registerLazySingleton(() => GetRecommendations(sl()));

  sl
    ..registerLazySingleton(
      () =>
          TripsCubit(createTrip: sl(), listTrips: sl(), addActivityToTrip: sl())
            ..load(),
    )
    ..registerLazySingleton(
      () => ExperienceCubit(getRecommendations: sl())..load(),
    )
    ..registerLazySingleton(() => TripExtrasCubit(repo: sl()));
}
