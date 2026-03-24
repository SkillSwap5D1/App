import 'package:flutter/material.dart';
import 'package:skillswap_app/data/mock_data.dart';
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 8.0),
            _buildDescription(),
            SizedBox(height: 8.0),
            _buildTags(),
            SizedBox(height: 8.0),
            _buildAvailability(),
            SizedBox(height: 16.0),
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
          backgroundColor: AppColors.primaryLight,
          child: Text(
            widget.listing.ownerName[0].toUpperCase(),
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 12.0),
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
              Text(
                widget.listing.ownerName,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.0),
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
      spacing: 6.0,
      runSpacing: 6.0,
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
            Icon(Icons.schedule, size: 12, color: AppColors.textMuted),
            SizedBox(width: 4),
            Text(
              'Tomorrow, 3 PM',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
            SizedBox(width: 4),
            Text(
              widget.listing.modality,
              style: AppTextStyles.caption,
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
          icon: Icon(Icons.send, size: 14),
          label: Text('Send Request'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.0),
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
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            child: Text('Edit'),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
