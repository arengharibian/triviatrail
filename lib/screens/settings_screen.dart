import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundOn = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Settings",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Sound Effects"),
            value: soundOn,
            onChanged: (value) {
              setState(() => soundOn = value);
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
