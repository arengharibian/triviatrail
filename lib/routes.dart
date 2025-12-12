// lib/routes.dart
import 'package:flutter/material.dart';

import 'data/models.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/territory_battle_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String battle = '/battle';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name;

    if (name == null || name == '/') {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    } else if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == map) {
      return MaterialPageRoute(builder: (_) => const MapScreen());
    } else if (name == profile) {
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    } else if (name == AppRoutes.settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else if (name == AppRoutes.battle) {
      final territory = settings.arguments as Territory;
      return PageRouteBuilder(
        pageBuilder: (_, __, ___) => TerritoryBattleScreen(territory: territory),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      );
    }

    // Fallback
    return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
