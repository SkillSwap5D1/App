import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../browse/browse_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../requests/requests_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedIndex = 0;
  String? _initializedForUid;

  final List<Widget> _screens = const [
    BrowseScreen(),
    RequestsScreen(),
    ChatListScreen(),
    ProfileScreen(),
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
      if (auth.currentUser == null || auth.isLoading) {
        _loadData();
        return;
      }

      final uid = auth.currentUser?.uid;
      if (uid == null || uid == _initializedForUid) return;

      _initializedForUid = uid;

      try {
        context.read<ListingProvider>().loadListings();
      } catch (_) {}

      try {
        context.read<RequestProvider>().loadRequests(uid);
      } catch (_) {}

      try {
        context.read<ChatProvider>().loadConversations(uid);
      } catch (_) {}

      try {
        context.read<NotificationProvider>().loadNotifications(uid);
      } catch (_) {}
    });
  }

  void _setSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
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
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildTopNavigation(context),
              Expanded(child: _screens[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopNavigation(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 760;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              if (!compact) ...[
                const Icon(Icons.school_rounded, color: AppColors.primary, size: 26),
                const SizedBox(width: 10),
                Text('SkillSwap', style: AppTextStyles.h3),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TopNavButton(
                      icon: Icons.home_rounded,
                      label: 'Browse',
                      active: _selectedIndex == 0,
                      onTap: () => _setSelectedIndex(0),
                    ),
                    _TopNavButton(
                      icon: Icons.inbox_rounded,
                      label: 'Requests',
                      active: _selectedIndex == 1,
                      onTap: () => _setSelectedIndex(1),
                    ),
                    _TopNavButton(
                      icon: Icons.message_rounded,
                      label: 'Messages',
                      active: _selectedIndex == 2,
                      onTap: () => _setSelectedIndex(2),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        final active = _selectedIndex == 4;
                        final hasUnread = notificationProvider.unreadCount > 0;
                        return _TopNavButton(
                          icon: Icons.notifications_rounded,
                          label: 'Alerts',
                          active: active,
                          showBadge: hasUnread,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    _TopNavButton(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      active: _selectedIndex == 3,
                      onTap: () => _setSelectedIndex(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool showBadge;
  final VoidCallback onTap;

  const _TopNavButton({
    required this.icon,
    required this.label,
    required this.active,
    this.showBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.primary.withValues(alpha: 0.20) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: active ? AppColors.primary : AppColors.textMuted,
                  ),
                  if (showBadge)
                    const Positioned(
                      right: -3,
                      top: -3,
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
