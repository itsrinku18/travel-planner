import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/wishlist/domain/wishlist_repository.dart';

class WishlistState extends Equatable {
  const WishlistState({required this.ids, required this.isLoading});

  final Set<String> ids;
  final bool isLoading;

  static const initial = WishlistState(ids: <String>{}, isLoading: false);

  WishlistState copyWith({Set<String>? ids, bool? isLoading}) => WishlistState(
    ids: ids ?? this.ids,
    isLoading: isLoading ?? this.isLoading,
  );

  bool contains(String id) => ids.contains(id);

  @override
  List<Object?> get props => [ids, isLoading];
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({required WishlistRepository repo})
    : _repo = repo,
      super(WishlistState.initial);

  final WishlistRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final ids = await _repo.load();
    if (isClosed) return;
    emit(state.copyWith(ids: ids, isLoading: false));
  }

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state.ids);
    if (!next.add(id)) next.remove(id);
    emit(state.copyWith(ids: next));
    await _repo.toggle(id);
  }
}
