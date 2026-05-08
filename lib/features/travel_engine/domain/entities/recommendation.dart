import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

class Recommendation extends Equatable {
  const Recommendation({
    required this.id,
    required this.title,
    required this.category,
    required this.reason,
    required this.estimatedMinutes,
  });

  final String id;
  final String title;
  final ActivityCategory category;
  final String reason;
  final int estimatedMinutes;

  @override
  List<Object?> get props => [id, title, category, reason, estimatedMinutes];
}
