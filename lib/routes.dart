// lib/routes.dart
import 'package:flutter/material.dart';

import 'data/models.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/level_detail_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String level = '/level';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name;

    if (name == login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    } else if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == map) {
      return MaterialPageRoute(builder: (_) => const MapScreen());
    } else if (name == profile) {
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    } else if (name == settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else if (name == level) {
      final levelArg = settings.arguments as Level;
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => LevelDetailScreen(level: levelArg),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      );
    }

    // Fallback
    return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
