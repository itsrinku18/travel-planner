import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_planner/core/usecase/usecase.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/add_activity_to_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/create_trip.dart';
import 'package:travel_planner/features/travel_engine/domain/usecases/list_trips.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  TripsCubit({
    required CreateTrip createTrip,
    required ListTrips listTrips,
    required AddActivityToTrip addActivityToTrip,
  }) : _createTrip = createTrip,
       _listTrips = listTrips,
       _addActivityToTrip = addActivityToTrip,
       super(TripsState.initial);

  final CreateTrip _createTrip;
  final ListTrips _listTrips;
  final AddActivityToTrip _addActivityToTrip;
  final _uuid = const Uuid();

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _listTrips(const NoParams());
    if (result.failure != null) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure!.message),
      );
      return;
    }
    emit(state.copyWith(isLoading: false, trips: result.data!));
  }

  Future<void> create({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _createTrip(
      CreateTripParams(
        destination: destination,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    if (result.failure != null) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure!.message),
      );
      return;
    }
    await load();
  }

  Future<void> addActivity({
    required String tripId,
    required String title,
    required ActivityCategory category,
    required DateTime startAt,
    required int durationMinutes,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final activity = Activity(
      id: _uuid.v4(),
      title: title.trim(),
      category: category,
      startAt: startAt,
      durationMinutes: durationMinutes,
    );
    final result = await _addActivityToTrip(
      AddActivityParams(tripId: tripId, activity: activity),
    );
    if (result.failure != null) {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.failure!.message),
      );
      return;
    }
    await load();
  }

  Trip? byId(String id) {
    for (final t in state.trips) {
      if (t.id == id) return t;
    }
    return null;
  }
}
