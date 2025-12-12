import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundOn = true;
  bool shareLocation = true;
  bool autoMatch = true;
  bool haptics = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Control Center",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Sound FX"),
            value: soundOn,
            onChanged: (value) {
              setState(() => soundOn = value);
            },
          ),
          SwitchListTile(
            title: const Text("Share precise location"),
            subtitle: const Text("Required to anchor you inside a territory ring."),
            value: shareLocation,
            onChanged: (value) {
              setState(() => shareLocation = value);
            },
          ),
          SwitchListTile(
            title: const Text("Auto join contested matches"),
            subtitle: const Text("We’ll ping you when a nearby district needs help."),
            value: autoMatch,
            onChanged: (value) {
              setState(() => autoMatch = value);
            },
          ),
          SwitchListTile(
            title: const Text("Haptics"),
            subtitle: const Text("Vibrate on correct answers and control swings."),
            value: haptics,
            onChanged: (value) {
              setState(() => haptics = value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.radar),
            title: const Text("Recalibrate location"),
            subtitle: const Text("Force a GPS scan if things feel off."),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Recalibration started...")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About This Game"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "TriviaTrail",
                applicationVersion: "1.0.0",
              );
            },
          ),
        ],
      ),
    );
  }
}
