import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';
import 'tag_chip.dart';

class ListingCard extends StatefulWidget {
  final MockListing listing;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onSendRequest;
  final bool isOwner;
  final bool isBookmarked;

  const ListingCard({
    super.key,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildDescription(),
            const SizedBox(height: 8),
            _buildTags(),
            const SizedBox(height: 8),
            _buildAvailability(),
            const SizedBox(height: 16),
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
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Text(
            widget.listing.ownerName.isNotEmpty
                ? widget.listing.ownerName[0].toUpperCase()
                : '?',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listing.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(widget.listing.ownerName, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const StarRating(
              rating: 4.8,
              reviewCount: 24,
              size: 14,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _toggleBookmark,
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppColors.primary : AppColors.textMuted,
                size: 18,
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
      spacing: 6,
      runSpacing: 6,
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
            const Icon(Icons.schedule, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('Tomorrow, 3 PM', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(widget.listing.modality, style: AppTextStyles.caption),
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
          icon: const Icon(Icons.send, size: 14),
          label: const Text('Send Request'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
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
  }
}
