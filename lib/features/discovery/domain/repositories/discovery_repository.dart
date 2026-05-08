import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';

abstract interface class DiscoveryRepository {
  Future<Result<List<Destination>>> trending();
  Future<Result<List<Destination>>> recommended();
  Future<Result<List<Destination>>> search(String query);
  Future<Result<Destination?>> byId(String id);
  Future<Result<List<Destination>>> byCategory(DestinationCategory category);
}
