import 'package:uuid/uuid.dart';
import 'package:travel_planner/features/travel_engine/data/models/activity_model.dart';
import 'package:travel_planner/features/travel_engine/data/models/recommendation_model.dart';
import 'package:travel_planner/features/travel_engine/data/models/trip_model.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

abstract interface class TravelEngineLocalDataSource {
  Future<List<TripModel>> listTrips();
  Future<TripModel> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<TripModel> addActivity({
    required String tripId,
    required ActivityModel activity,
  });
  Future<List<RecommendationModel>> getRecommendations({
    required Set<ActivityCategory> preferences,
  });
}

class TravelEngineLocalDataSourceImpl implements TravelEngineLocalDataSource {
  TravelEngineLocalDataSourceImpl() {
    final now = DateTime.now();
    final seedTrip = TripModel(
      id: const Uuid().v4(),
      destination: 'Goa',
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day + 2),
      activities: const [],
    );
    _trips.add(seedTrip);
  }

  final _uuid = const Uuid();
  final List<TripModel> _trips = [];

  @override
  Future<List<TripModel>> listTrips() async {
    _trips.sort((a, b) => b.startDate.compareTo(a.startDate));
    return List<TripModel>.unmodifiable(_trips);
  }

  @override
  Future<TripModel> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final trip = TripModel(
      id: _uuid.v4(),
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      activities: const [],
    );
    _trips.add(trip);
    return trip;
  }

  @override
  Future<TripModel> addActivity({
    required String tripId,
    required ActivityModel activity,
  }) async {
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx < 0) {
      throw StateError('Trip not found');
    }
    final trip = _trips[idx];
    final updated = trip.copyWith(
      activities: [...trip.activityModels, activity],
    );
    _trips[idx] = updated;
    return updated;
  }

  @override
  Future<List<RecommendationModel>> getRecommendations({
    required Set<ActivityCategory> preferences,
  }) async {
    final wants =
        preferences.isEmpty ? ActivityCategory.values.toSet() : preferences;

    final all = <RecommendationModel>[
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Sunrise viewpoint walk',
        category: ActivityCategory.nature,
        reason: 'Great light and calm crowds in the morning.',
        estimatedMinutes: 90,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Local street food trail',
        category: ActivityCategory.food,
        reason: 'Taste the region with low-cost small plates.',
        estimatedMinutes: 120,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Heritage museum + old town',
        category: ActivityCategory.culture,
        reason: 'Quick context to make the rest of the trip richer.',
        estimatedMinutes: 150,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Kayak in backwaters / lake',
        category: ActivityCategory.adventure,
        reason: 'Active but beginner-friendly with guided options.',
        estimatedMinutes: 120,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Beach sunset + unwind',
        category: ActivityCategory.relax,
        reason: 'A buffer activity that reduces schedule stress.',
        estimatedMinutes: 75,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'Handicraft market browse',
        category: ActivityCategory.shopping,
        reason: 'Pick gifts and souvenirs without pressure.',
        estimatedMinutes: 60,
      ),
      RecommendationModel(
        id: _uuid.v4(),
        title: 'City highlights photo loop',
        category: ActivityCategory.sightseeing,
        reason: 'Efficient route hitting the iconic spots.',
        estimatedMinutes: 140,
      ),
    ];

    final filtered = all.where((r) => wants.contains(r.category)).toList();
    return filtered;
  }
}
