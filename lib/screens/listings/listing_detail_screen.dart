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

                  // Skill title
                  _buildSkillTitle(),
                  SizedBox(height: AppSpacing.md),

                  // Tag chips row
                  _buildTagsRow(isMobile),
                  SizedBox(height: AppSpacing.lg),

                  // Level and modality info
                  _buildLevelAndModality(),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelAndModality() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoChip(
              icon: Icons.trending_up,
              label: 'Level',
              value: widget.listing.level,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _infoChip(
              icon: widget.listing.modality == 'Online'
                  ? Icons.video_call
                  : Icons.location_on,
              label: 'Format',
              value: widget.listing.modality,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(bool isMobile) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: widget.listing.tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.primary, width: 1),
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
    );
  }

  Widget _buildSkillTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.listing.title,
          style: AppTextStyles.h1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            widget.listing.category,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
