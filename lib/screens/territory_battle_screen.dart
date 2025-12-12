import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models.dart';
import '../data/territory_repository.dart';
import '../data/location_trivia_service.dart';

enum MatchPhase { scanning, battle, complete }

class TerritoryBattleScreen extends StatefulWidget {
  final Territory territory;
  const TerritoryBattleScreen({super.key, required this.territory});

  @override
  State<TerritoryBattleScreen> createState() => _TerritoryBattleScreenState();
}

class _TerritoryBattleScreenState extends State<TerritoryBattleScreen> {
  final _repo = TerritoryRepository.instance;
  final _trivia = LocationTriviaService();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _playerScore = 0;
  int _rivalScore = 0;
  double _controlDelta = 0;
  double? _distance;
  Position? _playerPosition;
  bool _loading = true;
  MatchPhase _phase = MatchPhase.scanning;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_handleRepoChange);
    _bootstrap();
  }

  void _handleRepoChange() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrap() async {
    await _resolveLocation();
    final questions = await _trivia.generateQuestionsFor(
      widget.territory,
      position: _playerPosition,
      distanceMeters: _distance,
    );
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _loading = false;
      _phase = MatchPhase.battle;
    });
  }

  Future<void> _resolveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.territory.latitude,
        widget.territory.longitude,
      );
      setState(() {
        _playerPosition = position;
        _distance = distance;
      });
    } catch (_) {
      // Ignore errors, we can still play remotely.
    }
  }

  @override
  void dispose() {
    _repo.removeListener(_handleRepoChange);
    super.dispose();
  }

  Territory get _liveTerritory =>
      _repo.byId(widget.territory.id) ?? widget.territory;

  double get _roundProgress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  Future<void> _handleAnswer(int index) async {
    if (_phase != MatchPhase.battle) return;
    final question = _questions[_currentIndex];
    final correct = index == question.correctIndex;
    setState(() {
      if (correct) {
        _playerScore += 12;
        _controlDelta += 0.08;
      } else {
        _rivalScore += 9;
        _controlDelta -= 0.05;
      }
    });

    await Future.delayed(const Duration(milliseconds: 220));

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _repo.awardControl(widget.territory.id, _controlDelta);
      if (!mounted) return;
      setState(() {
        _phase = MatchPhase.complete;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final territory = _liveTerritory;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              territory.accent.withValues(alpha: 0.25),
              const Color(0xFF0F111A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context, territory),
                const SizedBox(height: 16),
                _buildControlMeter(territory),
                const SizedBox(height: 12),
                _buildMomentumRow(),
                const SizedBox(height: 16),
                Expanded(child: _buildBattleArea(context, territory)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Territory territory) {
    final distanceMeters = _distance;
    final distanceLabel = distanceMeters == null
        ? 'Unknown distance'
        : distanceMeters < 30
            ? 'Inside the zone'
            : '${(distanceMeters / 1000).toStringAsFixed(2)} km away';

    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
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
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${territory.landmark} • $distanceLabel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.groups, size: 16),
              const SizedBox(width: 4),
              Text('${territory.challengers} nearby'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlMeter(Territory territory) {
    final projected = (territory.control + max(_controlDelta, -territory.control))
        .clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Territory Control',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = (constraints.maxWidth * projected).clamp(12, constraints.maxWidth);
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 12,
                    width: barWidth.toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          territory.accent,
                          territory.accent.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You ${(_controlDelta * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Locals ${(territory.control * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMomentumRow() {
    final total = max(1, _playerScore + _rivalScore);
    final playerShare = _playerScore / total;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.05),
            ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Momentum',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: playerShare,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('You $_playerScore pts'),
                    Text('Locals $_rivalScore pts'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          width: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              const Text(
                'Round',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                '${_currentIndex + 1}/${_questions.isEmpty ? 5 : _questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBattleArea(BuildContext context, Territory territory) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_phase == MatchPhase.complete) {
      return _buildResultsCard(context, territory);
    }

    final question = _questions[_currentIndex];
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                        onPressed: () => _handleAnswer(index),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            question.options[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _roundProgress,
            minHeight: 6,
            backgroundColor: Colors.white12,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Complete the set to shift control'),
      ],
    );
  }

  Widget _buildResultsCard(BuildContext context, Territory territory) {
    final controlChange = (_controlDelta * 100).toStringAsFixed(1);
    final success = _controlDelta >= 0;
    final headline = success ? 'Zone fortified' : 'Control lost';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                success
                    ? 'Your squad just pushed deeper into ${territory.name}.'
                    : 'Locals reclaimed ground while you were inside.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Control Shift', style: TextStyle(color: Colors.white70)),
                        Text(
                          '$controlChange%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: success ? Colors.tealAccent : Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Final Score', style: TextStyle(color: Colors.white70)),
                        Text('You $_playerScore • Locals $_rivalScore',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: territory.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.shield),
          label: const Text(
            'Return to districts',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
