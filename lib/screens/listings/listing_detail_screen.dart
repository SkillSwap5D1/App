import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class ListingDetailScreen extends StatefulWidget {
  final MockListing listing;

  const ListingDetailScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late bool _isOwner;

  @override
  void initState() {
    super.initState();
    _isOwner = widget.listing.ownerId == MockData.currentUser.id;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? AppSpacing.md : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Back button header
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider info row
                  _buildProviderHeader(),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderHeader() {
    return Row(
      children: [
        // Avatar with initials
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Center(
            child: Text(
              widget.listing.ownerName
                  .split(' ')
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase(),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),

        // Name and rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listing.ownerName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.star_filled,
                    size: 16,
                    color: const Color(0xFFFCD34D), // Yellow star
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '${widget.listing.ownerRating.toStringAsFixed(1)} (${widget.listing.ownerReviewCount} reviews)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
