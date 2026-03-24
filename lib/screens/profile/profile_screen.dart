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

              // About section
              Text('About', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              Text(
                'I\'m a passionate Computer Science student in my third year. I love teaching programming concepts and helping others understand code. I specialize in Python, JavaScript, and have experience with Flutter for mobile development.',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Contact section
              Text('Contact', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),

              // Email row
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'sarah.johnson@myport.ac.uk',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Member since row
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member Since', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'January 15, 2024',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Privacy Settings section
              Text('Privacy Settings', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),

              // Show full name toggle
              _buildPrivacyToggle(
                title: 'Show my full name',
                subtitle: 'Visible to other students',
                value: _showFullName,
                onChanged: (value) {
                  setState(() => _showFullName = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Show course toggle
              _buildPrivacyToggle(
                title: 'Show my course',
                subtitle: 'Display your program info',
                value: _showCourse,
                onChanged: (value) {
                  setState(() => _showCourse = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Show profile picture toggle
              _buildPrivacyToggle(
                title: 'Show my profile picture',
                subtitle: 'Avatar visible publicly',
                value: _showProfilePicture,
                onChanged: (value) {
                  setState(() => _showProfilePicture = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Edit Profile button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/edit-profile');
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: value ? AppColors.primary : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.check,
                color: value ? AppColors.primary : Colors.grey[300],
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
