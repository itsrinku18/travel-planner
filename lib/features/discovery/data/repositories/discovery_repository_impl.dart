import 'package:travel_planner/core/error/failure.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/discovery/data/datasources/discovery_local_datasource.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';
import 'package:travel_planner/features/discovery/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  const DiscoveryRepositoryImpl({required this.local});

  final DiscoveryLocalDataSource local;

  @override
  Future<Result<List<Destination>>> recommended() async {
    try {
      return (data: await local.recommended(), failure: null);
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
  Future<Result<List<Destination>>> search(String query) async {
    try {
      return (data: await local.search(query), failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Search failed'),
      );
    }
  }

  @override
  Future<Result<List<Destination>>> trending() async {
    try {
      return (data: await local.trending(), failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to load trending'),
      );
    }
  }

  @override
  Future<Result<Destination?>> byId(String id) async {
    try {
      return (data: await local.byId(id), failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to load place'),
      );
    }
  }

  @override
  Future<Result<List<Destination>>> byCategory(
    DestinationCategory category,
  ) async {
    try {
      return (data: await local.byCategory(category), failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const UnexpectedFailure(message: 'Failed to load category'),
      );
    }
  }
}
