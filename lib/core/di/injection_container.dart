import 'package:get_it/get_it.dart';
import 'package:travel_planner/features/travel_engine/data/datasources/travel_engine_local_datasource.dart';
import 'package:travel_planner/features/travel_engine/data/repositories/travel_engine_repository_impl.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/add_activity_to_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/create_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/get_recommendations.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/list_trips.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Data sources
  sl.registerLazySingleton<TravelEngineLocalDataSource>(
    () => TravelEngineLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<TravelEngineRepository>(
    () => TravelEngineRepositoryImpl(local: sl()),
  );

  // Use cases
  sl
    ..registerLazySingleton(() => CreateTrip(sl()))
    ..registerLazySingleton(() => ListTrips(sl()))
    ..registerLazySingleton(() => AddActivityToTrip(sl()))
    ..registerLazySingleton(() => GetRecommendations(sl()));

  // Presentation
  sl
    ..registerFactory(
      () =>
          TripsCubit(createTrip: sl(), listTrips: sl(), addActivityToTrip: sl())
            ..load(),
    )
    ..registerFactory(() => ExperienceCubit(getRecommendations: sl())..load());
}
