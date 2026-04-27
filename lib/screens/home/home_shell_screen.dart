import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../browse/browse_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    BrowseScreen(),
    BrowseScreen(), // Search screen - showing browse for now
    ChatListScreen(),
    ProfileScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          height: 64,
          onDestinationSelected: _onNavItemTapped,
          selectedIndex: _selectedIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: Colors.transparent,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_rounded,
                color: _selectedIndex == 0
                    ? AppColors.accent
                    : AppColors.textMuted,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search_rounded,
                color: _selectedIndex == 1
                    ? AppColors.accent
                    : AppColors.textMuted,
              ),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.chat_bubble_rounded,
                color: _selectedIndex == 2
                    ? AppColors.accent
                    : AppColors.textMuted,
              ),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_rounded,
                color: _selectedIndex == 3
                    ? AppColors.accent
                    : AppColors.textMuted,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
