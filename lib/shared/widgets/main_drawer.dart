import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:jal_shakti_app/features/about/presentation/about_us_screen.dart';
import 'package:jal_shakti_app/features/about/presentation/contact_us_screen.dart';
import 'package:jal_shakti_app/features/complaints/presentation/complaint_screen.dart';
import 'package:jal_shakti_app/features/profile/presentation/profile_screen.dart';
import 'package:jal_shakti_app/features/reports/presentation/reports_screen.dart';
import 'package:jal_shakti_app/features/settings/presentation/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  // --- NEW: Callback to notify the parent (MainScreen) about a selection ---
  final Function(int) onSelectItem;

  const MainDrawer({super.key, required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _createHeader(context),
          // --- Main App Sections (now use the callback) ---
          _createDrawerItem(
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              onSelectItem(0); // Select Home screen (index 0)
            },
          ),
          _createDrawerItem(
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              onSelectItem(1); // Select Dashboard screen (index 1)
            },
          ),
          _createDrawerItem(
            icon: Icons.map_outlined,
            text: 'DWLR Map',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              onSelectItem(2); // Select Map screen (index 2)
            },
          ),
          _createDrawerItem(
            icon: Icons.work_outline,
            text: 'Profession Section',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              onSelectItem(3); // Select Profession screen (index 3)
            },
          ),
          const Divider(),
          // --- Informational Pages (still use standard navigation) ---
          _createDrawerItem(
            icon: Icons.article_outlined,
            text: 'Reports',
            onTap: () => _navigateTo(context, const ReportsScreen()),
          ),
          _createDrawerItem(
            icon: Icons.info_outline,
            text: 'About Us',
            onTap: () => _navigateTo(context, const AboutUsScreen()),
          ),
          _createDrawerItem(
            icon: Icons.contact_mail_outlined,
            text: 'Contact Us',
            onTap: () => _navigateTo(context, const ContactUsScreen()),
          ),
          const Expanded(child: SizedBox()),
          const Divider(),
          // --- User Account & Actions ---
          _createDrawerItem(
            icon: Icons.report_problem_outlined,
            text: 'Lodge a Complaint',
            onTap: () => _navigateTo(context, const ComplaintPage()),
          ),
          _createDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            onTap: () => _navigateTo(context, const SettingPage()),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- MODIFIED: This is now only for pages NOT on the main bottom nav bar ---
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // Close the drawer first
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => screen,
    ));
  }

  Widget _createHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: const Text('Guest User'),
      accountEmail: const Text('Tap to view profile'),
      onDetailsPressed: () => _navigateTo(context, const ProfileScreen()),
      currentAccountPicture: GestureDetector(
        onTap: () => _navigateTo(context, const ProfileScreen()),
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 40),
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
