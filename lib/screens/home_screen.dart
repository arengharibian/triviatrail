import 'dart:math';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/models.dart';
import '../widgets/level_card.dart';
import '../data/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final levels = <Level>[
    Level(
      id: 1,
      title: 'Campus Gate',
      description: 'Warm-up questions to start your journey.',
      difficulty: 1,
      latitude: null,
      longitude: null,
    ),
    Level(
      id: 2,
      title: 'Library Steps',
      description: 'Trivia for the well-read wanderer.',
      difficulty: 2,
      latitude: 43.039, // example
      longitude: -76.135,
    ),
    Level(
      id: 3,
      title: 'Stadium Lights',
      description: 'Sports, noise, and night-time questions.',
      difficulty: 3,
      latitude: 43.041,
      longitude: -76.138,
    ),
  ];

  Map<int, int> bestScores = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    bestScores = await DBHelper.instance.getBestScores();
    if (mounted) setState(() {});
  }

  void _openRandomLevel() {
    final random = Random();
    final level = levels[random.nextInt(levels.length)];
    Navigator.pushNamed(context, '/level', arguments: level).then((_) {
      _loadScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'TriviaTrail',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadScores,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            // Example menu
            if (value == 'about') {
              showAboutDialog(
                context: context,
                applicationName: 'TriviaTrail',
                applicationVersion: '1.0.0',
              );
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'about',
              child: Text('About'),
            ),
          ],
        ),
      ],
      fab: FloatingActionButton(
        onPressed: _openRandomLevel,
        child: const Icon(Icons.play_arrow),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isWide
                ? GridView.count(
                    key: const ValueKey('grid'),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    children: levels
                        .map((l) => LevelCard(
                              level: l,
                              bestScore: bestScores[l.id],
                              onTap: () {
                                Navigator.pushNamed(context, '/level',
                                    arguments: l);
                              },
                            ))
                        .toList(),
                  )
                : ListView.builder(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.all(16),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return LevelCard(
                        level: level,
                        bestScore: bestScores[level.id],
                        onTap: () {
                          Navigator.pushNamed(context, '/level',
                              arguments: level);
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
