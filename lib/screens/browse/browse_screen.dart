import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';
import '../requests/send_request_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedTab = 'Available';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedFormat = 'All Formats';

  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ['All', 'Programming', 'Languages', 'Design', 'Music', 'Sports', 'Business'];
  final List<String> levels = ['All Levels', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];
  final List<String> formats = ['All Formats', 'In-person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    print('[BrowseScreen] initState called');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final category = _selectedCategory == 'All' ? '' : _selectedCategory;
    final level = _selectedLevel == 'All Levels' ? '' : _selectedLevel;
    final format = _selectedFormat == 'All Formats' ? '' : _selectedFormat;

    context.read<ListingProvider>().searchListings(
      query: _searchQuery,
      category: category,
      level: level,
      modality: format,
    );
  }

  List<ListingModel> _getListings(ListingProvider provider, AuthProvider authProvider) {
    if (_selectedTab == 'Available') {
      // Filter out current user's listings from available
      final currentUid = authProvider.currentUser?.uid ?? '';
      return provider.listings.where((listing) => listing.ownerId != currentUid).toList();
    }
    return provider.myListings;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListingProvider, AuthProvider>(
      builder: (context, listingProvider, authProvider, _) {
        final listings = _getListings(listingProvider, authProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Browse Skills'),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: listingProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : listingProvider.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${listingProvider.errorMessage}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => listingProvider.loadListings(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : listings.isEmpty
                      ? const Center(
                          child: Text('No listings available'),
                        )
                      : ListView.builder(
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            final listing = listings[index];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(listing.title),
                                subtitle: Text('${listing.ownerName} • ${listing.level}'),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  // Navigate to listing detail
                                },
                              ),
                            );
                          },
                        ),
        );
      },
    );
  }

  Widget _buildListingGrid(
    List<ListingModel> listings,
    ListingProvider provider, {
    bool isCompact = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (provider.errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessage}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _performSearch(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              '${listings.length} skill${listings.length == 1 ? '' : 's'} found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: (listings.length / 2).ceil(),
                itemBuilder: (context, index) {
                  final startIdx = index * 2;
                  final endIdx = (startIdx + 2 < listings.length) ? startIdx + 2 : listings.length;
                  final row = listings.sublist(startIdx, endIdx);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: !isCompact && row.length > 1
                        ? Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 350,
                                  child: _buildListingCard(row[0]),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 350,
                                  child: _buildListingCard(row[1]),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 350,
                            child: _buildListingCard(row[0]),
                          ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListingCard(ListingModel listing) {
    final isMySkills = _selectedTab == 'My Skills';
    final initials = listing.ownerName.isNotEmpty ? listing.ownerName[0].toUpperCase() : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: AppColors.glassCard(borderRadius: 20),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.accentGradient,
                            boxShadow: AppShadows.hover,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                listing.ownerName,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '4.8',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      listing.description,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: listing.tags
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentVeryLight,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('Flexible', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(listing.modality, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isMySkills)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListingDetailScreen(listing: listing),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.accentUltraLight,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          minimumSize: const Size.fromHeight(42),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await context.read<ListingProvider>().deleteListing(listing.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Listing deleted')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: const Color(0xFFFEE2E2),
                          side: const BorderSide(color: Color(0x33DC2626)),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          minimumSize: const Size.fromHeight(42),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                )
              else
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final currentUid = authProvider.currentUser?.uid;
                    final isOwnListing = listing.ownerId == currentUid;

                    return Row(
                      children: [
                        Expanded(
                          child: isOwnListing
                              ? OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textMuted,
                                    backgroundColor: AppColors.accentUltraLight,
                                    side: const BorderSide(color: AppColors.borderLight),
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                    minimumSize: const Size.fromHeight(42),
                                  ),
                                  child: const Text('Your Listing'),
                                )
                              : SizedBox(
                                  height: 42,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.accentGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: AppShadows.hover,
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SendRequestScreen(listing: listing),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                                      label: const Text('Send Request'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            color: AppColors.accentUltraLight,
                          ),
                          child: IconButton(
                            onPressed: () {
                              final uid = authProvider.currentUser?.uid;
                              if (uid != null) {
                                context.read<ListingProvider>().toggleSaved(uid, listing.id);
                              }
                            },
                            icon: Icon(
                              context.read<ListingProvider>().isSaved(listing.id)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              color: context.read<ListingProvider>().isSaved(listing.id)
                                  ? AppColors.primary
                                  : Color(0xFFC4B5FD),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar({bool isCompact = false}) {
    return Container(
      width: isCompact ? double.infinity : 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: isCompact
            ? const Border(bottom: BorderSide(color: AppColors.borderLight))
            : const Border(right: BorderSide(color: AppColors.borderLight)),
      ),
      child: SingleChildScrollView(
        scrollDirection: isCompact ? Axis.horizontal : Axis.vertical,
        child: SizedBox(
          width: isCompact ? 900 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Available'),
                    _buildTabButton('My Skills'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSidebarLabel('CATEGORY'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedCategory,
                items: categories,
                onChanged: (val) {
                  setState(() => _selectedCategory = val!);
                  _performSearch();
                },
              ),
              const SizedBox(height: 20),
              _buildSidebarLabel('LEVEL'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedLevel,
                items: levels,
                onChanged: (val) {
                  setState(() => _selectedLevel = val!);
                  _performSearch();
                },
              ),
              const SizedBox(height: 20),
              _buildSidebarLabel('FORMAT'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedFormat,
                items: formats,
                onChanged: (val) {
                  setState(() => _selectedFormat = val!);
                  _performSearch();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = label);
          if (label == 'My Skills') {
            final uid = context.read<AuthProvider>().currentUser?.uid;
            if (uid != null) {
              context.read<ListingProvider>().loadMyListings(uid);
            }
          } else {
            context.read<ListingProvider>().loadListings();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.accentGradient : null,
            color: isSelected ? null : AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? AppShadows.hover
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Available' ? Icons.search : Icons.grid_view,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: value,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        dropdownColor: AppColors.surface,
        iconEnabledColor: AppColors.accentLight,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.accentLight),
          const SizedBox(height: 16),
          Text(
            'No skills found',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SkillSwap',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateListingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'A curated marketplace for premium peer-to-peer learning.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _performSearch();
            },
            decoration: InputDecoration(
              hintText: 'Search skills, topics, or people...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: const Color(0xCCFFFFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

}
