import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _controller;
  Position? _position;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_handleRepoChange);
    _loadLocation();
  }

  void _handleRepoChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _repo.removeListener(_handleRepoChange);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() => _requesting = true);
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
      setState(() => _position = position);
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (_) {
      // ignore errors
    } finally {
      setState(() => _requesting = false);
    }
  }

  Set<Circle> get _circles {
    return _repo.territories
        .map(
          (territory) => Circle(
            circleId: CircleId('territory-${territory.id}'),
            center: LatLng(territory.latitude, territory.longitude),
            radius: territory.radiusMeters.toDouble(),
            strokeColor: territory.accent.withValues(alpha: 0.8),
            fillColor: territory.accent.withValues(alpha: 0.15),
            strokeWidth: 2,
          ),
        )
        .toSet();
  }

  Set<Marker> get _markers {
    return _repo.territories
        .map(
          (territory) => Marker(
            markerId: MarkerId('marker-${territory.id}'),
            position: LatLng(territory.latitude, territory.longitude),
            infoWindow: InfoWindow(
              title: territory.name,
              snippet:
                  '${(territory.control * 100).toStringAsFixed(0)}% control • ${territory.challengers} rivals',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.battle,
                arguments: territory,
              ),
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final target = _position != null
        ? LatLng(_position!.latitude, _position!.longitude)
        : LatLng(_repo.territories.first.latitude, _repo.territories.first.longitude);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: target, zoom: 13.5),
              myLocationEnabled: _position != null,
              circles: _circles,
              markers: _markers,
              onMapCreated: (controller) => _controller = controller,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildLegend(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 210,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.78),
                  itemCount: _repo.territories.length,
                  itemBuilder: (context, index) {
                    final territory = _repo.territories[index];
                    final distance = _repo.distanceTo(
                      territory,
                      latitude: _position?.latitude,
                      longitude: _position?.longitude,
                    );
                    return _TerritoryPreviewCard(
                      territory: territory,
                      distanceMeters: distance,
                      onEngage: () => Navigator.pushNamed(
                        context,
                        AppRoutes.battle,
                        arguments: territory,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _requesting ? null : _loadLocation,
        label: Text(_requesting ? 'Syncing...' : 'Center on me'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _position == null ? 'Waiting for your signal' : 'Synced to your GPS',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white70),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Colored rings show how far you need to be to contribute full control.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _TerritoryPreviewCard extends StatelessWidget {
  final Territory territory;
  final double? distanceMeters;
  final VoidCallback onEngage;

  const _TerritoryPreviewCard({
    required this.territory,
    required this.distanceMeters,
    required this.onEngage,
  });

  @override
  Widget build(BuildContext context) {
    final distanceLabel = distanceMeters == null
        ? 'Unknown distance'
        : distanceMeters! < 30
            ? 'Inside zone'
            : '${(distanceMeters! / 1000).toStringAsFixed(2)} km away';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withValues(alpha: 0.6),
          border: Border.all(color: Colors.white10),
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
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.place, color: territory.accent, size: 18),
                const SizedBox(width: 4),
                Text(distanceLabel),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: territory.control,
              backgroundColor: Colors.white12,
              color: territory.accent,
            ),
            const SizedBox(height: 8),
            Text(
              '${(territory.control * 100).toStringAsFixed(0)}% control • ${territory.challengers} rivals',
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onEngage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                backgroundColor: territory.accent,
              ),
              child: const Text('Engage'),
            ),
          ],
        ),
      ),
    );
  }
}
