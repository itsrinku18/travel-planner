import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.category,
    required super.startAt,
    required super.durationMinutes,
  });

  factory ActivityModel.fromEntity(Activity a) => ActivityModel(
    id: a.id,
    title: a.title,
    category: a.category,
    startAt: a.startAt,
    durationMinutes: a.durationMinutes,
  );
}
