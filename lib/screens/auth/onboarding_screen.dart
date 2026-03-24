import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> _skillCategories = [
    'Programming',
    'Languages',
    'Music',
    'Design',
    'Business',
    'Mathematics',
    'Writing',
    'Fitness',
    'Cooking',
    'Photography',
    'Art',
    'Engineering',
  ];

  late Set<String> _selectedTeachSkills;
  late Set<String> _selectedLearnSkills;

  @override
  void initState() {
    super.initState();
    _selectedTeachSkills = {};
    _selectedLearnSkills = {};
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.md : 40,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Header
              Text(
                'Tell us about you',
                style: AppTextStyles.h1.copyWith(fontSize: isMobile ? 24 : 28),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This helps us match you with the right people',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // What can you teach section
              Text('What can you teach?', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select the skills you\'re good at',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Teach skills grid
              _buildSkillChipsGrid(_selectedTeachSkills),
              const SizedBox(height: AppSpacing.lg),

              // What do you want to learn section
              Text('What do you want to learn?', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select the skills you\'re interested in',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Learn skills grid
              _buildSkillChipsGrid(_selectedLearnSkills),
              const SizedBox(height: AppSpacing.lg),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Get Started', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Skip link
              Center(
                child: Text(
                  'Skip for now',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChipsGrid(Set<String> selectedSkills) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children:
          _skillCategories.map((skill) {
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
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isSelected ? AppColors.surface : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
