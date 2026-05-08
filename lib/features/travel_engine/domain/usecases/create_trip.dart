import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/repositories/travel_engine_repository.dart';

class CreateTrip implements UseCase<Trip, CreateTripParams> {
  const CreateTrip(this._repo);
  final TravelEngineRepository _repo;

  @override
  Future<Result<Trip>> call(CreateTripParams params) {
    return _repo.createTrip(
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class CreateTripParams {
  const CreateTripParams({
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  final String destination;
  final DateTime startDate;
  final DateTime endDate;
}
