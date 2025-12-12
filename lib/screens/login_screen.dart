import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _aliasController = TextEditingController();
  final _emailController = TextEditingController();
  bool _requestingLocation = false;
  bool _locationGranted = false;
  String _status = 'We match you with live trivia zones based on your GPS.';

  @override
  void dispose() {
    _aliasController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() => _requestingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _status = 'Enable location services to anchor trivia in your area.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _status = 'Permission denied. We need location to pair you with nearby rivals.';
          _locationGranted = false;
        });
        return;
      }

      await Geolocator.getCurrentPosition();
      setState(() {
        _locationGranted = true;
        _status = 'Locked on. We\'ll drop you into the busiest arena nearby.';
      });
    } catch (err) {
      setState(() {
        _status = 'Could not read your position: $err';
      });
    } finally {
      setState(() => _requestingLocation = false);
    }
  }

  void _enterArena() {
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a call sign before entering.')),
      );
      return;
    }
    if (!_locationGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secure location access first.')),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF090B13), Color(0xFF161C3A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF5F5BFF), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TriviaTrail',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Claim the blocks around you with live trivia battles.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  _buildMissionCard(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    final tags = ['Downtown', 'Campus', 'Food Row', 'Arts District', 'Harbor'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tonight’s Trail',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _status,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    label: Text(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _requestingLocation ? null : _requestLocation,
            style: FilledButton.styleFrom(
              backgroundColor:
                  _locationGranted ? Colors.greenAccent.shade400 : null,
            ),
            icon: Icon(
              _locationGranted ? Icons.check_circle : Icons.my_location,
            ),
            label: Text(_locationGranted ? 'Location locked in' : 'Use my location'),
          )
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _aliasController,
          decoration: const InputDecoration(
            labelText: 'Call sign',
            helperText: 'What other locals will see.',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Contact (email or phone)',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Play style',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: const [
                  _ModeChip(label: 'Explorer'),
                  _ModeChip(label: 'Strategist'),
                  _ModeChip(label: 'Speed Runner'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: const Color(0xFF5F5BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _enterArena,
            child: const Text(
              'Enter Local Arena',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatefulWidget {
  final String label;
  const _ModeChip({required this.label});

  @override
  State<_ModeChip> createState() => _ModeChipState();
}

class _ModeChipState extends State<_ModeChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      selectedColor: Colors.white.withValues(alpha: 0.2),
      checkmarkColor: Colors.white,
    );
  }
}
