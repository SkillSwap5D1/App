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
    return const Scaffold();
  }
}