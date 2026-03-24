import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Privacy settings state
  late bool _showFullName;
  late bool _showCourse;
  late bool _showProfilePicture;

  @override
  void initState() {
    super.initState();
    _showFullName = true;
    _showCourse = true;
    _showProfilePicture = true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h3),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.md : 40,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              // Hero section with avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Avatar circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Text('👤', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Name
                    Text(
                      'Sarah Johnson',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Rating with stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '⭐ 4.8 (24 reviews)',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Course
                    Text(
                      'Computer Science',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Member since
                    Text(
                      'Member since January 2024',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats row
              Row(
                children: [
                  Expanded(child: _buildStatCard('12', 'Sessions\nCompleted')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildStatCard('4.8', 'Rating')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildStatCard('8', 'Skills\nOffered')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
