import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/notification_provider.dart';
import '../listings/create_listing_screen.dart';
import '../listings/listing_detail_screen.dart';
import '../notifications/notifications_screen.dart';

const Color _bgTopLeft = Color(0xFFEDE9F6);
const Color _bgMidLeft = Color(0xFFEAF2FF);
const Color _bgMidRight = Color(0xFFFFF4E8);
const Color _bgBottomRight = Color(0xFFF5F3FF);

const Color _headingColor = Color(0xFF1E1B4B);
const Color _bodyColor = Color(0xFF6B7280);
const Color _mutedColor = Color(0xFF9CA3AF);
const Color _accentColor = Color(0xFF7C3AED);
const Color _accentLightColor = Color(0xFFA78BFA);
const Color _pastelBlue = Color(0xFFBFDBFE);
const Color _pastelOrange = Color(0xFFFCD8B8);
const Color _pastelPink = Color(0xFFFBCFE8);
const Color _surfaceTint = Color(0xFFF5F3FF);
const Color _errorColor = Color(0xFFDC2626);
const Color _successColor = Color(0xFF059669);

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

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
          listing.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

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
    return provider.listings
        .where((listing) => listing.ownerId != currentUid)
        .toList();
  }

  List<ListingModel> _getMyListings(
    ListingProvider provider,
    AuthProvider authProvider,
  ) {
    final currentUid = authProvider.currentUser?.uid ?? '';
    return provider.listings
        .where((listing) => listing.ownerId == currentUid)
        .toList();
  }

  bool get _isBrowseTabSelected => _tabController.index == 0;

  BoxDecoration get _glassDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.90),
          _pastelBlue.withOpacity(0.26),
          _pastelPink.withOpacity(0.22),
          _pastelOrange.withOpacity(0.20),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: _accentColor.withOpacity(0.07),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          blurRadius: 0,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTopLeft, _bgMidLeft, _bgMidRight, _bgBottomRight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: _buildTopBar(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _buildTabToggle(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBrowseTab(context),
                    _buildMyListingsTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Text(
          'SkillSwap',
          style: TextStyle(
            color: _headingColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final hasUnread = notificationProvider.unreadCount > 0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _accentColor.withOpacity(0.10)),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: _bodyColor,
                      size: 22,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _tabController.animateTo(0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient:
                    _isBrowseTabSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                        : null,
                color:
                    _isBrowseTabSelected
                        ? null
                        : Colors.white.withOpacity(0.60),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      _isBrowseTabSelected
                          ? Colors.transparent
                          : _accentColor.withOpacity(0.20),
                ),
                boxShadow:
                    _isBrowseTabSelected
                        ? [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : const [],
              ),
              child: Text(
                'Browse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isBrowseTabSelected ? Colors.white : _bodyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _tabController.animateTo(1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient:
                    !_isBrowseTabSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                        : null,
                color:
                    !_isBrowseTabSelected
                        ? null
                        : Colors.white.withOpacity(0.60),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      !_isBrowseTabSelected
                          ? Colors.transparent
                          : _accentColor.withOpacity(0.20),
                ),
                boxShadow:
                    !_isBrowseTabSelected
                        ? [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : const [],
              ),
              child: Text(
                'My Listings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !_isBrowseTabSelected ? Colors.white : _bodyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Level',
                  value: _selectedLevel,
                  items: _levels,
                  onChanged: (val) => setState(() => _selectedLevel = val!),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Format',
                  value: _selectedFormat,
                  items: _formats,
                  onChanged: (val) => setState(() => _selectedFormat = val!),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer2<ListingProvider, AuthProvider>(
            builder: (context, listingProvider, authProvider, _) {
              if (listingProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 2.5,
                  ),
                );
              }

              final otherListings = _getOtherListings(
                listingProvider,
                authProvider,
              );
              final filteredListings = _filterListings(otherListings);

              if (filteredListings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _surfaceTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          color: _accentLightColor,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No skills found',
                        style: TextStyle(
                          color: _headingColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Try different keywords or filters',
                        style: TextStyle(color: _mutedColor, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: _buildPairedRows(
                  filteredListings,
                  (listing) => _buildBrowseListingCard(listing, context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsTab(BuildContext context) {
    return Consumer2<ListingProvider, AuthProvider>(
      builder: (context, listingProvider, authProvider, _) {
        if (listingProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _accentColor,
              strokeWidth: 2.5,
            ),
          );
        }

        final myListings = _getMyListings(listingProvider, authProvider);

        if (myListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: _surfaceTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    color: _accentLightColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No skills found',
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create your first listing to get started',
                  style: TextStyle(color: _mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateListingScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.92),
                          _pastelOrange.withOpacity(0.52),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _pastelOrange.withOpacity(0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: _pastelOrange.withOpacity(0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Create Listing',
                      style: TextStyle(
                        color: _headingColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: _buildPairedRows(
            myListings,
            (listing) => _buildMyListingCard(listing, context),
          ),
        );
      },
    );
  }

  List<Widget> _buildPairedRows(
    List<ListingModel> listings,
    Widget Function(ListingModel listing) cardBuilder,
  ) {
    final rows = <Widget>[];

    for (var index = 0; index < listings.length; index += 2) {
      final firstListing = listings[index];
      final hasSecondListing = index + 1 < listings.length;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardBuilder(firstListing)),
              if (hasSecondListing) ...[
                const SizedBox(width: 12),
                Expanded(child: cardBuilder(listings[index + 1])),
              ],
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _mutedColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              cursorColor: _accentColor,
              decoration: const InputDecoration(
                hintText: 'Search skills...',
                hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: _headingColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseListingCard(ListingModel listing, BuildContext context) {
    final initialLetter =
        listing.ownerName.isNotEmpty ? listing.ownerName[0].toUpperCase() : '?';

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
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: _glassDecoration,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                          listing.title,
                          style: const TextStyle(
                            color: _headingColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          listing.ownerName,
                          style: const TextStyle(
                            color: _bodyColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _surfaceTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  listing.category,
                  style: const TextStyle(
                    color: _accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _bodyColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.signal_cellular_alt_rounded,
                    color: _accentLightColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.level,
                      style: const TextStyle(color: _bodyColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.location_on_outlined,
                    color: _accentLightColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.modality,
                      style: const TextStyle(color: _bodyColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.92),
                        _pastelBlue.withOpacity(0.55),
                        _accentLightColor.withOpacity(0.30),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _pastelBlue.withOpacity(0.55)),
                    boxShadow: [
                      BoxShadow(
                        color: _pastelBlue.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: _headingColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyListingCard(ListingModel listing, BuildContext context) {
    final initialLetter =
        listing.ownerName.isNotEmpty ? listing.ownerName[0].toUpperCase() : '?';

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
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: _glassDecoration,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                          listing.title,
                          style: const TextStyle(
                            color: _headingColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          listing.ownerName,
                          style: const TextStyle(
                            color: _bodyColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          listing.isActive
                              ? _successColor.withOpacity(0.10)
                              : _errorColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      listing.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: listing.isActive ? _successColor : _errorColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _surfaceTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  listing.category,
                  style: const TextStyle(
                    color: _accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _bodyColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.signal_cellular_alt_rounded,
                    color: _accentLightColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.level,
                      style: const TextStyle(color: _bodyColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.location_on_outlined,
                    color: _accentLightColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.modality,
                      style: const TextStyle(color: _bodyColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.92),
                              _pastelBlue.withOpacity(0.34),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _pastelBlue.withOpacity(0.50)),
                          boxShadow: [
                            BoxShadow(
                              color: _pastelBlue.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: _headingColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ListingDetailScreen(listing: listing),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.92),
                              _pastelOrange.withOpacity(0.40),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _pastelOrange.withOpacity(0.55)),
                          boxShadow: [
                            BoxShadow(
                              color: _pastelOrange.withOpacity(0.20),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: _headingColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _accentColor.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _accentLightColor,
            size: 16,
          ),
          iconSize: 16,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          style: const TextStyle(
            color: _headingColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hint: Text(
            label,
            style: const TextStyle(color: _headingColor, fontSize: 13),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: _headingColor, fontSize: 13),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
