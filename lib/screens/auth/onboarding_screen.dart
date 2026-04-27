import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Set<String> _selectedTeachSkills = {};
  Set<String> _selectedLearnSkills = {};
  bool _isSaving = false;

  final List<String> _skills = [
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
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveTags() async {
    final userService = UserService();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      // Update user document with teach and learn tags
      await userService.updateUser(userId, {
        'teachSkills': _selectedTeachSkills.toList(),
        'learnSkills': _selectedLearnSkills.toList(),
      });

      if (mounted) {
        // Navigate to HomeShellScreen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              const Color(0xFFF5F2EC),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 24,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  final isActive = index == _currentPage;
                  return Container(
                    width: isActive ? 32 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accent : AppColors.textMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage(
                    title: 'What can you teach?',
                    selectedSkills: _selectedTeachSkills,
                  ),
                  _buildPage(
                    title: 'What do you want to learn?',
                    selectedSkills: _selectedLearnSkills,
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_currentPage == 0 &&
                              _selectedTeachSkills.isEmpty)
                          ? null
                          : (_isSaving
                              ? null
                              : () {
                                  if (_currentPage == 0) {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    _saveTags();
                                  }
                                }),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.surface,
                                ),
                              ),
                            )
                          : Text(
                              _currentPage == 0 ? 'Next →' : 'Get Started',
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required Set<String> selectedSkills,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Skill chips grid (3 per row)
            _buildSkillsGrid(selectedSkills),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(Set<String> selectedSkills) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _skills.map((skill) {
        final isSelected = selectedSkills.contains(skill);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSkills.remove(skill);
              } else {
                selectedSkills.add(skill);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentLight : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  skill,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
