import 'package:flutter/material.dart';
import 'training_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int index = 0;
  final profileKey = GlobalKey<ProfileScreenState>();

  final keys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget page) {
    return Navigator(
      key: key,
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {

        final navigator = keys[index].currentState!;

        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        if (index != 0) {
          setState(() {
            index = 0;
          });
          return;
        }
      },

      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            _buildNavigator(keys[0], const TrainingScreen()),
            _buildNavigator(
              keys[1],
              ProfileScreen(key: profileKey),
            ),
            _buildNavigator(keys[2], const SettingsScreen()),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: index,
          onTap: (i) {
            if (i == index) {
              keys[i].currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                index = i;
              });

              if (i == 1) {
                profileKey.currentState?.refreshProfile();
              }
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/list_icon.png',
                width: 31,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/profile_icon.png',
                width: 31,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/settings_icon.png',
                width: 31,
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}