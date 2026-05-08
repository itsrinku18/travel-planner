import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';

class AddActivityToTrip implements UseCase<Trip, AddActivityParams> {
  const AddActivityToTrip(this._repo);
  final TravelEngineRepository _repo;

  @override
  Future<Result<Trip>> call(AddActivityParams params) {
    return _repo.addActivity(tripId: params.tripId, activity: params.activity);
  }
}

class AddActivityParams {
  const AddActivityParams({required this.tripId, required this.activity});
  final String tripId;
  final Activity activity;
}
