import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';
import '../../widgets/tag_chip.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Icons.code_rounded;
      case 'languages':
        return Icons.language_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'data science':
        return Icons.data_usage_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListingProvider, AuthProvider>(
      builder: (context, listingProvider, authProvider, _) {
        final otherListings = _getOtherListings(listingProvider, authProvider);
        final myListings = _getMyListings(listingProvider, authProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Skills'),
            backgroundColor: AppColors.surface,
            elevation: 0,
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
              // BROWSE TAB - Other people's listings
              // ═════════════════════════════════════════════════════════════
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateListingScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accentUltraLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColors.accent,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'List a Skill',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.accent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: otherListings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 48,
                                  color: AppColors.accentLight.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No skills available yet',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: otherListings.length,
                            itemBuilder: (context, index) {
                              return _buildListingCard(
                                otherListings[index],
                                context,
                              );
                            },
                          ),
                  ),
                ],
              ),

              // ═════════════════════════════════════════════════════════════
              // MY LISTINGS TAB - Current user's listings
              // ═════════════════════════════════════════════════════════════
              myListings.isEmpty
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
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: myListings.length,
                      itemBuilder: (context, index) {
                        return _buildMyListingCard(
                          myListings[index],
                          context,
                        );
                      },
                    ),
            ],
          ),
        );
      },
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
          overflow: Clip.antiAlias,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colored header with category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentUltraLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.accentLight, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(listing.category),
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      listing.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.ownerName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Quick info row with icons
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grade_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              listing.level,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              listing.modality == 'Online'
                                  ? Icons.cloud_queue_rounded
                                  : listing.modality == 'In-person'
                                      ? Icons.location_on_rounded
                                      : Icons.hub_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              listing.modality,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Tags preview
                  if (listing.tags.isNotEmpty)
                    Wrap(
                      spacing: 3,
                      children: listing.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      },
                      child: Text(
                        'View',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          overflow: Clip.antiAlias,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colored header with category + status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentUltraLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.accentLight, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(listing.category),
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      listing.category,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: listing.isActive
                          ? const Color(0x1A10B981)
                          : const Color(0x1A6B7280),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      listing.isActive ? '●' : '●',
                      style: AppTextStyles.caption.copyWith(
                        color: listing.isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.nextAvailable,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Quick info row with icons
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grade_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              listing.level,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              listing.modality == 'Online'
                                  ? Icons.cloud_queue_rounded
                                  : listing.modality == 'In-person'
                                      ? Icons.location_on_rounded
                                      : Icons.hub_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              listing.modality,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Tags preview
                  if (listing.tags.isNotEmpty)
                    Wrap(
                      spacing: 3,
                      children: listing.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      },
                      child: Text(
                        'Edit',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
