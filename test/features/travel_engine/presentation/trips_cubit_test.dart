import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/error/failure.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/add_activity_to_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/create_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/list_trips.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';

class _FakeRepo implements TravelEngineRepository {
  final List<Trip> _trips = [];
  bool failNextCreate = false;

  @override
  Future<Result<Trip>> addActivity({
    required String tripId,
    required Activity activity,
  }) async {
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx < 0) {
      return (
        data: null,
        failure: const ValidationFailure(message: 'Trip not found'),
      );
    }
    final updated = Trip(
      id: _trips[idx].id,
      destination: _trips[idx].destination,
      startDate: _trips[idx].startDate,
      endDate: _trips[idx].endDate,
      activities: [..._trips[idx].activities, activity],
    );
    _trips[idx] = updated;
    return (data: updated, failure: null);
  }

  @override
  Future<Result<Trip>> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (failNextCreate) {
      failNextCreate = false;
      return (data: null, failure: const ValidationFailure(message: 'nope'));
    }
    final trip = Trip(
      id: 'trip-${_trips.length + 1}',
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      activities: const [],
    );
    _trips.add(trip);
    return (data: trip, failure: null);
  }

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required Set<ActivityCategory> preferences,
  }) async => (data: const <Recommendation>[], failure: null);

  @override
  Future<Result<List<Trip>>> listTrips() async => (
    data: List<Trip>.unmodifiable(_trips),
    failure: null,
  );
}

void main() {
  late _FakeRepo repo;
  late TripsCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = TripsCubit(
      createTrip: CreateTrip(repo),
      listTrips: ListTrips(repo),
      addActivityToTrip: AddActivityToTrip(repo),
    );
  });

  tearDown(() async => cubit.close());

  test('initial state has no trips and is not loading', () {
    expect(cubit.state.trips, isEmpty);
    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
  });

  test('load() populates trips', () async {
    await repo.createTrip(
      destination: 'Goa',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
    );
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.trips, hasLength(1));
    expect(cubit.state.trips.first.destination, 'Goa');
  });

  test('create() success refreshes list', () async {
    await cubit.create(
      destination: 'Tokyo',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 6),
    );

    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.trips.map((t) => t.destination), contains('Tokyo'));
  });

  test(
    'create() failure surfaces errorMessage and keeps trips empty',
    () async {
      repo.failNextCreate = true;

      await cubit.create(
        destination: 'X',
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 6),
      );

      expect(cubit.state.errorMessage, 'nope');
      expect(cubit.state.trips, isEmpty);
    },
  );

  test('addActivity() appends activity and refreshes list', () async {
    await cubit.create(
      destination: 'Bali',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 4),
    );
    final tripId = cubit.state.trips.first.id;

    await cubit.addActivity(
      tripId: tripId,
      title: 'Surf lesson',
      category: ActivityCategory.adventure,
      startAt: DateTime(2026, 6, 1, 9, 0),
      durationMinutes: 90,
    );

    expect(cubit.state.errorMessage, isNull);
    final trip = cubit.byId(tripId)!;
    expect(trip.activities, hasLength(1));
    expect(trip.activities.first.title, 'Surf lesson');
  });

  test('byId returns null for unknown trip', () {
    expect(cubit.byId('missing'), isNull);
  });
}
