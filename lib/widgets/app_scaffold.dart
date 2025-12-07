// lib/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../routes.dart';

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
              route: AppRoutes.home,
            ),
            _drawerItem(
              context,
              icon: Icons.map,
              label: 'Trail Map',
              route: AppRoutes.map,
            ),
            _drawerItem(
              context,
              icon: Icons.person,
              label: 'Profile',
              route: AppRoutes.profile,
            ),
            _drawerItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              route: AppRoutes.settings,
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: fab,
    );
  }

  ListTile _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
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
