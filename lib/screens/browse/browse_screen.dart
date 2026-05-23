import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../listings/create_listing_screen.dart';
import '../listings/listing_detail_screen.dart';

const Color _pageBg = Color(0xFFF8FAFC);
const Color _surface = Color(0xFFFFFFFF);
const Color _surfaceAlt = Color(0xFFF1F5F9);
const Color _line = Color(0xFFE2E8F0);
const Color _textPrimary = Color(0xFF0F172A);
const Color _textSecondary = Color(0xFF475569);
const Color _textMuted = Color(0xFF94A3B8);
const Color _accent = Color(0xFF0F766E);
const Color _accentSoft = Color(0xFFCCFBF1);
const Color _accentTeal = Color(0xFF064E3B);
const Color _accentBlue = Color(0xFF60A5FA);
const Color _cardShadow = Color(0x140F172A);
const Color _chipBg = Color(0xFFF8FAFC);
const Color _chipBorder = Color(0xFFE2E8F0);

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedFormat = 'All Formats';

  final List<String> _categories = [
    'All',
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Mathematics',
  ];
  final List<String> _levels = [
    'All Levels',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  final List<String> _formats = [
    'All Formats',
    'Online',
    'In-Person',
    'Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _searchController = TextEditingController();
  }

  void _handleTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ListingModel> _filterListings(List<ListingModel> listings) {
    return listings.where((listing) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;
      final matchesLevel =
          _selectedLevel == 'All Levels' || listing.level == _selectedLevel;
      final matchesFormat =
          _selectedFormat == 'All Formats' ||
          listing.modality == _selectedFormat;

      return matchesSearch && matchesCategory && matchesLevel && matchesFormat;
    }).toList();
  }

  List<ListingModel> _getOtherListings(
    ListingProvider provider,
    AuthProvider authProvider,
  ) {
    final currentUid = authProvider.currentUser?.uid ?? '';
    return provider.listings.where((listing) => listing.ownerId != currentUid).toList();
  }

  List<ListingModel> _getMyListings(
    ListingProvider provider,
    AuthProvider authProvider,
  ) {
    final currentUid = authProvider.currentUser?.uid ?? '';
    return provider.listings.where((listing) => listing.ownerId == currentUid).toList();
  }

  bool get _isBrowseTabSelected => _tabController.index == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildSidebar(), Expanded(child: _buildListingGrid())],
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP NAVBAR ─────────────────────────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              const Icon(
                Icons.handshake_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'SkillSwap',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Nav items
          Row(
            spacing: 32,
            children: [
              _buildNavItem('Browse', Icons.search_rounded),
              _buildNavItem('Requests', Icons.mail_outline_rounded),
              _buildNavItem('Saved', Icons.bookmark_outline_rounded),
              _buildNavItem('Chat', Icons.chat_bubble_outline_rounded),
              _buildNavItem('Profile', Icons.person_outline_rounded),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon) {
    return Row(
      spacing: 6,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ── LISTING GRID ────────────────────────────────────────────────────────────
  Widget _buildListingGrid() {
    final listings = _filteredListings;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${listings.length} skill${listings.length == 1 ? '' : 's'} found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(color: Color(0x240F172A), blurRadius: 30, offset: Offset(0, 14)),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeroBadge(text: 'Discover'),
                    _HeroBadge(text: 'Exchange'),
                    _HeroBadge(text: 'Learn'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Find skills worth swapping.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 30 : 40,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    'Browse lessons, trade expertise, and connect with people who can teach what you need next.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.86),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _HeroStat(label: 'Active listings', value: '${context.watch<ListingProvider>().listings.length}'),
                    _HeroStat(label: 'Filtered results', value: '${_filterListings(_getOtherListings(context.watch<ListingProvider>(), context.watch<AuthProvider>())).length}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(color: _cardShadow, blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentTab(
                label: 'Browse',
                active: _isBrowseTabSelected,
                onTap: () => _tabController.animateTo(0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SegmentTab(
                label: 'My Listings',
                active: !_isBrowseTabSelected,
                onTap: () => _tabController.animateTo(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseTab(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final filtered = _filterListings(_getOtherListings(listingProvider, authProvider));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSidebar = constraints.maxWidth >= 1080;
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSidebar) ...[
                  SizedBox(width: 300, child: _buildFilterPanel(context)),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSearchBar(context),
                      const SizedBox(height: 14),
                      _buildQuickFilters(context),
                      const SizedBox(height: 14),
                      filtered.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 8),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth >= 700 ? 2 : 1,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 164,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildListingCard(context, filtered[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyListingsTab(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final myListings = _getMyListings(listingProvider, authProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your listings',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateListingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Listing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(0, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: myListings.isEmpty
                ? _buildEmptyOwnedState()
                : ListView.separated(
                    itemCount: myListings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildListingCard(context, myListings[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(color: _cardShadow, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Refine by category, level, and format.',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _FilterGroup(
            title: 'Category',
            value: _selectedCategory,
            options: _categories,
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 16),
          _FilterGroup(
            title: 'Level',
            value: _selectedLevel,
            options: _levels,
            onChanged: (value) => setState(() => _selectedLevel = value),
          ),
          const SizedBox(height: 16),
          _FilterGroup(
            title: 'Format',
            value: _selectedFormat,
            options: _formats,
            onChanged: (value) => setState(() => _selectedFormat = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(color: _cardShadow, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_rounded, color: _textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search skills, topics, or teachers',
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.close_rounded, color: _textMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final chips = [
          _QuickFilterChip(
            label: 'All',
            active: _selectedCategory == 'All' && _selectedLevel == 'All Levels' && _selectedFormat == 'All Formats',
            onTap: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedLevel = 'All Levels';
                _selectedFormat = 'All Formats';
              });
            },
          ),
          _QuickFilterChip(
            label: 'Programming',
            active: _selectedCategory == 'Programming',
            onTap: () => setState(() => _selectedCategory = 'Programming'),
          ),
          _QuickFilterChip(
            label: 'Languages',
            active: _selectedCategory == 'Languages',
            onTap: () => setState(() => _selectedCategory = 'Languages'),
          ),
          if (!compact)
            _QuickFilterChip(
              label: 'Online',
              active: _selectedFormat == 'Online',
              onTap: () => setState(() => _selectedFormat = 'Online'),
            ),
        ];

        if (compact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < chips.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  chips[index],
                ],
              ],
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.search_off_rounded, color: _accent, size: 34),
              ),
              const SizedBox(height: 14),
              const Text(
                'No listings match this search',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different category or clear the filters to see more results.',
                style: TextStyle(color: _textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOwnedState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: _accent, size: 34),
              ),
              const SizedBox(height: 14),
              const Text(
                'No listings yet',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first listing to start trading skills.',
                style: TextStyle(color: _textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, ListingModel listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(color: _cardShadow, blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_accentTeal, _accentBlue],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  listing.ownerName.isNotEmpty ? listing.ownerName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(text: listing.category),
                      _InfoChip(text: listing.level),
                      _InfoChip(text: listing.modality),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/send-request',
                      arguments: listing,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Request',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String text;

  const _HeroBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 46,
        decoration: BoxDecoration(
          color: active ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterGroup({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = option == value;
            return InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _accentSoft : _chipBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: active ? _accentSoft : _chipBorder),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: active ? _accent : _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _accent : _surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? _accent : _line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _chipBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
