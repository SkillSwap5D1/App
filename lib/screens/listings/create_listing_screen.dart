import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/widgets/snackbar_helper.dart';

class CreateListingScreen extends StatefulWidget {
  final ListingModel? listing;

  const CreateListingScreen({super.key, this.listing});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  String _selectedCategory = 'Programming';
  String _selectedLevel = 'Beginner';
  String _selectedModality = 'Online';
  List<String> _tags = [];
  bool _isLoading = false;

  static const categories = ['Programming', 'Languages', 'Design', 'Music', 'Business', 'Data Science'];
  static const levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const modalities = ['In-person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing?.title ?? '');
    _descriptionController = TextEditingController(text: widget.listing?.description ?? '');
    _tagController = TextEditingController();
    _tags = List.from(widget.listing?.tags ?? []);
    _selectedCategory = widget.listing?.category ?? 'Programming';
    _selectedLevel = widget.listing?.level ?? 'Beginner';
    _selectedModality = widget.listing?.modality ?? 'Online';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      SnackBarHelper.error(context, 'Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ListingProvider>();
      final listingData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'level': _selectedLevel,
        'modality': _selectedModality,
        'tags': _tags,
      };

      if (widget.listing != null) {
        // Update existing - for now just show success
        SnackBarHelper.success(context, 'Listing updated');
      } else {
        // Create new listing
        SnackBarHelper.success(context, 'Listing created');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing != null ? 'Edit Listing' : 'Create Listing'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveListing,
            child: Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Skill Title', _titleController),
            SizedBox(height: AppSpacing.lg),
            _buildTextField('Description', _descriptionController, maxLines: 5),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Category', _selectedCategory, categories, (value) {
              setState(() => _selectedCategory = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Level', _selectedLevel, levels, (value) {
              setState(() => _selectedLevel = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Modality', _selectedModality, modalities, (value) {
              setState(() => _selectedModality = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildTags(),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveListing,
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save Listing'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  setState(() {
                    _tags.add(_tagController.text);
                    _tagController.clear();
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: _tags
              .map((tag) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag, style: AppTextStyles.caption),
                        SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _tags.remove(tag)),
                          child: Icon(Icons.close, size: 14),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing != null ? 'Edit Listing' : 'Create Listing'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveListing,
            child: Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Skill Title', _titleController),
            SizedBox(height: AppSpacing.lg),
            _buildTextField('Description', _descriptionController, maxLines: 5),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Category', _selectedCategory, categories, (value) {
              setState(() => _selectedCategory = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Level', _selectedLevel, levels, (value) {
              setState(() => _selectedLevel = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildDropdown('Modality', _selectedModality, modalities, (value) {
              setState(() => _selectedModality = value);
            }),
            SizedBox(height: AppSpacing.lg),
            _buildTags(),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveListing,
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save Listing'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) => onChanged(value ?? value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add tag and press Add',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  setState(() {
                    _tags.add(_tagController.text);
                    _tagController.clear();
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: _tags
              .map((tag) => TagChip(
                    label: tag,
                    onRemove: () => setState(() => _tags.remove(tag)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

extension on TagChip {
  TagChip copyWith({String? onRemove}) => TagChip(
    label: label,
  );
}
