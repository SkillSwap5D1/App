import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import 'saved_empty_state.dart';
import '../../models/listing_model.dart';

class SavedBookmarkedScreen extends StatefulWidget {
  const SavedBookmarkedScreen({super.key});

  @override
  State<SavedBookmarkedScreen> createState() => _SavedBookmarkedScreenState();
}

class _SavedBookmarkedScreenState extends State<SavedBookmarkedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListingProvider, AuthProvider>(
      builder: (context, listingProvider, authProvider, _) {
        final uid = authProvider.currentUser?.uid;
        final savedIds = listingProvider.savedListingIds;
        final savedListings = listingProvider.listings
            .where((listing) => savedIds.contains(listing.id))
            .toList();

        if (uid != null && savedIds.isEmpty && !listingProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ListingProvider>().loadListings();
            context.read<ListingProvider>().loadSavedListings(uid);
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Saved Skills', style: AppTextStyles.h2),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          '${savedListings.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (savedListings.isEmpty)
                  Expanded(
                    child: SavedEmptyState(
                      onBrowsePressed: () {
                        Navigator.of(context).pushNamed('/browse');
                      },
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      itemCount: savedListings.length,
                      itemBuilder: (context, index) {
                        final listing = savedListings[index];
                        return _buildSavedCard(listing);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedCard(ListingModel listing) {
    final mockListing = MockListing(
      id: listing.id,
      ownerId: listing.ownerId,
      ownerName: listing.ownerName,
      ownerRating: 4.8,
      ownerReviewCount: 24,
      title: listing.title,
      description: listing.description,
      tags: listing.tags,
      level: listing.level,
      modality: listing.modality,
      category: listing.category,
      nextAvailable: listing.nextAvailable,
      isBookmarked: true,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/listing-detail',
          arguments: listing,
        );
      },
      child: ListingCard(
        listing: mockListing,
        isBookmarked: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/listing-detail',
            arguments: listing,
          );
        },
        onBookmark: () {
          final uid = context.read<AuthProvider>().currentUser?.uid;
          if (uid != null) {
            context.read<ListingProvider>().toggleSaved(uid, listing.id);
          }
        },
        onSendRequest: () {
          Navigator.pushNamed(
            context,
            '/send-request',
            arguments: listing,
          );
        },
      ),
    );
  }
}
