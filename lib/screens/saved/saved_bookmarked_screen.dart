import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../browse/listing_card.dart';

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
    _savedListings = List.from(MockData.savedListings);
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
                  Text(
                    'Saved Skills',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_savedListings.length} skill${_savedListings.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // ── CONTENT ────────────────────────────────────────────
            if (_savedListings.isEmpty)
              _buildEmptyState()
            else
              _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No saved skills yet',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Browse to find and save skills',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Browse screen
              },
              child: const Text('Browse Skills'),
            ),
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
          return _buildSavedCard(listing, index);
        },
      ),
    );
  }

  Widget _buildSavedCard(MockListing listing, int index) {
    return GestureDetector(
      onLongPress: () {
        _removeFromSaved(listing, index);
      },
      child: ListingCard(
        listing: listing,
        isSaved: true,
        onSaveToggle: () {
          _removeFromSaved(listing, index);
        },
      ),
    );
  }

  void _removeFromSaved(MockListing listing, int index) {
    setState(() {
      _savedListings.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from saved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _savedListings.insert(index, listing);
            });
          },
        ),
      ),
    );
  }
}
