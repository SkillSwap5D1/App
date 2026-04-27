import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/widgets/snackbar_helper.dart';
import 'package:skillswap_app/widgets/tag_chip.dart';
import 'package:skillswap_app/providers/auth_provider.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // In real app, check if user has bookmarked this listing
  }

  Future<void> _sendRequest() async {
    // Navigate to SendRequestScreen
    Navigator.pushNamed(context, '/send-request', arguments: widget.listing);
  }

  Future<void> _editListing() async {
    // Navigate to CreateListingScreen with listing
    Navigator.pushNamed(context, '/create-listing', arguments: widget.listing);
  }

  Future<void> _deleteListing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete listing?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        // TODO: Call provider to delete listing
        if (mounted) {
          SnackBarHelper.success(context, 'Listing deleted');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.error(context, 'Error deleting: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isOwner = authProvider.currentUser?.uid == widget.listing.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Listing', style: AppTextStyles.h3),
        actions: [
          if (isOwner)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Edit'),
                  onTap: _editListing,
                ),
                PopupMenuItem(
                  child: Text('Delete', style: TextStyle(color: AppColors.error)),
                  onTap: _deleteListing,
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: _isBookmarked ? AppColors.accent : null,
              ),
              onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderSection(),
                SizedBox(height: AppSpacing.lg),
                _buildTitleSection(),
                SizedBox(height: AppSpacing.lg),
                _buildDescriptionSection(),
                SizedBox(height: AppSpacing.lg),
                _buildAvailabilitySection(),
                SizedBox(height: AppSpacing.lg),
                _buildProviderStatsCard(),
                SizedBox(height: 100),
              ],
            ),
          ),
          if (!isOwner)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Request Lesson'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            child: Text(
              widget.listing.ownerName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.surface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listing.ownerName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text('4.5 (12 reviews)', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.listing.title, style: AppTextStyles.h2),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            TagChip(label: widget.listing.level),
            TagChip(label: widget.listing.modality),
            TagChip(label: widget.listing.category),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About This Skill', style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.sm),
        Text(
          widget.listing.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text('Tags', style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: widget.listing.tags
              .map((tag) => Chip(label: Text(tag)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability', style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Next Available'),
                subtitle: Text(widget.listing.nextAvailable),
                leading: Icon(Icons.calendar_today, color: AppColors.accent),
              ),
              Divider(),
              ListTile(
                title: Text('Status'),
                subtitle: Text(widget.listing.isActive ? 'Active' : 'Inactive'),
                leading: Icon(
                  widget.listing.isActive ? Icons.check_circle : Icons.cancel,
                  color: widget.listing.isActive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('42', 'Sessions'),
          VerticalDivider(),
          _buildStatColumn('4.5', 'Rating'),
          VerticalDivider(),
          _buildStatColumn('12', 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number,
          style: AppTextStyles.h3.copyWith(color: AppColors.accent),
        ),
        SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
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

                  // Description section
                  _buildDescription(),
                  SizedBox(height: AppSpacing.lg),

                  // Availability section
                  _buildAvailabilitySection(),
                  SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  _buildActionButtons(isMobile),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this skill',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          widget.listing.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    // Parse availability from nextAvailable field
    final availableSlots = _generateTimeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Column(
          children: availableSlots
              .map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border:
                          Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot['day'] ?? 'Available',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              slot['time'] ?? widget.listing.nextAvailable,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            'Available',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
  Widget _buildActionButtons(bool isMobile) {
    if (_isOwner) {
      // Owner sees Edit and Delete buttons
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Create Listing in edit mode
                Navigator.of(context).pushNamed(
                  '/create-listing',
                  arguments: {'listing': widget.listing, 'isEdit': true},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                'Edit Listing',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                // Show delete confirmation dialog
                _showDeleteConfirmation();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                'Delete Listing',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Non-owner sees Request Lesson button
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Send Request Form
            Navigator.of(context).pushNamed(
              '/send-request',
              arguments: {'listing': widget.listing},
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(
            'Request Lesson',
            style: AppTextStyles.button.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete listing logic here
              Navigator.pop(context);
              Navigator.pop(context);
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  List<Map<String, String>> _generateTimeSlots() {
    // Generate 3 sample time slots based on availability
    return [
      {
        'day': 'Mondays & Wednesdays',
        'time': '2:00 PM - 5:00 PM',
      },
      {
        'day': 'Thursdays',
        'time': '6:00 PM - 8:00 PM',
      },
      {
        'day': 'Weekends',
        'time': '10:00 AM - 4:00 PM',
      },
    ];
  }

  Widget _buildLevelAndModality() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
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
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: Text(
                tag,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
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
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            widget.listing.category,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
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
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Text(
            widget.listing.ownerName[0].toUpperCase(),
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
                    Icons.star,
                    size: 16,
                    color: AppColors.accent, // Purple star
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
