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
  late PageController _pageController;

  final List<Widget> _screens = [
    const BrowseScreen(),
    const RequestsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize all data streams on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final uid = authProvider.currentUser!.uid;
        context.read<ListingProvider>().loadListings();
        context.read<RequestProvider>().loadRequests(uid);
        context.read<ChatProvider>().loadConversations(uid);
        context.read<NotificationProvider>().loadNotifications(uid);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildRequestsBadge(),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: _buildChatBadge(),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsBadge() {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, _) {
        final badgeCount = requestProvider.pendingCount;
        if (badgeCount == 0) {
          return const Icon(Icons.inbox_rounded);
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.inbox_rounded),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatBadge() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final badgeCount = chatProvider.totalUnreadCount;
        if (badgeCount == 0) {
          return const Icon(Icons.chat_bubble_rounded);
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.chat_bubble_rounded),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
