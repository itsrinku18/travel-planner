import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/get_recommendations.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';

class _FakeRepo implements TravelEngineRepository {
  Set<ActivityCategory>? lastPreferences;

  @override
  Future<Result<Trip>> addActivity({
    required String tripId,
    required Activity activity,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Trip>> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required Set<ActivityCategory> preferences,
  }) async {
    lastPreferences = preferences;
    final all =
        ActivityCategory.values
            .map(
              (c) => Recommendation(
                id: c.name,
                title: '${c.name} pick',
                category: c,
                reason: 'because ${c.name}',
                estimatedMinutes: 60,
              ),
            )
            .toList();
    final wants =
        preferences.isEmpty ? ActivityCategory.values.toSet() : preferences;
    return (
      data: all.where((r) => wants.contains(r.category)).toList(),
      failure: null,
    );
  }

  @override
  Future<Result<List<Trip>>> listTrips() async => throw UnimplementedError();
}

void main() {
  late _FakeRepo repo;
  late ExperienceCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = ExperienceCubit(getRecommendations: GetRecommendations(repo));
  });

  tearDown(() async => cubit.close());

  test('load() with no preferences returns all categories', () async {
    await cubit.load();

    expect(cubit.state.recommendations.length, ActivityCategory.values.length);
    expect(repo.lastPreferences, isEmpty);
  });

  test('togglePreference adds and reloads filtered recommendations', () async {
    await cubit.togglePreference(ActivityCategory.food);

    expect(cubit.state.preferences, {ActivityCategory.food});
    expect(cubit.state.recommendations.map((r) => r.category).toSet(), {
      ActivityCategory.food,
    });
  });

  test('togglePreference twice removes it', () async {
    await cubit.togglePreference(ActivityCategory.food);
    await cubit.togglePreference(ActivityCategory.food);

    expect(cubit.state.preferences, isEmpty);
  });

  test('clear() resets preferences and reloads', () async {
    await cubit.togglePreference(ActivityCategory.adventure);
    await cubit.togglePreference(ActivityCategory.nature);
    expect(cubit.state.preferences, hasLength(2));

    await cubit.clear();

    expect(cubit.state.preferences, isEmpty);
    expect(cubit.state.recommendations, isNotEmpty);
  });
}
