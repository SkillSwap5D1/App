import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing_model.dart';

class CreateListingScreen extends StatefulWidget {
  final ListingModel? listing;
  const CreateListingScreen({super.key, this.listing});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Programming';
  String _selectedLevel = 'Beginner';
  String _selectedModality = 'Online';
  bool _isLoading = false;

  final categories = [
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Data Science',
  ];
  final levels = ['Beginner', 'Intermediate', 'Advanced'];
  final modalities = ['In-person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.listing?.description ?? '',
    );

    if (widget.listing != null) {
      _selectedCategory = widget.listing!.category;
      _selectedLevel = widget.listing!.level;
      _selectedModality = _normalizeModality(widget.listing!.modality);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final listingProvider = context.read<ListingProvider>();

      if (widget.listing == null) {
        final newListing = ListingModel(
          id: '',
          ownerId: currentUser.uid,
          ownerName: '${currentUser.firstName} ${currentUser.lastName}'.trim(),
          title: _titleController.text,
          description: _descriptionController.text,
          tags: [],
          level: _selectedLevel,
          modality: _selectedModality,
          category: _selectedCategory,
          nextAvailable: 'Flexible',
          isActive: true,
          createdAt: DateTime.now(),
        );

        await listingProvider.createListing(newListing);
      } else {
        await listingProvider.updateListing(widget.listing!.id, {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'level': _selectedLevel,
          'modality': _selectedModality,
          'category': _selectedCategory,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Skill listing saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _normalizeModality(String modality) {
    switch (modality.toLowerCase()) {
      case 'in-person':
      case 'in person':
        return 'In-person';
      case 'online':
        return 'Online';
      case 'hybrid':
        return 'Hybrid';
      default:
        return 'Online';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? AppSpacing.md : 40,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Hero icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: AppShadows.hover,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'List Your Skill',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: isMobile ? 24 : 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Form card with glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: AppColors.glassCard(borderRadius: 28),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Share your expertise',
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: isMobile ? 22 : 24,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tell others about the skills you can teach',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Divider(color: AppColors.borderLight),
                              const SizedBox(height: AppSpacing.lg),

                              // Skill Title
                              Text('Skill Title', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSkillTitleField(),
                              const SizedBox(height: AppSpacing.md),

                              // Description
                              Text('Description', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildDescriptionField(),
                              const SizedBox(height: AppSpacing.md),

                              // Category
                              Text('Category', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildCategoryDropdown(),
                              const SizedBox(height: AppSpacing.md),

                              // Level and Modality in row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Level',
                                          style: AppTextStyles.label,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        _buildLevelDropdown(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Modality',
                                          style: AppTextStyles.label,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        _buildModalityDropdown(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Create Listing Button
                              _buildCreateButton(),
                              const SizedBox(height: AppSpacing.md),

                              // Back button
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Back to Browse',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTitleField() {
    return TextField(
      controller: _titleController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'e.g., Advanced Flutter Development',
        prefixIcon: const Icon(Icons.school_outlined),
        prefixIconColor: AppColors.accentLight,
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
          borderSide: const BorderSide(
            color: AppColors.borderActive,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: 'Describe what you\'ll teach and what students will learn...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(top: 18),
          child: Icon(Icons.description_outlined),
        ),
        prefixIconColor: AppColors.accentLight,
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
          borderSide: const BorderSide(
            color: AppColors.borderActive,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items:
            categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedCategory = value);
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.category_outlined),
          prefixIconColor: AppColors.accentLight,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLevel,
        items:
            levels
                .map(
                  (level) => DropdownMenuItem(value: level, child: Text(level)),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedLevel = value);
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.grade_outlined),
          prefixIconColor: AppColors.accentLight,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildModalityDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedModality,
        items:
            modalities
                .map((mod) => DropdownMenuItem(value: mod, child: Text(mod)))
                .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedModality = value);
          }
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_on_outlined),
          prefixIconColor: AppColors.accentLight,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.accentGradient,
          color: _isLoading ? AppColors.accentUltraLight : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: _isLoading ? null : AppShadows.hover,
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveListing,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('List Your Skill', style: AppTextStyles.button),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
