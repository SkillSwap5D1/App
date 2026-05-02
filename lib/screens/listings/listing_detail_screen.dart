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
  }

  Future<void> _sendRequest() async {
    Navigator.pushNamed(context, '/send-request', arguments: widget.listing);
  }

  Future<void> _editListing() async {
    Navigator.pushNamed(context, '/create-listing', arguments: widget.listing);
  }

  Future<void> _deleteListing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete listing?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        if (mounted) {
          SnackBarHelper.success(context, 'Listing deleted');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) SnackBarHelper.error(context, 'Error deleting: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
            PopupMenuButton(itemBuilder: (context) => [
              PopupMenuItem(child: Text('Edit'), onTap: _editListing),
              PopupMenuItem(child: Text('Delete', style: TextStyle(color: AppColors.error)), onTap: _deleteListing),
            ])
          else
            IconButton(
              icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_outline, color: _isBookmarked ? AppColors.accent : null),
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
                  color: AppColors.surfaceElevated,
                  border: Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    elevation: 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: _isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                          : Text('Request Lesson', style: AppTextStyles.button),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: AppShadows.hover,
            ),
            alignment: Alignment.center,
            child: Text(widget.listing.ownerName[0].toUpperCase(), style: TextStyle(color: AppColors.surface, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.listing.ownerName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text('4.5 (12 reviews)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
        Text(widget.listing.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6)),
        SizedBox(height: AppSpacing.md),
        Text('Tags', style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        Wrap(spacing: AppSpacing.sm, children: widget.listing.tags.map((tag) => Chip(label: Text(tag))).toList()),
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
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
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
                leading: Icon(widget.listing.isActive ? Icons.check_circle : Icons.cancel, color: widget.listing.isActive ? AppColors.success : AppColors.error),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('42', 'Sessions'),
          VerticalDivider(color: AppColors.border),
          _buildStatColumn('4.5', 'Rating'),
          VerticalDivider(color: AppColors.border),
          _buildStatColumn('12', 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number, style: AppTextStyles.h3.copyWith(color: AppColors.accent)),
        SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
