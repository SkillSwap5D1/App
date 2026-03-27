import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
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
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          height: 64,
          onDestinationSelected: _onNavItemTapped,
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_rounded,
                color: _selectedIndex == 0
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search_rounded,
                color: _selectedIndex == 1
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.chat_bubble_rounded,
                color: _selectedIndex == 2
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_rounded,
                color: _selectedIndex == 3
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
