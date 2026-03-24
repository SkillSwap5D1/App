import 'package:flutter/material.dart';
import 'package:skillswap_app/models/listing.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/widgets/star_rating.dart';
import 'package:skillswap_app/widgets/tag_chip.dart';

class ListingCard extends StatefulWidget {
  final MockListing listing;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onSendRequest;
  final bool isOwner;
  final bool isBookmarked;

  const ListingCard({
    required this.listing,
    required this.onTap,
    required this.onBookmark,
    required this.onSendRequest,
    this.isOwner = false,
    this.isBookmarked = false,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    widget.onBookmark();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppSpacing.sm),
            _buildDescription(),
            SizedBox(height: AppSpacing.sm),
            _buildTags(),
            SizedBox(height: AppSpacing.sm),
            _buildAvailability(),
            SizedBox(height: AppSpacing.md),
            if (widget.isOwner) _buildOwnerButtons() else _buildUserButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.avatarBg,
          child: Text(
            widget.listing.ownerName[0].toUpperCase(),
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listing.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.listing.ownerName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StarRating(
              rating: widget.listing.ownerRating,
              reviewCount: 24,
              size: 14,
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: _toggleBookmark,
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.listing.description,
      style: AppTextStyles.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: widget.listing.tags
          .take(3)
          .map((tag) => TagChip(label: tag))
          .toList(),
    );
  }

  Widget _buildAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'Tomorrow, 3 PM',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              widget.listing.modality,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: widget.onSendRequest,
          icon: Icon(Icons.send, size: 16),
          label: Text('Send Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
        ),
      ],
    );
  }
}
