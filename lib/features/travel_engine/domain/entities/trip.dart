import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.activities,
  });

  final String id;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<Activity> activities;

  int get totalDays => endDate.difference(startDate).inDays + 1;

  @override
  List<Object?> get props => [id, destination, startDate, endDate, activities];
}
