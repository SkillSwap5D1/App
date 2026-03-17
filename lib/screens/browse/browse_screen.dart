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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SIDEBAR ─────────────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
            _buildSidebarLabel('SEARCH'),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search skills...',
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textMuted, size: 18),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('CATEGORY'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedCategory,
              items: MockData.categories,
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('LEVEL'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedLevel,
              items: MockData.levels,
              onChanged: (val) => setState(() => _selectedLevel = val!),
            ),
            const SizedBox(height: 20),
            _buildSidebarLabel('FORMAT'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedFormat,
              items: MockData.formats,
              onChanged: (val) => setState(() => _selectedFormat = val!),
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
        onTap: () => setState(() => _selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected ? AppShadows.card : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Available' ? Icons.search : Icons.grid_view,
                size: 14,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
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
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: AppTextStyles.bodyMedium,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTextStyles.bodyMedium),
              ))
          .toList(),
    );
  }
}

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