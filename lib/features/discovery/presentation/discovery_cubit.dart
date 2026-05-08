import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';
import 'package:travel_planner/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit({required DiscoveryRepository repo})
    : _repo = repo,
      super(DiscoveryState.initial);

  final DiscoveryRepository _repo;
  Timer? _debounce;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final trending = await _repo.trending();
    final recommended = await _repo.recommended();
    final categoryResults = await _repo.byCategory(state.category);

    final failure =
        trending.failure ?? recommended.failure ?? categoryResults.failure;
    if (failure != null) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      return;
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        isLoading: false,
        trending: trending.data!,
        recommended: recommended.data!,
        categoryResults: categoryResults.data!,
        searchResults: const [],
      ),
    );
  }

  Future<void> setCategory(DestinationCategory category) async {
    emit(state.copyWith(category: category));
    final r = await _repo.byCategory(category);
    if (isClosed) return;
    if (r.failure != null) {
      emit(state.copyWith(errorMessage: r.failure!.message));
      return;
    }
    emit(state.copyWith(categoryResults: r.data!));
  }

  void setQuery(String q) {
    if (isClosed) return;
    emit(state.copyWith(query: q));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () async {
      if (isClosed) return;
      final query = state.query.trim();
      if (query.isEmpty) {
        emit(state.copyWith(searchResults: const []));
        return;
      }
      final r = await _repo.search(query);
      if (isClosed) return;
      if (r.failure != null) {
        emit(state.copyWith(errorMessage: r.failure!.message));
        return;
      }
      emit(state.copyWith(searchResults: r.data!));
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
