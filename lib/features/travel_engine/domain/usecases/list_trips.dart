import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';

class ListTrips implements UseCase<List<Trip>, NoParams> {
  const ListTrips(this._repo);
  final TravelEngineRepository _repo;

  @override
  Future<Result<List<Trip>>> call(NoParams params) => _repo.listTrips();
}
