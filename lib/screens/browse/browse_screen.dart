import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../listings/listing_detail_screen.dart';
import '../requests/send_request_screen.dart';
import '../requests/requests_screen.dart';
import '../requests/counter_offer_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_bookmarked_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  String _selectedTab = 'Available';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedFormat = 'All Formats';

  final TextEditingController _searchController = TextEditingController();

  // ── FILTERED LISTINGS ──────────────────────────────────────────────────────
  List<MockListing> get _filteredListings {
    final source =
        _selectedTab == 'Available' ? MockData.listings : MockData.myListings;

    return source.where((listing) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          listing.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;

      final matchesLevel =
          _selectedLevel == 'All Levels' || listing.level == _selectedLevel;

      final matchesFormat =
          _selectedFormat == 'All Formats' ||
          listing.modality == _selectedFormat;

      return matchesSearch && matchesCategory && matchesLevel && matchesFormat;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Skills'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      drawer: _buildNavigationDrawer(context),
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildSidebar(), Expanded(child: _buildListingGrid())],
            ),
          ),
        ],
      ),
    );
  }

  // ── LISTING GRID ────────────────────────────────────────────────────────────
  Widget _buildListingGrid() {
    final listings = _filteredListings;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${listings.length} skill${listings.length == 1 ? '' : 's'} found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                listings.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: (listings.length / 2).ceil(),
                      addAutomaticKeepAlives: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final startIndex = index * 2;
                        final endIndex = (startIndex + 2 < listings.length)
                            ? startIndex + 2
                            : listings.length;
                        final rowListings =
                            listings.sublist(startIndex, endIndex);
                        return _buildListingRow(rowListings);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // ── LISTING ROW ───────────────────────────────────────────────────────────
  Widget _buildListingRow(List<MockListing> rowListings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child:
          rowListings.length > 1
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 350,
                      child: _buildListingCard(rowListings[0]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 350,
                      child: _buildListingCard(rowListings[1]),
                    ),
                  ),
                ],
              )
              : SizedBox(
                height: 350,
                child: _buildListingCard(rowListings[0]),
              ),
    );
  }

  // ── LISTING CARD ────────────────────────────────────────────────────────────
  Widget _buildListingCard(MockListing listing) {
    final isMySkills = _selectedTab == 'My Skills';
    final initials =
        listing.ownerName.isNotEmpty ? listing.ownerName[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(listing.ownerName, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${listing.ownerRating} (${listing.ownerReviewCount})',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            listing.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                listing.tags
                    .map<Widget>(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(listing.nextAvailable, style: AppTextStyles.caption),
              const SizedBox(width: 12),
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(listing.modality, style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          if (isMySkills) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteDialog(listing),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Send Request'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      listing.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color:
                          listing.isBookmarked
                              ? AppColors.primary
                              : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── SIDEBAR ─────────────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  _buildTabButton('Available'),
                  _buildTabButton('My Skills'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSidebarLabel('SEARCH'),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search skills...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('CATEGORY'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedCategory,
              items: MockData.categories,
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('LEVEL'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedLevel,
              items: MockData.levels,
              onChanged: (val) => setState(() => _selectedLevel = val!),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('FORMAT'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedFormat,
              items: MockData.formats,
              onChanged: (val) => setState(() => _selectedFormat = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected ? AppShadows.card : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Available' ? Icons.search : Icons.grid_view,
                size: 14,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      ),
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No skills found',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── DELETE DIALOG ───────────────────────────────────────────────────────────
  void _showDeleteDialog(MockListing listing) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: const Text('Delete Listing'),
            content: Text(
              'Are you sure you want to delete "${listing.title}"? '
              'This cannot be undone.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: AppTextStyles.bodyMedium,
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: AppTextStyles.bodyMedium),
                ),
              )
              .toList(),
    );
  }

  // ── HERO SECTION ──────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF9), Color(0xFFFFF7ED), Color(0xFFF8F7F4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Discover & Exchange',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Find Skills to Learn', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Browse skills offered by students at your university\nand start learning today.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── NAVIGATION DRAWER ──────────────────────────────────────────────────────
  Widget _buildNavigationDrawer(BuildContext context) {
    // Sample data for navigation
    final sampleListing = MockData.listings.isNotEmpty
        ? MockData.listings.first
        : MockListing(
            id: '1',
            ownerId: 'user1',
            ownerName: 'John Doe',
            ownerRating: 4.5,
            ownerReviewCount: 12,
            title: 'Web Development',
            category: 'Programming',
            level: 'Intermediate',
            modality: 'Online',
            description: 'Learn web development basics',
            nextAvailable: 'Tomorrow',
            tags: ['Web', 'Design'],
            isBookmarked: false,
          );

    final sampleRequest = MockData.incomingRequests.isNotEmpty
        ? MockData.incomingRequests.first
        : MockRequest(
            id: '1',
            fromUserId: 'user1',
            fromUserName: 'John Doe',
            listingId: '1',
            skillName: 'Web Development',
            message: 'Looking forward to learning web dev!',
            status: 'pending',
            timeAgo: '2h ago',
            proposedTimes: ['Monday 3pm', 'Tuesday 4pm'],
          );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SkillSwap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'All Screens',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            number: 4,
            title: 'Browse Skills',
            icon: Icons.search,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            number: 6,
            title: 'Listing Detail',
            icon: Icons.description,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: sampleListing),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 7,
            title: 'Send Request',
            icon: Icons.send,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendRequestScreen(listing: sampleListing),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 8,
            title: 'Requests',
            icon: Icons.inbox,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RequestsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 10,
            title: 'Counter Offer',
            icon: Icons.schedule,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CounterOfferScreen(originalRequest: sampleRequest),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 11,
            title: 'Chat',
            icon: Icons.chat,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 12,
            title: 'Profile',
            icon: Icons.person,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            number: 13,
            title: 'Saved',
            icon: Icons.bookmark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SavedBookmarkedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int number,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'S$number',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: Text(title),
      trailing: Icon(icon, size: 18, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
