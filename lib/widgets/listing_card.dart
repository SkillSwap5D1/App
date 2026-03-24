import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';
import 'tag_chip.dart';

class ListingCard extends StatefulWidget {
  final MockListing listing;
  final bool isMySkills;
  final VoidCallback? onSendRequest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBookmarkToggle;

  const ListingCard({
    required this.listing,
    required this.isMySkills,
    this.onSendRequest,
    this.onEdit,
    this.onDelete,
    this.onBookmarkToggle,
    super.key,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.listing.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.listing.ownerName.isNotEmpty
        ? widget.listing.ownerName[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(initials),
          const SizedBox(height: 10),
          _buildDescription(),
          const SizedBox(height: 10),
          _buildTags(),
          const SizedBox(height: 10),
          _buildMetadata(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(String initials) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listing.title,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.listing.ownerName,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        StarRating(
          rating: widget.listing.ownerRating,
          reviewCount: widget.listing.ownerReviewCount,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.listing.description,
      style: AppTextStyles.bodySmall
          .copyWith(color: AppColors.textSecondary),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.listing.tags
          .map<Widget>((tag) => TagChip(label: tag))
          .toList(),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded,
            size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(widget.listing.nextAvailable,
            style: AppTextStyles.caption),
        const SizedBox(width: 12),
        const Icon(Icons.location_on_outlined,
            size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(widget.listing.modality, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.isMySkills) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onSendRequest,
              icon: const Icon(Icons.send_rounded, size: 14),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: IconButton(
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                widget.onBookmarkToggle?.call();
              },
              icon: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                color: _isBookmarked
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 18,
              ),
            ),
          ),
        ],
      );
    }
  }
}
