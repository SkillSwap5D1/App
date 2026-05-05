import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chip_selector_widget.dart';
import '../../widgets/snackbar_helper.dart';

class EditSkillsScreen extends StatefulWidget {
  const EditSkillsScreen({super.key});

  @override
  State<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends State<EditSkillsScreen> {
  late List<String> _canTeach;
  late List<String> _wantsToLearn;
  bool _isLoading = false;

  static const List<String> skills = [
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Data Science',
    'Art',
    'Culture',
    'Computer Science',
    'Creative',
    'Fitness',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSkills();
  }

  void _initializeSkills() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _canTeach = List.from(authProvider.currentUser?.canTeach ?? []);
    _wantsToLearn = List.from(authProvider.currentUser?.wantsToLearn ?? []);
  }

  Future<void> _saveSkills() async {
    if (_canTeach.isEmpty || _wantsToLearn.isEmpty) {
      SnackBarHelper.error(
        context,
        'Please select at least one skill for each category',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userService = UserService();

      if (authProvider.currentUser != null) {
        await userService.updateUser(authProvider.currentUser!.uid, {
          'canTeach': _canTeach,
          'wantsToLearn': _wantsToLearn,
        });

        // Update the auth provider with the new skills
        final updatedUser = authProvider.currentUser!.copyWith(
          canTeach: _canTeach,
          wantsToLearn: _wantsToLearn,
        );
        authProvider.currentUser = updatedUser;

        if (mounted) {
          SnackBarHelper.success(context, 'Skills updated successfully!');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, 'Error saving skills: $e');
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Skills'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Can Teach Section
            Text('What can you teach?', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Select the skills you\'d like to share with others',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ChipSelector(
              items: skills,
              selectedItems: _canTeach,
              onChanged: (items) {
                setState(() => _canTeach = items);
              },
              multiSelect: true,
              itemsPerRow: 3,
            ),
            const SizedBox(height: 40),

            // Wants to Learn Section
            Text('What do you want to learn?', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Select the skills you\'d like to develop',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ChipSelector(
              items: skills,
              selectedItems: _wantsToLearn,
              onChanged: (items) {
                setState(() => _wantsToLearn = items);
              },
              multiSelect: true,
              itemsPerRow: 3,
            ),
            const SizedBox(height: 40),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSkills,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text('Save Skills', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
