import 'package:travel_planner/features/discovery/domain/entities/destination.dart';
import 'package:travel_planner/features/discovery/domain/entities/destination_category.dart';

abstract interface class DiscoveryLocalDataSource {
  Future<List<Destination>> trending();
  Future<List<Destination>> recommended();
  Future<List<Destination>> search(String query);
  Future<Destination?> byId(String id);
  Future<List<Destination>> byCategory(DestinationCategory category);
}

class DiscoveryLocalDataSourceImpl implements DiscoveryLocalDataSource {
  static const _seed = <Destination>[
    Destination(
      id: 'goa',
      name: 'Goa',
      country: 'India',
      heroImageUrl:
          'https://images.unsplash.com/photo-1526481280695-3c687fd643ed?auto=format&fit=crop&w=1400&q=80',
      tags: ['Beaches', 'Night markets', 'Sunsets'],
      rating: 4.6,
      priceLevel: PriceLevel.mid,
      categories: [DestinationCategory.beach, DestinationCategory.food],
      summary:
          'Sun-soaked beaches, Portuguese architecture and a laid-back vibe — perfect for a long weekend escape.',
      bestSeason: 'Nov – Feb',
    ),
    Destination(
      id: 'varanasi',
      name: 'Varanasi',
      country: 'India',
      heroImageUrl:
          'https://images.unsplash.com/photo-1601972602237-8c79241e468b?auto=format&fit=crop&w=1400&q=80',
      tags: ['Spiritual', 'Ghats', 'Aarti'],
      rating: 4.7,
      priceLevel: PriceLevel.budget,
      categories: [DestinationCategory.spiritual, DestinationCategory.city],
      summary:
          'One of the world’s oldest living cities. Ganga aarti, narrow lanes, sunrise boat rides.',
      bestSeason: 'Oct – Mar',
    ),
    Destination(
      id: 'tokyo',
      name: 'Tokyo',
      country: 'Japan',
      heroImageUrl:
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=1400&q=80',
      tags: ['Food', 'City lights', 'Culture'],
      rating: 4.8,
      priceLevel: PriceLevel.luxury,
      categories: [DestinationCategory.city, DestinationCategory.food],
      summary:
          'A neon-lit megacity that pairs ancient temples with hyper-modern districts and world-class food.',
      bestSeason: 'Mar – May / Oct – Nov',
    ),
    Destination(
      id: 'bali',
      name: 'Bali',
      country: 'Indonesia',
      heroImageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=1400&q=80',
      tags: ['Nature', 'Wellness', 'Villas'],
      rating: 4.7,
      priceLevel: PriceLevel.mid,
      categories: [DestinationCategory.beach, DestinationCategory.adventure],
      summary:
          'Rice terraces, surf breaks and serene temples — Bali balances adventure with deep relaxation.',
      bestSeason: 'Apr – Oct',
    ),
    Destination(
      id: 'leh',
      name: 'Leh-Ladakh',
      country: 'India',
      heroImageUrl:
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=1400&q=80',
      tags: ['Adventure', 'Mountains', 'Road trip'],
      rating: 4.8,
      priceLevel: PriceLevel.mid,
      categories: [
        DestinationCategory.mountains,
        DestinationCategory.adventure,
      ],
      summary:
          'High-altitude desert with dramatic monasteries, turquoise lakes and legendary mountain passes.',
      bestSeason: 'Jun – Sep',
    ),
    Destination(
      id: 'paris',
      name: 'Paris',
      country: 'France',
      heroImageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1400&q=80',
      tags: ['Art', 'Cafes', 'Architecture'],
      rating: 4.7,
      priceLevel: PriceLevel.luxury,
      categories: [DestinationCategory.city, DestinationCategory.food],
      summary:
          'Boulevards, boulangeries and museums for days — Paris rewards slow walking and second espressos.',
      bestSeason: 'Apr – Jun / Sep – Oct',
    ),
    Destination(
      id: 'kerala',
      name: 'Kerala Backwaters',
      country: 'India',
      heroImageUrl:
          'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=1400&q=80',
      tags: ['Backwaters', 'Houseboat', 'Coconut'],
      rating: 4.6,
      priceLevel: PriceLevel.mid,
      categories: [DestinationCategory.beach, DestinationCategory.food],
      summary:
          'Languid backwaters explored by houseboat — a slow, sensorial India experience.',
      bestSeason: 'Sep – Mar',
    ),
    Destination(
      id: 'swiss',
      name: 'Swiss Alps',
      country: 'Switzerland',
      heroImageUrl:
          'https://images.unsplash.com/photo-1530841344095-502e3d8b9b07?auto=format&fit=crop&w=1400&q=80',
      tags: ['Snow', 'Trains', 'Hiking'],
      rating: 4.9,
      priceLevel: PriceLevel.luxury,
      categories: [
        DestinationCategory.mountains,
        DestinationCategory.adventure,
      ],
      summary:
          'Postcard-perfect alpine villages, scenic rail rides, and trails for every fitness level.',
      bestSeason: 'Jun – Sep / Dec – Mar',
    ),
  ];

  @override
  Future<List<Destination>> trending() async => _seed.take(4).toList();

  @override
  Future<List<Destination>> recommended() async => _seed.toList();

  @override
  Future<List<Destination>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _seed
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.country.toLowerCase().contains(q) ||
              d.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Future<Destination?> byId(String id) async {
    for (final d in _seed) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Future<List<Destination>> byCategory(DestinationCategory category) async {
    if (category == DestinationCategory.all) return _seed.toList();
    return _seed.where((d) => d.categories.contains(category)).toList();
  }
}
