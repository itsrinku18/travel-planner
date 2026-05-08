import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/trip.dart';

class TripsState extends Equatable {
  const TripsState({
    required this.trips,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<Trip> trips;
  final bool isLoading;
  final String? errorMessage;

  TripsState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const initial = TripsState(
    trips: [],
    isLoading: false,
    errorMessage: null,
  );

  @override
  List<Object?> get props => [trips, isLoading, errorMessage];
}
