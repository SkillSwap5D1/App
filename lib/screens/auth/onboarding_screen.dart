import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

              // Teach skills placeholder
              Container(
                color: Colors.grey[100],
                height: 200,
                child: const Center(child: Text('Teach skills grid here')),
              ),
              const SizedBox(height: AppSpacing.lg),

              // What do you want to learn section
              Text('What do you want to learn?', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Select the skills you\'re interested in',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Learn skills placeholder
              Container(
                color: Colors.grey[100],
                height: 200,
                child: const Center(child: Text('Learn skills grid here')),
              ),
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
}
