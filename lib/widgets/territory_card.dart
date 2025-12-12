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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
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
                      style: const TextStyle(color: Color(0xFF6A6A7B)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Control', style: TextStyle(color: Color(0xFF7A7A8C))),
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
              backgroundColor: const Color(0xFFE8E8F4),
              valueColor: AlwaysStoppedAnimation<Color>(territory.accent),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: territory.hotCategories
                .map(
                  (tag) => Chip(
                        backgroundColor: const Color(0xFFF0F3FF),
                        label: Text(tag),
                      ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${territory.challengers} rivals active • radius ${territory.radiusMeters}m',
            style: const TextStyle(color: Color(0xFF6A6A7B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4B4AEA),
                    side: const BorderSide(color: Color(0xFFD6DAF0)),
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
                    foregroundColor: Colors.white,
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
