import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../app.dart';
import '../data/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _position;

  final _levels = <Level>[
    // same list as in HomeScreen (could be shared via provider)
  ];

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _position = position);
  }

  @override
  Widget build(BuildContext context) {
    final markers = _levels
        .where((l) => l.latitude != null && l.longitude != null)
        .map(
          (level) => Marker(
            markerId: MarkerId(level.id.toString()),
            position: LatLng(level.latitude!, level.longitude!),
            infoWindow: InfoWindow(title: level.title),
          ),
        )
        .toSet();

    return AppScaffold(
      title: 'Trail Map',
      body: _position == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_position!.latitude, _position!.longitude),
                zoom: 15,
              ),
              markers: markers,
              myLocationEnabled: true,
              onMapCreated: (_) {},
            ),
    );
  }
}
