import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'browse/browse_screen.dart';
import 'listings/listing_detail_screen.dart';
import 'requests/send_request_screen.dart';
import 'requests/requests_screen.dart';
import 'requests/counter_offer_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart';
import 'saved/saved_bookmarked_screen.dart';
import '../data/mock_data.dart';

class ScreensMenu extends StatelessWidget {
  const ScreensMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      _ScreenItem(
        number: 4,
        title: 'Browse Skills',
        description: 'Browse and filter available skills with search',
        icon: Icons.search,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BrowseScreen()),
        ),
      ),
      _ScreenItem(
        number: 5,
        title: 'Browse Tabs',
        description: 'Tab switching between Available and My Skills',
        icon: Icons.category,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BrowseScreen()),
        ),
      ),
      _ScreenItem(
        number: 6,
        title: 'Listing Detail',
        description: 'View skill listing with owner details and request button',
        icon: Icons.info,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              listing: _sampleListing,
            ),
          ),
        ),
      ),
      _ScreenItem(
        number: 7,
        title: 'Send Request',
        description: 'Request a lesson with time slot selection',
        icon: Icons.event,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SendRequestScreen(listing: _sampleListing),
          ),
        ),
      ),
      _ScreenItem(
        number: 8,
        title: 'Requests - Incoming',
        description: 'Manage incoming lesson requests with actions',
        icon: Icons.inbox,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RequestsScreen()),
        ),
      ),
      _ScreenItem(
        number: 9,
        title: 'Requests - Outgoing',
        description: 'View outgoing requests with status tracking',
        icon: Icons.send,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RequestsScreen()),
        ),
      ),
      _ScreenItem(
        number: 10,
        title: 'Counter Offer',
        description: 'Propose alternative times for a request',
        icon: Icons.schedule,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CounterOfferScreen(
              originalRequest: _sampleRequest,
            ),
          ),
        ),
      ),
      _ScreenItem(
        number: 11,
        title: 'Chat List',
        description: 'View all active conversations',
        icon: Icons.message,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        ),
      ),
      _ScreenItem(
        number: 12,
        title: 'Profile',
        description: 'User profile with privacy settings',
        icon: Icons.person,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      _ScreenItem(
        number: 13,
        title: 'Saved Bookmarks',
        description: 'View bookmarked skills and saved listings',
        icon: Icons.bookmark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedBookmarkedScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SkillSwap - Screens'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final screen = screens[index];
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: _buildScreenCard(context, screen),
          );
        },
      ),
    );
  }

  Widget _buildScreenCard(BuildContext context, _ScreenItem screen) {
    return GestureDetector(
      onTap: screen.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'S${screen.number}',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screen.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      screen.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _sampleListing = MockListing(
    id: 'skill_001',
    ownerId: 'user_001',
    ownerName: 'Sarah Anderson',
    ownerRating: 4.8,
    ownerReviewCount: 24,
    title: 'Web Development Bootcamp',
    description: 'Learn modern web development with React and Node.js.',
    tags: ['React', 'JavaScript', 'Web Development'],
    level: 'Intermediate',
    modality: 'Online',
    category: 'Programming',
    nextAvailable: 'Tomorrow, 3 PM',
    isBookmarked: false,
  );

  static final _sampleRequest = MockRequest(
    id: 'req_001',
    fromUserId: 'user_002',
    fromUserName: 'John Doe',
    listingId: 'skill_001',
    skillName: 'Web Development Bootcamp',
    message: 'Really interested in learning React. Can we schedule ASAP?',
    status: 'pending',
    timeAgo: '2 hours ago',
    proposedTimes: ['Tomorrow 3 PM', 'Thursday 5 PM'],
  );
}

class _ScreenItem {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  _ScreenItem({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}
