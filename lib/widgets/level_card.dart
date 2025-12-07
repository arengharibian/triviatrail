import 'package:flutter/material.dart';
import '../data/models.dart';

class LevelCard extends StatelessWidget {
  final Level level;
  final int? bestScore;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.bestScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'level-${level.id}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          level.difficulty,
                          (index) => const Icon(Icons.star, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
                if (bestScore != null)
                  Column(
                    children: [
                      const Text('Best'),
                      Text(
                        '$bestScore',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
