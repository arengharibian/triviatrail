import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models.dart';
import '../data/territory_repository.dart';
import '../routes.dart';
import '../widgets/territory_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = TerritoryRepository.instance;
  Position? _position;
  bool _locating = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
    _resolveLocation();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  Future<void> _resolveLocation() async {
    setState(() {
      _locating = true;
      _permissionDenied = false;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _permissionDenied = true);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _position = position);
    } catch (_) {
      // ignore
    } finally {
      setState(() => _locating = false);
    }
  }

  List<Territory> get _territories {
    final lat = _position?.latitude;
    final lon = _position?.longitude;
    return _repo.byDistance(latitude: lat, longitude: lon);
  }

  double? _distanceFor(Territory territory) {
    final lat = _position?.latitude;
    final lon = _position?.longitude;
    if (lat == null || lon == null) return null;
    return _repo.distanceTo(territory, latitude: lat, longitude: lon);
  }

  void _openBattle(Territory territory) {
    Navigator.pushNamed(context, AppRoutes.battle, arguments: territory);
  }

  void _handleDestination(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.map);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contested = _repo.territories.where((t) => t.control < 0.55 && t.control > 0.25).length;
    final players = _repo.territories.fold<int>(0, (prev, t) => prev + t.challengers);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _handleDestination,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Districts'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFEFF), Color(0xFFE3EAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _resolveLocation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                automaticallyImplyLeading: false,
                title: const Text('Your Arena'),
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                    child: _HeroPanel(
                      locating: _locating,
                      permissionDenied: _permissionDenied,
                      onLocationTap: _resolveLocation,
                      playersOnline: players,
                      contestedZones: contested,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _QuickStats(
                    contestedZones: contested,
                    playersOnline: players,
                    locating: _locating,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final territory = _territories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: TerritoryCard(
                        territory: territory,
                        distanceMeters: _distanceFor(territory),
                        onScout: () => Navigator.pushNamed(context, AppRoutes.map),
                        onEngage: () => _openBattle(territory),
                      ),
                    );
                  },
                  childCount: _territories.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final bool locating;
  final bool permissionDenied;
  final VoidCallback onLocationTap;
  final int playersOnline;
  final int contestedZones;

  const _HeroPanel({
    required this.locating,
    required this.permissionDenied,
    required this.onLocationTap,
    required this.playersOnline,
    required this.contestedZones,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = permissionDenied
        ? 'Location permission is off. Tap to retry.'
        : locating
            ? 'Scanning for active territories...'
            : 'Ready to deploy in your closest battle line.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [Color(0xFF66D4FF), Color(0xFF7A74FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live rival check-in',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: List.generate(
                  12,
                  (index) => Expanded(
                    child: Container(
                      color: index.isEven ? Colors.black26 : Colors.yellow.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _HeroMetric(label: 'Players nearby', value: '$playersOnline')),
              const SizedBox(width: 12),
              Expanded(child: _HeroMetric(label: 'Zones contested', value: '$contestedZones')),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onLocationTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4B4AEA),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: Icon(locating ? Icons.downloading : Icons.my_location),
            label: Text(locating ? 'Re-scanning' : 'Rescan location'),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int playersOnline;
  final int contestedZones;
  final bool locating;

  const _QuickStats({
    required this.playersOnline,
    required this.contestedZones,
    required this.locating,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatTileData(
        icon: Icons.flash_on,
        title: 'Quick match',
        subtitle: locating ? 'Calibrating...' : 'Closest battle auto-join.',
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.battle,
          arguments: TerritoryRepository.instance.territories.first,
        ),
      ),
      _StatTileData(
        icon: Icons.shield_moon,
        title: '$contestedZones contested',
        subtitle: 'Hold the line or reclaim it tonight.',
      ),
      _StatTileData(
        icon: Icons.people_alt,
        title: '$playersOnline rivals',
        subtitle: 'Locals currently online.',
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return SizedBox(width: 220, child: _StatCard(data: tile));
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: tiles.length,
      ),
    );
  }
}

class _StatTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  _StatTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final _StatTileData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: const Color(0xFF6C5CE7)),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                style: const TextStyle(color: Color(0xFF6B6B7A), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
