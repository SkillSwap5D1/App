import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../browse/listing_card.dart';
import 'saved_empty_state.dart';

class SavedBookmarkedScreen extends StatefulWidget {
  const SavedBookmarkedScreen({super.key});

  @override
  State<SavedBookmarkedScreen> createState() => _SavedBookmarkedScreenState();
}

class _SavedBookmarkedScreenState extends State<SavedBookmarkedScreen> {
  // ── STATE ──────────────────────────────────────────────────────────
  late List<MockListing> _savedListings;
  final Map<String, int> _removalHistory = {};

  @override
  void initState() {
    super.initState();
    _loadSavedListings();
  }

  void _loadSavedListings() {
    _savedListings = List.from(MockData.savedListings);
  }

  int _getSavedCount() => _savedListings.length;

  bool _isListingSaved(String listingId) {
    return _savedListings.any((listing) => listing.id == listingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Saved Skills',
                        style: AppTextStyles.h2,
                      ),
                      // Count badge
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          '${_getSavedCount()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),

            // ── CONTENT ────────────────────────────────────────────
            if (_savedListings.isEmpty)
              Expanded(
                child: SavedEmptyState(
                  onBrowsePressed: () {
                    // TODO: Navigate to Browse screen
                    // Uses Navigator to push Browse screen
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const BrowseScreen(),
                    //   ),
                    // );
                  },
                ),
              )
            else
              _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Expanded(
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
        itemCount: _savedListings.length,
        itemBuilder: (context, index) {
          final listing = _savedListings[index];
          return AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildSavedCard(listing, index),
          );
        },
      ),
    );
  }

  Widget _buildSavedCard(MockListing listing, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: Navigate to listing detail
          },
          child: ListingCard(
            listing: listing,
            isSaved: true,
            onSaveToggle: () {
              _removeFromSaved(listing, index);
            },
          ),
        ),
        // Filled bookmark indicator with animation
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: const Icon(
                    Icons.bookmark,
                    color: AppColors.surface,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _removeFromSaved(MockListing listing, int index) {
    // Create a copy to restore later
    final removedListing = listing;
    
    setState(() {
      _savedListings.removeAt(index);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from saved'),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _savedListings.insert(index, removedListing);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restored to saved'),
                duration: Duration(milliseconds: 1500),
              ),
            );
          },
        ),
      ),
    );
  }
}
