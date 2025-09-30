import 'package:flutter/material.dart';

// Note: The AuthCubit and BlocProvider are not needed for this page's UI,
// but you would keep them in your real app's main file for overall auth state.

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // State variables to hold the current settings values
  bool _criticalAlertsEnabled = true;
  bool _schemeNotificationsEnabled = true;
  bool _weeklySummaryEnabled = false;
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0D47A1), // Consistent app bar color
      ),
      // backgroundColor: const Color(0xFFF4F6F8), // Consistent background color
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Notifications"),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Critical Water Level Alerts"),
                  subtitle: const Text("Receive alerts for 'Critical' zones"),
                  value: _criticalAlertsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _criticalAlertsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.warning_amber_rounded),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("New Scheme Announcements"),
                  subtitle: const Text("Get notified about new government schemes"),
                  value: _schemeNotificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _schemeNotificationsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.campaign_outlined),
                ),
                 const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Weekly Summary Report"),
                  subtitle: const Text("Receive a report every Monday morning"),
                  value: _weeklySummaryEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _weeklySummaryEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.summarize_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Appearance"),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text("Theme"),
              subtitle: Text(_getThemeString(_selectedTheme)),
              onTap: () => _showThemeDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("About & Support"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About Jal Vibhag"),
                  subtitle: const Text("Version 1.0.0"),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text("Privacy Policy"),
                  onTap: () {},
                ),
                 const Divider(height: 1),
                 ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Help & Support"),
                  onTap: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// A helper widget to create styled section headers.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Shows a dialog to select the app theme.
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: _selectedTheme,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                  // TODO: Add logic to actually change the app's theme
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: _selectedTheme,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                   Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: _selectedTheme,
                onChanged: (ThemeMode? value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                   Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Converts the ThemeMode enum to a readable string.
  String _getThemeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "lightMode";
      case ThemeMode.dark:
        return "darkMode";
      case ThemeMode.system:
      return "System Default";
    }
  }
}