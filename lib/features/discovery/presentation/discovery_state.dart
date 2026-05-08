import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';

class DiscoveryState extends Equatable {
  const DiscoveryState({
    required this.isLoading,
    required this.errorMessage,
    required this.query,
    required this.trending,
    required this.recommended,
    required this.searchResults,
    required this.category,
    required this.categoryResults,
  });

  final bool isLoading;
  final String? errorMessage;
  final String query;
  final List<Destination> trending;
  final List<Destination> recommended;
  final List<Destination> searchResults;
  final DestinationCategory category;
  final List<Destination> categoryResults;

  static const initial = DiscoveryState(
    isLoading: false,
    errorMessage: null,
    query: '',
    trending: [],
    recommended: [],
    searchResults: [],
    category: DestinationCategory.all,
    categoryResults: [],
  );

  DiscoveryState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? query,
    List<Destination>? trending,
    List<Destination>? recommended,
    List<Destination>? searchResults,
    DestinationCategory? category,
    List<Destination>? categoryResults,
  }) {
    return DiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      query: query ?? this.query,
      trending: trending ?? this.trending,
      recommended: recommended ?? this.recommended,
      searchResults: searchResults ?? this.searchResults,
      category: category ?? this.category,
      categoryResults: categoryResults ?? this.categoryResults,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    query,
    trending,
    recommended,
    searchResults,
    category,
    categoryResults,
  ];
}
