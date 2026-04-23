import 'package:flutter/material.dart';
import 'training_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class NavigationMenu extends StatefulWidget {
  final int initialIndex;

  const NavigationMenu({super.key, this.initialIndex = 0});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    TrainingScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/list_icon.png', width: 31),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/profile_icon.png', width: 31),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/settings_icon.png', width: 31),
          label: "",
        ),
      ],
    );
  }
}
