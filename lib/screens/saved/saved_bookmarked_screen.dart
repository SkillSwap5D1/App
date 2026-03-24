import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/listing_card.dart';
import 'saved_empty_state.dart';

class SavedBookmarkedScreen extends StatefulWidget {
  const SavedBookmarkedScreen({super.key});

  @override
  State<SavedBookmarkedScreen> createState() => _SavedBookmarkedScreenState();
}

class _SavedBookmarkedScreenState extends State<SavedBookmarkedScreen> {
  // ── STATE ──────────────────────────────────────────────────────────
  late List<MockListing> _savedListings;

  @override
  void initState() {
    super.initState();
    _loadSavedListings();
  }

  void _loadSavedListings() {
    _savedListings = List.from(MockData.savedListings);
  }

  int _getSavedCount() => _savedListings.length;

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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/listing-detail',
          arguments: listing,
        );
      },
      child: ListingCard(
        listing: listing,
        isBookmarked: true,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/listing-detail',
            arguments: listing,
          );
        },
        onBookmark: () {
          _removeFromSaved(listing, index);
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
