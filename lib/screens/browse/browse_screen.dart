import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});
@override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends StatefulWidget {
  // ── STATE ──────────────────────────────────────────────────────────────────
  String _selectedTab    = 'Available'; // Available / My Skills
  String _searchQuery    = '';
  String _selectedCategory = 'All';
  String _selectedLevel  = 'All Levels';
  String _selectedFormat = 'All Formats';