import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Profile",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/avatar.png'),
              // Add your own avatar image to assets/images OR change to Icon(Icons.person)
            ),
            const SizedBox(height: 16),
            Text(
              "Player 1",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const Text("Best Score: TBD"),
            const Text("Levels Completed: TBD"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // eventually: logout or change name
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit profile coming soon")),
                );
              },
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
