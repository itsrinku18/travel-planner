import 'package:flutter/material.dart';

enum DestinationCategory {
  all('All', Icons.public),
  beach('Beaches', Icons.beach_access_outlined),
  mountains('Mountains', Icons.terrain_outlined),
  city('Cities', Icons.location_city_outlined),
  spiritual('Spiritual', Icons.self_improvement_outlined),
  food('Food', Icons.restaurant_outlined),
  adventure('Adventure', Icons.kayaking_outlined);

  const DestinationCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}
