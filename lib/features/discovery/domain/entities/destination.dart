import 'package:equatable/equatable.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';

class Destination extends Equatable {
  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.heroImageUrl,
    required this.tags,
    required this.rating,
    required this.priceLevel,
    required this.categories,
    this.summary = '',
    this.bestSeason = '',
  });

  final String id;
  final String name;
  final String country;
  final String heroImageUrl;
  final List<String> tags;
  final double rating;
  final PriceLevel priceLevel;
  final List<DestinationCategory> categories;
  final String summary;
  final String bestSeason;

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    heroImageUrl,
    tags,
    rating,
    priceLevel,
    categories,
    summary,
    bestSeason,
  ];
}

enum PriceLevel { budget, mid, luxury }

extension PriceLevelX on PriceLevel {
  String get label => switch (this) {
    PriceLevel.budget => 'Budget',
    PriceLevel.mid => 'Mid',
    PriceLevel.luxury => 'Luxury',
  };

  String get symbol => switch (this) {
    PriceLevel.budget => '\$',
    PriceLevel.mid => '\$\$',
    PriceLevel.luxury => '\$\$\$',
  };
}
