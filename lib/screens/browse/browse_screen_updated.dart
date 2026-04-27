import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/widgets/empty_state.dart';
import 'package:skillswap_app/widgets/snackbar_helper.dart';
import 'package:skillswap_app/widgets/badge_widget.dart';
import 'package:skillswap_app/models/listing_model.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late TextEditingController _searchController;
  String _activeTab = 'browse';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All';
  String _selectedFormat = 'All';
  Set<String> _bookmarkedListings = {};

  static const List<String> categories = [
    'All',
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Data Science',
    'Art',
  ];

  static const List<String> levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  static const List<String> formats = ['All', 'In-person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: _activeTab == 'browse' ? _buildBrowseTab() : _buildMySkillsTab(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('SkillSwap', style: AppTextStyles.h3),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        BadgeWidget(
          count: 3,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: CircleAvatar(
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.person, color: AppColors.surface),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search skills...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _buildFilterChip(
            'Category',
            _selectedCategory,
            categories,
            (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            'Level',
            _selectedLevel,
            levels,
            (value) => setState(() => _selectedLevel = value),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            'Format',
            _selectedFormat,
            formats,
            (value) => setState(() => _selectedFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selected,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => options
          .map((option) => PopupMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected, style: AppTextStyles.bodySmall),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeTab = 'browse'),
              child: Text(
                'Available',
                style: _activeTab == 'browse'
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      )
                    : AppTextStyles.bodyLarge,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeTab = 'my'),
              child: Text(
                'My Skills',
                style: _activeTab == 'my'
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      )
                    : AppTextStyles.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Consumer<ListingProvider>(
      builder: (context, provider, _) {
        // Filter listings - for now just use all listings
        final listings = provider.listings;

        if (listings.isEmpty) {
          return EmptyState.listing(
            onBrowse: () => _searchController.clear(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic would go here
            await Future.delayed(const Duration(seconds: 1));
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.55,
            ),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _buildListingCard(listing);
            },
          ),
        );
      },
    );
  }

  Widget _buildMySkillsTab() {
    return Consumer<ListingProvider>(
      builder: (context, provider, _) {
        final authProvider = context.read<AuthProvider>();
        
        // Filter user's own listings
        final myListings = provider.listings
            .where((l) => l.ownerId == authProvider.currentUser?.uid)
            .toList();

        if (myListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, size: 64, color: AppColors.border),
                const SizedBox(height: AppSpacing.lg),
                Text('No listings yet', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                  ),
                  child: const Text('+ Create Listing'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: myListings.length,
          itemBuilder: (context, index) {
            final listing = myListings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text(listing.category),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateListingScreen(listing: listing),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Delete', style: TextStyle(color: AppColors.error)),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete listing?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed ?? false) {
                          if (mounted) {
                            SnackBarHelper.success(context, 'Listing deleted');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListingCard(ListingModel listing) {
    final isBookmarked = _bookmarkedListings.contains(listing.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listing: listing),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with bookmark
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      listing.ownerName[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.surface),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked ? AppColors.accent : null,
                    ),
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        if (isBookmarked) {
                          _bookmarkedListings.remove(listing.id);
                        } else {
                          _bookmarkedListings.add(listing.id);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                listing.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Owner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                listing.ownerName,
                style: AppTextStyles.bodySmall,
              ),
            ),
            // Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('4.5 (12)', style: AppTextStyles.caption),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Wrap(
                spacing: 4,
                children: listing.tags
                    .take(2)
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: AppTextStyles.caption),
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            // Send Request Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.success(context, 'Feature coming soon');
                  },
                  child: Text('Send Request', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late TextEditingController _searchController;
  String _activeTab = 'browse'; // 'browse' or 'my'
  String _selectedCategory = 'All';
  String _selectedLevel = 'All';
  String _selectedFormat = 'All';
  Set<String> _bookmarkedListings = {};

  static const List<String> categories = [
    'All',
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Data Science',
    'Art',
  ];

  static const List<String> levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  static const List<String> formats = ['All', 'In-person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: _activeTab == 'browse' ? _buildBrowseTab() : _buildMySkillsTab(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('SkillSwap', style: AppTextStyles.h3),
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        BadgeWidget(
          count: 3,
          child: IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: CircleAvatar(
            backgroundColor: AppColors.accent,
            child: Icon(Icons.person, color: AppColors.surface),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search skills...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _buildFilterChip(
            'Category',
            _selectedCategory,
            categories,
            (value) => setState(() => _selectedCategory = value),
          ),
          SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            'Level',
            _selectedLevel,
            levels,
            (value) => setState(() => _selectedLevel = value),
          ),
          SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            'Format',
            _selectedFormat,
            formats,
            (value) => setState(() => _selectedFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selected,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => options
          .map((option) => PopupMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected, style: AppTextStyles.bodySmall),
            SizedBox(width: AppSpacing.xs),
            Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeTab = 'browse'),
              child: Text(
                'Available',
                style: _activeTab == 'browse'
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      )
                    : AppTextStyles.bodyLarge,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeTab = 'my'),
              child: Text(
                'My Skills',
                style: _activeTab == 'my'
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      )
                    : AppTextStyles.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Consumer<ListingProvider>(
      builder: (context, provider, _) {
        // Filter listings
        final filtered = _filterListings(provider.listings);

        if (filtered.isEmpty) {
          return EmptyState.listing(
            onBrowse: () => _searchController.clear(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchListings();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.55,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final listing = filtered[index];
              return _buildListingCard(listing);
            },
          ),
        );
      },
    );
  }

  Widget _buildMySkillsTab() {
    return Consumer<ListingProvider>(
      builder: (context, provider, _) {
        // Filter user's own listings
        final myListings = provider.listings
            .where((l) => l.ownerId == provider.currentUserId)
            .toList();

        if (myListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 64, color: AppColors.border),
                SizedBox(height: AppSpacing.lg),
                Text('No listings yet', style: AppTextStyles.h3),
                SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateListingScreen()),
                  ),
                  child: Text('+ Create Listing'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: myListings.length,
          itemBuilder: (context, index) {
            final listing = myListings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text(listing.category),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Edit'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateListingScreen(listing: listing),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Delete', style: TextStyle(color: AppColors.error)),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete listing?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed ?? false) {
                          await context.read<ListingProvider>().deleteListing(listing.id);
                          if (mounted) {
                            SnackBarHelper.success(context, 'Listing deleted');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListingCard(ListingModel listing) {
    final isBookmarked = _bookmarkedListings.contains(listing.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listing: listing),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with bookmark
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      listing.ownerName[0].toUpperCase(),
                      style: TextStyle(color: AppColors.surface),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked ? AppColors.accent : null,
                    ),
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        if (isBookmarked) {
                          _bookmarkedListings.remove(listing.id);
                        } else {
                          _bookmarkedListings.add(listing.id);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                listing.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Owner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                listing.ownerName,
                style: AppTextStyles.bodySmall,
              ),
            ),
            // Rating (placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.star, size: 14, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('4.5 (12)', style: AppTextStyles.caption),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Spacer(),
            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Wrap(
                spacing: 4,
                children: listing.tags
                    .take(2)
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: AppTextStyles.caption),
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            // Send Request Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to SendRequestScreen
                    SnackBarHelper.success(context, 'Feature coming soon');
                  },
                  child: Text('Send Request', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ListingModel> _filterListings(List<ListingModel> listings) {
    return listings.where((listing) {
      final matchesSearch = _searchController.text.isEmpty ||
          listing.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          listing.tags.any((t) => t.toLowerCase().contains(_searchController.text.toLowerCase()));

      final matchesCategory = _selectedCategory == 'All' || listing.category == _selectedCategory;
      final matchesLevel = _selectedLevel == 'All' || listing.level == _selectedLevel;
      final matchesFormat = _selectedFormat == 'All' || listing.modality == _selectedFormat;

      return matchesSearch && matchesCategory && matchesLevel && matchesFormat;
    }).toList();
  }
}
