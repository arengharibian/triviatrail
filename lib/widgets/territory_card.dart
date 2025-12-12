import 'package:flutter/material.dart';

import '../data/models.dart';

class TerritoryCard extends StatelessWidget {
  final Territory territory;
  final double? distanceMeters;
  final VoidCallback onScout;
  final VoidCallback onEngage;

  const TerritoryCard({
    super.key,
    required this.territory,
    required this.distanceMeters,
    required this.onScout,
    required this.onEngage,
  });

  @override
  Widget build(BuildContext context) {
    final distanceLabel = distanceMeters == null
        ? 'Unknown distance'
        : distanceMeters! < 35
            ? 'Inside the zone'
            : '${(distanceMeters! / 1000).toStringAsFixed(2)} km away';

    final controlPercent = (territory.control * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: territory.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${territory.landmark} • $distanceLabel',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Control', style: TextStyle(color: Colors.white70)),
                  Text(
                    '$controlPercent%',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: territory.control,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(territory.accent),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: territory.hotCategories
                .map(
                  (tag) => Chip(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        label: Text(tag),
                      ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${territory.challengers} rivals active • radius ${territory.radiusMeters}m',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Scout'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEngage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: territory.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.bolt),
                  label: const Text('Engage'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
