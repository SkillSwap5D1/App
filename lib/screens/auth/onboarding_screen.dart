import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/services/user_service.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/widgets/chip_selector_widget.dart';
import 'package:skillswap_app/widgets/snackbar_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> _canTeach = [];
  List<String> _wantsToLearn = [];
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
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
          'onboardingComplete': true,
        });

        // Update the auth provider with the new skills
        await authProvider.updateSkills(
          canTeach: _canTeach,
          wantsToLearn: _wantsToLearn,
        );

        if (mounted) {
          SnackBarHelper.success(context, 'Welcome to SkillSwap!');
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
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

  Future<void> _skipOnboarding() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userService = UserService();

      if (authProvider.currentUser != null) {
        await userService.updateUser(authProvider.currentUser!.uid, {
          'canTeach': [],
          'wantsToLearn': [],
          'onboardingComplete': true,
        });

        // Update the auth provider with empty skills
        await authProvider.updateSkills(canTeach: [], wantsToLearn: []);

        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.error(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.editorialGradient),
          child: Column(
            children: [
              // Skip button + progress
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'Step ${_currentPage + 1}/2',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _buildPage(
                      title: 'What can you teach?',
                      subtitle: 'Select the skills you\'d like to share',
                      selectedItems: _canTeach,
                      onChanged: (items) {
                        setState(() => _canTeach = items);
                      },
                    ),
                    _buildPage(
                      title: 'What do you want to learn?',
                      subtitle: 'Select the skills you\'d like to develop',
                      selectedItems: _wantsToLearn,
                      onChanged: (items) {
                        setState(() => _wantsToLearn = items);
                      },
                    ),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (_currentPage == 0) {
                                  if (_canTeach.isEmpty) {
                                    SnackBarHelper.error(
                                      context,
                                      'Please select at least one skill',
                                    );
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                } else {
                                  _completeOnboarding();
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 0 ? 'Next' : 'Get Started',
                        style: AppTextStyles.button,
                      ),
                    ),

                    if (_currentPage > 0) const SizedBox(height: AppSpacing.sm),

                    if (_currentPage > 0)
                      TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                        child: Text(
                          'Back',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2),
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ChipSelector(
            items: skills,
            selectedItems: selectedItems,
            onChanged: onChanged,
            multiSelect: true,
            itemsPerRow: 3,
          ),
        ],
      ),
    );
  }
}
