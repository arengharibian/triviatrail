import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'models.dart';

class TerritoryRepository extends ChangeNotifier {
  TerritoryRepository._internal();

  static final TerritoryRepository instance = TerritoryRepository._internal();

  final List<Territory> _territories = [
    Territory(
      id: 1,
      name: 'Canal District',
      landmark: 'Clinton Square',
      latitude: 43.0481,
      longitude: -76.1474,
      radiusMeters: 550,
      control: 0.64,
      challengers: 12,
      hotCategories: ['Local History', 'Architecture', 'Food'],
      accent: const Color(0xFF5C6BC0),
    ),
    Territory(
      id: 2,
      name: 'University Commons',
      landmark: 'Marshall Street',
      latitude: 43.0389,
      longitude: -76.1351,
      radiusMeters: 480,
      control: 0.41,
      challengers: 27,
      hotCategories: ['Pop Culture', 'STEM', 'Campus Lore'],
      accent: const Color(0xFF7E57C2),
    ),
    Territory(
      id: 3,
      name: 'Dome Line',
      landmark: 'JMA Dome',
      latitude: 43.0361,
      longitude: -76.1360,
      radiusMeters: 520,
      control: 0.78,
      challengers: 9,
      hotCategories: ['Sports', 'Legends', 'Music'],
      accent: const Color(0xFFF06292),
    ),
    Territory(
      id: 4,
      name: 'Westcott Ridge',
      landmark: 'Westcott Street',
      latitude: 43.0477,
      longitude: -76.1210,
      radiusMeters: 610,
      control: 0.33,
      challengers: 18,
      hotCategories: ['Arts', 'Indie Culture', 'Cafes'],
      accent: const Color(0xFF26A69A),
    ),
  ];

  List<Territory> get territories => List.unmodifiable(_territories);

  Territory? byId(int id) {
    for (final territory in _territories) {
      if (territory.id == id) return territory;
    }
    return null;
  }

  List<Territory> byDistance({
    double? latitude,
    double? longitude,
  }) {
    if (latitude == null || longitude == null) {
      return List.unmodifiable(_territories);
    }
    final items = _territories.toList();
    items.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        latitude,
        longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        latitude,
        longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    return items;
  }

  double? distanceTo(
    Territory territory, {
    double? latitude,
    double? longitude,
  }) {
    if (latitude == null || longitude == null) return null;
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      territory.latitude,
      territory.longitude,
    );
  }

  void awardControl(int territoryId, double delta) {
    final index = _territories.indexWhere((t) => t.id == territoryId);
    if (index == -1) return;
    final current = _territories[index];
    final updated = current.copyWith(
      control: (current.control + delta).clamp(0.0, 1.0),
      challengers: max(0, current.challengers + (delta >= 0 ? 1 : -1)),
    );
    _territories[index] = updated;
    notifyListeners();
  }

  void pulse() {
    // Simple helper to notify listeners when external services refresh.
    notifyListeners();
  }
}
