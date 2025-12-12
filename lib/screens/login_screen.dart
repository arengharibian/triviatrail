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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4EB9FF), Color(0xFF3F6BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF40E5FF),
                              Color(0xFF2A9BFF),
                              Color(0xFF0060FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TRIVIA',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    shadows: const [
                                      Shadow(offset: Offset(0, 4), color: Colors.black26),
                                    ],
                                  ),
                            ),
                            Text(
                              'GAME',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    shadows: const [
                                      Shadow(offset: Offset(0, 4), color: Colors.black26),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Continue with',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSocialButtons(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('or sign in via phone number'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'By continuing, you agree to the Terms and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    const socials = [
      (Icons.apple, 'Continue with Apple'),
      (Icons.g_mobiledata, 'Continue with Google'),
      (Icons.facebook, 'Continue with Facebook'),
    ];

    return Column(
      children: socials
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D0D25),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                icon: Icon(s.$1),
                label: Text(s.$2),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link your call sign',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(_status, style: const TextStyle(color: Color(0xFF63637A))),
          const SizedBox(height: 20),
          TextField(
            controller: _aliasController,
            decoration: const InputDecoration(
              labelText: 'Call sign',
              helperText: 'Displayed to nearby rivals.',
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
          Row(
            children: [
              Icon(
                _locationGranted ? Icons.check_circle : Icons.location_searching,
                color: _locationGranted ? Colors.green : Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationGranted
                      ? 'Location locked • ready to deploy'
                      : 'Allow GPS so we can anchor trivia around you.',
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _requestingLocation ? null : _requestLocation,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _locationGranted ? const Color(0xFF21C57A) : const Color(0xFF5F5BFF),
                ),
                child: Text(_locationGranted ? 'Good to go' : 'Share GPS'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enterArena,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFF2326FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text(
                'Launch Arena',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
