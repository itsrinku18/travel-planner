import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';

class GetRecommendations
    implements UseCase<List<Recommendation>, GetRecommendationsParams> {
  const GetRecommendations(this._repo);
  final TravelEngineRepository _repo;

  @override
  Future<Result<List<Recommendation>>> call(GetRecommendationsParams params) {
    return _repo.getRecommendations(preferences: params.preferences);
  }
}

class GetRecommendationsParams {
  const GetRecommendationsParams({required this.preferences});
  final Set<ActivityCategory> preferences;
}
