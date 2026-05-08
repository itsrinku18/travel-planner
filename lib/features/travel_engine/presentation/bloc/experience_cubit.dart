import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/get_recommendations.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_state.dart';

class ExperienceCubit extends Cubit<ExperienceState> {
  ExperienceCubit({required GetRecommendations getRecommendations})
    : _getRecommendations = getRecommendations,
      super(ExperienceState.initial);

  final GetRecommendations _getRecommendations;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _getRecommendations(
      GetRecommendationsParams(preferences: state.preferences),
    );
    if (result.failure != null) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure!.message),
      );
      return;
    }
    emit(state.copyWith(isLoading: false, recommendations: result.data!));
  }

  Future<void> togglePreference(ActivityCategory cat) async {
    final next =
        state.preferences.contains(cat)
            ? (Set<ActivityCategory>.from(state.preferences)..remove(cat))
            : (Set<ActivityCategory>.from(state.preferences)..add(cat));
    emit(state.copyWith(preferences: next));
    await load();
  }

  Future<void> clear() async {
    emit(state.copyWith(preferences: {}));
    await load();
  }
}
