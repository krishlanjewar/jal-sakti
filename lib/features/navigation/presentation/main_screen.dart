import 'package:flutter/material.dart';
import 'package:jal_shakti_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:jal_shakti_app/features/home/presentation/home_screen.dart';
import 'package:jal_shakti_app/features/map/presentation/map_screen.dart';
import 'package:jal_shakti_app/features/profession/presentation/profession_screen.dart';
import 'package:jal_shakti_app/shared/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of the pages to be displayed
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    DashboardScreen(),
    MapScreen(),
    ProfessionScreen(),
  ];

  // List of the titles for the AppBar
  static const List<String> _widgetTitles = <String>[
    'Jal Shakti',
    'Dashboard',
    'Map',
    'Profession',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to Profile Page
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MainDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Profession',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
      ),
    );
  }
}
