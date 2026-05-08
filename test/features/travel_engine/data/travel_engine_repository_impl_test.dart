import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/error/failure.dart';
import 'package:travel_planner/features/travel_engine/data/datasources/travel_engine_local_datasource.dart';
import 'package:travel_planner/features/travel_engine/data/repositories/travel_engine_repository_impl.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

void main() {
  late TravelEngineRepositoryImpl repo;

  setUp(() {
    repo = TravelEngineRepositoryImpl(local: TravelEngineLocalDataSourceImpl());
  });

  group('createTrip', () {
    test('rejects empty destination with ValidationFailure', () async {
      final result = await repo.createTrip(
        destination: '   ',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      );

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure!.message, contains('Destination'));
    });

    test('rejects end date before start date', () async {
      final result = await repo.createTrip(
        destination: 'Goa',
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 5),
      );

      expect(result.failure, isA<ValidationFailure>());
    });

    test('trims destination and creates trip', () async {
      final result = await repo.createTrip(
        destination: '  Paris  ',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 7),
      );

      expect(result.failure, isNull);
      expect(result.data!.destination, 'Paris');
      expect(result.data!.totalDays, 7);
      expect(result.data!.activities, isEmpty);
    });
  });

  group('listTrips', () {
    test('returns seeded trip and is sorted by startDate desc', () async {
      await repo.createTrip(
        destination: 'Tokyo',
        startDate: DateTime(2030, 1, 1),
        endDate: DateTime(2030, 1, 3),
      );
      final result = await repo.listTrips();

      expect(result.failure, isNull);
      expect(result.data!.length, greaterThanOrEqualTo(2));
      // Newer trips come first.
      for (var i = 0; i < result.data!.length - 1; i++) {
        expect(
          result.data![i].startDate.isAfter(result.data![i + 1].startDate) ||
              result.data![i].startDate.isAtSameMomentAs(
                result.data![i + 1].startDate,
              ),
          isTrue,
        );
      }
    });
  });

  group('addActivity', () {
    test('appends activity to existing trip', () async {
      final create = await repo.createTrip(
        destination: 'Bali',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 3),
      );
      final tripId = create.data!.id;

      final activity = Activity(
        id: 'a1',
        title: 'Beach walk',
        category: ActivityCategory.relax,
        startAt: DateTime(2026, 6, 1, 17, 0),
        durationMinutes: 60,
      );
      final result = await repo.addActivity(tripId: tripId, activity: activity);

      expect(result.failure, isNull);
      expect(result.data!.activities, hasLength(1));
      expect(result.data!.activities.first.title, 'Beach walk');
    });

    test('returns ValidationFailure when trip is missing', () async {
      final activity = Activity(
        id: 'a1',
        title: 'Ghost activity',
        category: ActivityCategory.food,
        startAt: DateTime(2026, 6, 1, 12, 0),
        durationMinutes: 30,
      );

      final result = await repo.addActivity(
        tripId: 'does-not-exist',
        activity: activity,
      );

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
    });
  });

  group('getRecommendations', () {
    test('returns all categories when preferences empty', () async {
      final result = await repo.getRecommendations(preferences: const {});

      expect(result.failure, isNull);
      expect(result.data, isNotEmpty);
      // Seed contains one rec per category.
      final cats = result.data!.map((r) => r.category).toSet();
      expect(cats.length, ActivityCategory.values.length);
    });

    test('filters recommendations to selected categories only', () async {
      final result = await repo.getRecommendations(
        preferences: {ActivityCategory.food, ActivityCategory.nature},
      );

      expect(result.failure, isNull);
      expect(
        result.data!.every(
          (r) =>
              r.category == ActivityCategory.food ||
              r.category == ActivityCategory.nature,
        ),
        isTrue,
      );
      expect(result.data!.length, 2);
    });
  });
}
