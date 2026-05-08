import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.title,
    required this.category,
    required this.startAt,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final ActivityCategory category;
  final DateTime startAt;
  final int durationMinutes;

  DateTime get endAt => startAt.add(Duration(minutes: durationMinutes));

  @override
  List<Object?> get props => [id, title, category, startAt, durationMinutes];
}

enum ActivityCategory {
  sightseeing,
  food,
  nature,
  adventure,
  culture,
  shopping,
  relax,
}
