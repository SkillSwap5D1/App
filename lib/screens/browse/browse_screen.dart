import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  String _selectedTab = 'Available';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedFormat = 'All Formats';

  final TextEditingController _searchController = TextEditingController();

  // ── FILTERED LISTINGS ──────────────────────────────────────────────────────
  List<MockListing> get _filteredListings {
    final source = _selectedTab == 'Available'
        ? MockData.listings
        : MockData.myListings;

    return source.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          listing.tags
              .any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;

      final matchesLevel =
          _selectedLevel == 'All Levels' || listing.level == _selectedLevel;

      final matchesFormat =
          _selectedFormat == 'All Formats' || listing.modality == _selectedFormat;

      return matchesSearch && matchesCategory && matchesLevel && matchesFormat;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHero(),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  // ── HERO SECTION ────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FDF9),
            Color(0xFFFFF7ED),
            Color(0xFFF8F7F4),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Discover & Exchange',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Find Skills to Learn', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Browse skills offered by students at your university\nand start learning today.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}