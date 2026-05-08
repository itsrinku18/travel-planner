import 'package:flutter/material.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';

class CategoryUi {
  const CategoryUi._();

  static String label(ActivityCategory c) => switch (c) {
    ActivityCategory.sightseeing => 'Sightseeing',
    ActivityCategory.food => 'Food',
    ActivityCategory.nature => 'Nature',
    ActivityCategory.adventure => 'Adventure',
    ActivityCategory.culture => 'Culture',
    ActivityCategory.shopping => 'Shopping',
    ActivityCategory.relax => 'Relax',
  };

  static IconData icon(ActivityCategory c) => switch (c) {
    ActivityCategory.sightseeing => Icons.photo_camera_outlined,
    ActivityCategory.food => Icons.restaurant_outlined,
    ActivityCategory.nature => Icons.park_outlined,
    ActivityCategory.adventure => Icons.kayaking_outlined,
    ActivityCategory.culture => Icons.museum_outlined,
    ActivityCategory.shopping => Icons.shopping_bag_outlined,
    ActivityCategory.relax => Icons.self_improvement_outlined,
  };
}
