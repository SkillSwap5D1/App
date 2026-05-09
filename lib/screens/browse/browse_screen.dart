import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';

import '../../widgets/notification_icon_button.dart';


class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedFormat = 'All Formats';

  final List<String> _categories = ['All', 'Programming', 'Languages', 'Design', 'Music', 'Business', 'Mathematics'];
  final List<String> _levels = ['All Levels', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _formats = ['All Formats', 'Online', 'In-Person', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ListingModel> _filterListings(List<ListingModel> listings) {
    return listings.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || listing.category == _selectedCategory;
      final matchesLevel = _selectedLevel == 'All Levels' || listing.level == _selectedLevel;
      final matchesFormat = _selectedFormat == 'All Formats' || listing.modality == _selectedFormat;

      return matchesSearch && matchesCategory && matchesLevel && matchesFormat;
    }).toList();
  }

  List<ListingModel> _getOtherListings(
    ListingProvider provider,
    AuthProvider authProvider,
  ) {
    final currentUid = authProvider.currentUser?.uid ?? '';
    return provider.listings
        .where((listing) => listing.ownerId != currentUid)
        .toList();
  }

  List<ListingModel> _getMyListings(
    ListingProvider provider,
    AuthProvider authProvider,
  ) {
    final currentUid = authProvider.currentUser?.uid ?? '';
    return provider.listings
        .where((listing) => listing.ownerId == currentUid)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skills'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: const [NotificationIconButton()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.label,
          tabs: [
            const Tab(text: 'Browse'),
            const Tab(text: 'My Listings'),
          ],
        ),
      ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ═════════════════════════════════════════════════════════════
              // BROWSE TAB - Other people's listings with filters
              // ═════════════════════════════════════════════════════════════
              Column(
                children: [
                  // Search and Filter Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search skills...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Filter Dropdowns
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 12,
                            children: [
                              _buildFilterDropdown(
                                label: 'Category',
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: (val) => setState(() => _selectedCategory = val!),
                              ),
                              _buildFilterDropdown(
                                label: 'Level',
                                value: _selectedLevel,
                                items: _levels,
                                onChanged: (val) => setState(() => _selectedLevel = val!),
                              ),
                              _buildFilterDropdown(
                                label: 'Format',
                                value: _selectedFormat,
                                items: _formats,
                                onChanged: (val) => setState(() => _selectedFormat = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Listings Grid
                  Expanded(
                    child: Consumer2<ListingProvider, AuthProvider>(
                      builder: (context, listingProvider, authProvider, _) {
                        final otherListings = _getOtherListings(listingProvider, authProvider);
                        final filteredListings = _filterListings(otherListings);

                        if (filteredListings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: AppColors.accentLight.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No skills found',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different filters or search terms',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredListings.length,
                          itemBuilder: (context, index) {
                            return _buildListingCard(
                              filteredListings[index],
                              context,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ═════════════════════════════════════════════════════════════
              // MY LISTINGS TAB - Current user's listings
              // ═════════════════════════════════════════════════════════════
              Consumer2<ListingProvider, AuthProvider>(
                builder: (context, listingProvider, authProvider, _) {
                  final myListings = _getMyListings(listingProvider, authProvider);

                  return myListings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 48,
                                color: AppColors.accentLight.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You haven\'t listed any skills yet',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateListingScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Listing'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: myListings.length,
                          itemBuilder: (context, index) {
                            return _buildMyListingCard(
                              myListings[index],
                              context,
                            );
                          },
                        );
                },
              ),
            ],
          ),
        );
  }

  Widget _buildListingCard(ListingModel listing, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Avatar + Title + Category Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accentUltraLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        listing.ownerName.isNotEmpty
                            ? listing.ownerName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Title + Owner
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          listing.ownerName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Category Badge + Rating
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentUltraLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      listing.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Description
              Text(
                listing.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Details: Level + Modality
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildCompactChip(Icons.grade_rounded, listing.level),
                  _buildCompactChip(Icons.location_on_outlined, listing.modality),
                ],
              ),
              const SizedBox(height: 4),
              
              // Tags
              if (listing.tags.isNotEmpty)
                Wrap(
                  spacing: 3,
                  runSpacing: 3,
                  children: listing.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                      color: AppColors.accentUltraLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 6),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyListingCard(ListingModel listing, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: listing.isActive 
                          ? const Color(0x1A10B981)
                          : const Color(0x1A6B7280),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      listing.isActive ? 'Active' : 'Inactive',
                      style: AppTextStyles.caption.copyWith(
                        color: listing.isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Category Badge + Rating
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentUltraLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      listing.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.visibility_rounded,
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Description
              Text(
                listing.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Details: Level + Modality
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildCompactChip(Icons.grade_rounded, listing.level),
                  _buildCompactChip(Icons.location_on_outlined, listing.modality),
                ],
              ),
              const SizedBox(height: 4),
              
              // Tags
              if (listing.tags.isNotEmpty)
                Wrap(
                  spacing: 3,
                  runSpacing: 3,
                  children: listing.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentUltraLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 6),
              
              // Action Buttons
              Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Edit',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ListingDetailScreen(listing: listing),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'View',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentUltraLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: AppTextStyles.bodySmall),
            );
          }).toList(),
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hint: Text(label),
        ),
      ),
    );
  }
}
