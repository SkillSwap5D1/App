import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

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
    // Initialize privacy settings from current user or defaults
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _showFullName = authProvider.currentUser?.showFullName ?? true;
    _showCourse = authProvider.currentUser?.showCourse ?? true;
    _showProfilePicture = authProvider.currentUser?.showPhoto ?? true;
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.of(context).pushNamed('/edit-profile');

    // Handle returned data - refresh UI when profile is updated
    if (result is Map<String, dynamic>) {
      setState(() {
        _showFullName = result['showFullName'] ?? _showFullName;
        _showCourse = result['showCourse'] ?? _showCourse;
        _showProfilePicture = result['showPhoto'] ?? _showProfilePicture;
      });
    }
  }

  String _formatMemberSince(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${auth.currentUser?.firstName} ${auth.currentUser?.lastName}'),
              Text('Email: ${auth.currentUser?.email}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _handleSignOut(context),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Widget buildOld(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.h3),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Text(
                'No user data available',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          return SingleChildScrollView(
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.surface,
                              fontSize: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Name
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Rating with stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.accentLight,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.rating.toStringAsFixed(1)} (${user.sessionsCompleted} reviews)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Course
                        Text(
                          user.course,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Member since
                        Text(
                          'Member since ${_formatMemberSince(user.memberSince)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          user.sessionsCompleted.toString(),
                          'Sessions\nCompleted',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          user.rating.toStringAsFixed(1),
                          'Rating',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          '${user.sessionsCompleted}',
                          'Skills\nOffered',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // About section
                  Text('About', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.bio.isNotEmpty ? user.bio : 'No bio added yet',
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
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                              Text(user.email, style: AppTextStyles.bodySmall),
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
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                                _formatMemberSince(user.memberSince),
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
                      onPressed: _navigateToEditProfile,
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
                  const SizedBox(height: AppSpacing.md),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Sign out
                        await context.read<AuthProvider>().signOut();

                        // Navigate to login/registration page
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/auth', (route) => false);
                        }
                      },
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
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
          );
        },
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
          border: Border.all(color: AppColors.border),
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
                      color: AppColors.textSecondary,
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
                  color: value ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.check,
                color: value ? AppColors.primary : AppColors.textMuted,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
