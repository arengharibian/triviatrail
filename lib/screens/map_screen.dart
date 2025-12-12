import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models.dart';
import '../data/territory_repository.dart';
import '../routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _repo = TerritoryRepository.instance;
  Position? _position;
  bool _locating = false;

  late final double _minLat;
  late final double _maxLat;
  late final double _minLon;
  late final double _maxLon;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
    _computeBounds();
    _resolveLocation();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  void _computeBounds() {
    final lats = _repo.territories.map((t) => t.latitude);
    final lons = _repo.territories.map((t) => t.longitude);
    _minLat = lats.reduce(min);
    _maxLat = lats.reduce(max);
    _minLon = lons.reduce(min);
    _maxLon = lons.reduce(max);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  Future<void> _resolveLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Offset _offsetFor(Territory territory) {
    double normalize(double value, double min, double max) {
      if ((max - min).abs() < 0.0001) return 0.5;
      return (value - min) / (max - min);
    }

    final x = normalize(territory.longitude, _minLon, _maxLon);
    final y = 1 - normalize(territory.latitude, _minLat, _maxLat);
    return Offset(x, y);
  }

  Offset? _offsetForPosition(Position? position) {
    if (position == null) return null;
    final fake = Territory(
      id: -1,
      name: 'You',
      landmark: '',
      latitude: position.latitude,
      longitude: position.longitude,
      radiusMeters: 0,
      control: 0,
      challengers: 0,
      hotCategories: const [],
      accent: Colors.white,
    );
    return _offsetFor(fake);
  }

  @override
  Widget build(BuildContext context) {
    final devices = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF150A2E),
                    Color(0xFF040712),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + devices.padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildMapCanvas()),
                  const SizedBox(height: 16),
                  _buildTerritoryCarousel(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _locating ? null : _resolveLocation,
        icon: Icon(_locating ? Icons.radar : Icons.my_location),
        label: Text(_locating ? 'Scanning...' : 'Center on me'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.15),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live territory map',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _position == null ? 'Synced to presets' : 'Locked to your GPS',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          child: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Orbs pulse in real time as squads tip the balance. Tap any hotspot to deploy instantly.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            icon: const Icon(Icons.home_outlined, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildMapCanvas() {
    final userOffset = _offsetForPosition(_position);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF241D4A), Color(0xFF0F1328)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
                ..._repo.territories.map((territory) {
                  final offset = _offsetFor(territory);
                  return Positioned(
                    left: offset.dx * width - 32,
                    top: offset.dy * height - 32,
                    child: _MapPin(
                      territory: territory,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.battle,
                          arguments: territory,
                        );
                      },
                    ),
                  );
                }),
                if (userOffset != null)
                  Positioned(
                    left: userOffset.dx * width - 16,
                    top: userOffset.dy * height - 16,
                    child: _UserPin(scanning: _locating),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTerritoryCarousel(BuildContext context) {
    final controller = PageController(viewportFraction: 0.82);
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: controller,
        itemCount: _repo.territories.length,
        itemBuilder: (context, index) {
          final territory = _repo.territories[index];
          final distance = _repo.distanceTo(
            territory,
            latitude: _position?.latitude,
            longitude: _position?.longitude,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _MapCard(
              territory: territory,
              distanceMeters: distance,
              onEngage: () => Navigator.pushNamed(
                context,
                AppRoutes.battle,
                arguments: territory,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Territory territory;
  final VoidCallback onTap;

  const _MapPin({required this.territory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              territory.name,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: territory.accent.withValues(alpha: 0.6),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  territory.accent,
                  territory.accent.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Center(
              child: Text(
                '${(territory.control * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserPin extends StatelessWidget {
  final bool scanning;
  const _UserPin({required this.scanning});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scanning ? Colors.orangeAccent : Colors.white,
        boxShadow: [
          BoxShadow(
            color: scanning ? Colors.orangeAccent : Colors.white24,
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(Icons.navigation, color: Colors.black, size: 18),
    );
  }
}

class _MapCard extends StatelessWidget {
  final Territory territory;
  final double? distanceMeters;
  final VoidCallback onEngage;

  const _MapCard({
    required this.territory,
    required this.distanceMeters,
    required this.onEngage,
  });

  @override
  Widget build(BuildContext context) {
    final distance = distanceMeters == null
        ? 'Preset'
        : distanceMeters! < 30
            ? 'Inside zone'
            : '${(distanceMeters! / 1000).toStringAsFixed(2)} km away';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            territory.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            territory.landmark,
            style: const TextStyle(color: Color(0xFF6A6A7B)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Color(0xFF77778C)),
              const SizedBox(width: 6),
              Text(distance, style: const TextStyle(color: Color(0xFF77778C))),
            ],
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: territory.control,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8E8F4),
            color: territory.accent,
          ),
          const SizedBox(height: 8),
          Text(
            '${(territory.control * 100).toStringAsFixed(0)}% control • ${territory.challengers} rivals',
            style: const TextStyle(color: Color(0xFF77778C)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onEngage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              backgroundColor: territory.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Engage'),
          )
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 80.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide * 0.35, circlePaint);
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide * 0.55, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
