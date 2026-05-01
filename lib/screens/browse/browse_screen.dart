import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../listings/listing_detail_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ListingProvider>().loadListings();
      }
    });
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

  List<ListingModel> _getListings(ListingProvider provider) {
    return _selectedTab == 'Available' ? provider.listings : provider.myListings;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, _) {
        final listings = _getListings(listingProvider);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildHero(),
              Expanded(
                child: listings.isEmpty && !listingProvider.isLoading
                    ? _buildEmptyState()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSidebar(),
                          Expanded(child: _buildListingGrid(listings, listingProvider)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingGrid(List<ListingModel> listings, ListingProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
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
                    child: row.length > 1
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(16),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(listing.ownerName, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '4.8 (24)',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
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
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(AppRadius.full),
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
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('Flexible', style: AppTextStyles.caption),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(listing.modality, style: AppTextStyles.caption),
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
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendRequestScreen(listing: listing),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Send Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                      final uid = context.read<AuthProvider>().currentUser?.uid;
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
                          : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWarm,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
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
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? [const BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Available' ? Icons.search : Icons.grid_view,
                size: 14,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
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
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: AppTextStyles.bodySmall),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      underline: Container(height: 1, color: AppColors.border),
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
      dropdownColor: AppColors.surface,
      iconEnabledColor: AppColors.accent,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No skills found',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.heroBgTop, AppColors.background],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SkillSwap',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _performSearch();
            },
            decoration: InputDecoration(
              hintText: 'Search skills, topics, or people...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.surfaceWarm,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

}
