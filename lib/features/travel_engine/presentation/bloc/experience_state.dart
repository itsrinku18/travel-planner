import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/recommendation.dart';

class ExperienceState extends Equatable {
  const ExperienceState({
    required this.preferences,
    required this.recommendations,
    required this.isLoading,
    required this.errorMessage,
  });

  final Set<ActivityCategory> preferences;
  final List<Recommendation> recommendations;
  final bool isLoading;
  final String? errorMessage;

  static const initial = ExperienceState(
    preferences: {},
    recommendations: [],
    isLoading: false,
    errorMessage: null,
  );

  ExperienceState copyWith({
    Set<ActivityCategory>? preferences,
    List<Recommendation>? recommendations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExperienceState(
      preferences: preferences ?? this.preferences,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    preferences,
    recommendations,
    isLoading,
    errorMessage,
  ];
}
