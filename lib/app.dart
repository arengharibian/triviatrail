import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/level_detail_screen.dart';
import 'data/models.dart';

class TriviaTrailApp extends StatelessWidget {
  const TriviaTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriviaTrail',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/':
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/map':
            return MaterialPageRoute(builder: (_) => const MapScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/level':
            final level = settings.arguments as Level;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => LevelDetailScreen(level: level),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}

// Common drawer for navigation
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? fab;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.fab,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'TriviaTrail',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            _drawerItem(
              context,
              icon: Icons.home,
              label: 'Home',
              route: '/home',
            ),
            _drawerItem(
              context,
              icon: Icons.map,
              label: 'Trail Map',
              route: '/map',
            ),
            _drawerItem(
              context,
              icon: Icons.person,
              label: 'Profile',
              route: '/profile',
            ),
            _drawerItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              route: '/settings',
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: fab,
    );
  }

  ListTile _drawerItem(
      BuildContext context, {required IconData icon, required String label, required String route}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
