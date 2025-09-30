// import 'package:flutter/material.dart';
// import 'package:jal_shakti_app/core/theme/app_theme.dart';
// import 'package:jal_shakti_app/features/about/presentation/about_us_screen.dart';
// import 'package:jal_shakti_app/features/about/presentation/contact_us_screen.dart';
// import 'package:jal_shakti_app/features/complaints/presentation/complaint_screen.dart';
// import 'package:jal_shakti_app/features/dashboard/presentation/dashboard_screen.dart';
// import 'package:jal_shakti_app/features/home/presentation/home_screen.dart';
// import 'package:jal_shakti_app/features/map/presentation/map_screen.dart';
// import 'package:jal_shakti_app/features/profession/presentation/profession_screen.dart';
// import 'package:jal_shakti_app/features/profile/presentation/profile_screen.dart';
// import 'package:jal_shakti_app/features/reports/presentation/reports_screen.dart';
// import 'package:jal_shakti_app/features/settings/presentation/settings_screen.dart';

// class MainDrawer extends StatelessWidget {
//   const MainDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           _createHeader(context),
//           // --- Main App Sections ---
//           _createDrawerItem(
//             icon: Icons.home_outlined,
//             text: 'Home',
//             onTap: () => _navigateTo(context, const HomeScreen()), // Closes drawer, stays on MainScreen
//           ),
//           _createDrawerItem(
//             icon: Icons.dashboard_outlined,
//             text: 'Dashboard',
//             onTap: () => _navigateTo(context, DashboardScreen()),
//           ),
//            _createDrawerItem(
//             icon: Icons.map_outlined,
//             text: 'DWLR Map',
//             onTap: () => _navigateTo(context, MapScreen()),
//           ),
//           _createDrawerItem(
//             icon: Icons.work_outline,
//             text: 'Profession Section',
//             onTap: () => _navigateTo(context, ProfessionScreen()),
//           ),
//           const Divider(),
//           // --- Informational Pages ---
//            _createDrawerItem(
//             icon: Icons.article_outlined,
//             text: 'Reports',
//             onTap: () => _navigateTo(context, const ReportsScreen()),
//           ),
//           _createDrawerItem(
//             icon: Icons.info_outline,
//             text: 'About Us',
//             onTap: () => _navigateTo(context, const AboutUsScreen()),
//           ),
//           _createDrawerItem(
//             icon: Icons.contact_mail_outlined,
//             text: 'Contact Us',
//             onTap: () => _navigateTo(context, const ContactUsScreen()),
//           ),
//           const Expanded(child: SizedBox()),
//           const Divider(),
//           // --- User Account & Actions ---
//            _createDrawerItem(
//             icon: Icons.report_problem_outlined,
//             text: 'Lodge a Complaint',
//             onTap: () => _navigateTo(context, const ComplaintPage()),
//           ),
//           _createDrawerItem(
//             icon: Icons.settings_outlined,
//             text: 'Settings',
//             onTap: () => _navigateTo(context, const SettingPage()),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // Helper method for cleaner navigation
//   void _navigateTo(BuildContext context, Widget screen) {
//     Navigator.of(context).pop(); // Close the drawer first
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (_) => screen,
//     ));
//   }

//   Widget _createHeader(BuildContext context) {
//     // The entire header is tappable to navigate to the profile screen.
//     return UserAccountsDrawerHeader(
//       accountName: const Text('Guest User'),
//       accountEmail: const Text('Tap to view profile'),
//       onDetailsPressed: () => _navigateTo(context, const ProfileScreen()),
//       currentAccountPicture: GestureDetector(
//         onTap: () => _navigateTo(context, const ProfileScreen()),
//         child: const CircleAvatar(
//           backgroundColor: Colors.white,
//           child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 40),
//         ),
//       ),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     );
//   }

//   Widget _createDrawerItem({
//     required IconData icon,
//     required String text,
//     required GestureTapCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: AppTheme.primaryBlue),
//       title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
//       onTap: onTap,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:jal_shakti_app/features/about/presentation/about_us_screen.dart';
import 'package:jal_shakti_app/features/about/presentation/contact_us_screen.dart';
import 'package:jal_shakti_app/features/complaints/presentation/complaint_screen.dart';
import 'package:jal_shakti_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:jal_shakti_app/features/home/presentation/home_screen.dart';
import 'package:jal_shakti_app/features/map/presentation/map_screen.dart';
import 'package:jal_shakti_app/features/profession/presentation/profession_screen.dart';
import 'package:jal_shakti_app/features/profile/presentation/profile_screen.dart';
import 'package:jal_shakti_app/features/reports/presentation/reports_screen.dart';
import 'package:jal_shakti_app/features/settings/presentation/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _createHeader(context),
          // --- Main App Sections ---
          _createDrawerItem(
            icon: Icons.home_outlined,
            text: 'Home',
            onTap: () => _navigateTo(context, const HomeScreen()),
          ),
          _createDrawerItem(
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () => _navigateTo(context, DashboardScreen()),
          ),
          _createDrawerItem(
            icon: Icons.map_outlined,
            text: 'DWLR Map',
            onTap: () => _navigateTo(context, MapScreen()),
          ),
          _createDrawerItem(
            icon: Icons.work_outline,
            text: 'Profession Section',
            onTap: () => _navigateTo(context, ProfessionScreen()),
          ),
          const Divider(),
          // --- Informational Pages ---
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
            // FIX: Corrected class name from ComplaintPage to ComplaintScreen
            onTap: () => _navigateTo(context, const ComplaintPage()),
          ),
          _createDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            // FIX: Corrected class name from SettingPage to SettingsScreen
            onTap: () => _navigateTo(context, const SettingPage()),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper method for cleaner navigation
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // Close the drawer first

    // IMPROVEMENT: Used pushReplacement to avoid stacking pages.
    // This replaces the current screen with the new one instead of adding
    // it to the top of the navigation stack.
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => screen,
    ));
  }

  Widget _createHeader(BuildContext context) {
    // The entire header is tappable to navigate to the profile screen.
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