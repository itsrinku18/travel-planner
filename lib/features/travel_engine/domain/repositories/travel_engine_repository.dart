import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';

abstract interface class TravelEngineRepository {
  Future<Result<List<Trip>>> listTrips();
  Future<Result<Trip>> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<Trip>> addActivity({
    required String tripId,
    required Activity activity,
  });

  Future<Result<List<Recommendation>>> getRecommendations({
    required Set<ActivityCategory> preferences,
  });
}
