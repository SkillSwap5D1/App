import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../browse/browse_screen.dart';
import '../requests/requests_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedIndex = 0;
  String? _initializedForUid;

  final List<Widget> _screens = [
    const BrowseScreen(),
    const RequestsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final auth = context.read<AuthProvider>();
      final uid = auth.currentUser?.uid;

      if (uid == null || uid == _initializedForUid) {
        return;
      }

      _initializedForUid = uid;

      context.read<ListingProvider>().loadListings();
      context.read<RequestProvider>().loadRequests(uid);
      context.read<ChatProvider>().loadConversations(uid);
      context.read<NotificationProvider>().loadNotifications(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              border: Border(
                top: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppColors.accent,
                unselectedItemColor: AppColors.textMuted,
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Browse',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inbox_rounded),
                    label: 'Requests',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_rounded),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
