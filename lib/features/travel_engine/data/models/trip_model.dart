import 'package:travel_planner/features/travel_engine/data/models/activity_model.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.destination,
    required super.startDate,
    required super.endDate,
    required List<ActivityModel> activities,
  }) : super(activities: activities);

  List<ActivityModel> get activityModels =>
      activities.cast<ActivityModel>().toList(growable: false);

  TripModel copyWith({
    String? id,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<ActivityModel>? activities,
  }) {
    return TripModel(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      activities: activities ?? activityModels,
    );
  }
}
