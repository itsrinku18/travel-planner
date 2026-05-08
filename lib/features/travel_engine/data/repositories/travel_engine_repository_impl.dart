import 'package:travel_planner/core/error/failure.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/data/datasources/travel_engine_local_datasource.dart';
import 'package:travel_planner/features/travel_engine/data/models/activity_model.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';

class TravelEngineRepositoryImpl implements TravelEngineRepository {
  const TravelEngineRepositoryImpl({required this.local});
  final TravelEngineLocalDataSource local;

  @override
  Future<Result<Trip>> addActivity({
    required String tripId,
    required Activity activity,
  }) async {
    try {
      final updated = await local.addActivity(
        tripId: tripId,
        activity: ActivityModel.fromEntity(activity),
      );
      return (data: updated, failure: null);
    } on StateError catch (e) {
      return (data: null, failure: ValidationFailure(message: e.message));
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to add activity'),
      );
    }
  }

  @override
  Future<Result<Trip>> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (destination.trim().isEmpty) {
      return (
        data: null,
        failure: const ValidationFailure(message: 'Destination is required'),
      );
    }
    if (endDate.isBefore(startDate)) {
      return (
        data: null,
        failure: const ValidationFailure(
          message: 'End date must be after start date',
        ),
      );
    }
    try {
      final trip = await local.createTrip(
        destination: destination.trim(),
        startDate: startDate,
        endDate: endDate,
      );
      return (data: trip, failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to create trip'),
      );
    }
  }

  @override
  Future<Result<List<Recommendation>>> getRecommendations({
    required Set<ActivityCategory> preferences,
  }) async {
    try {
      final recs = await local.getRecommendations(preferences: preferences);
      return (data: recs, failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(
          message: 'Failed to load recommendations',
        ),
      );
    }
  }

  @override
  Future<Result<List<Trip>>> listTrips() async {
    try {
      final trips = await local.listTrips();
      return (data: trips, failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to load trips'),
      );
    }
  }
}
