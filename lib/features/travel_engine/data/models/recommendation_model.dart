import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.title,
    required super.category,
    required super.reason,
    required super.estimatedMinutes,
  });

  ActivityCategory get preference => category;
}
