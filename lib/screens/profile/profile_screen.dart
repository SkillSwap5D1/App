import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import './edit_profile_screen.dart';
import './edit_skills_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _showFullName;
  late bool _showCourse;
  late bool _showPhoto;

  @override
  void initState() {
    super.initState();
    _initializePrivacySettings();
  }

  void _initializePrivacySettings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _showFullName = authProvider.currentUser?.showFullName ?? true;
    _showCourse = authProvider.currentUser?.showCourse ?? true;
    _showPhoto = authProvider.currentUser?.showPhoto ?? true;
  }

  String _getDisplayName(String firstName, String lastName) {
    if (!_showFullName) {
      return '$firstName ${lastName[0]}.';
    }
    return '$firstName $lastName';
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
    return 'Member since ${months[date.month - 1]} ${date.year}';
  }

  int _getReviewCount(UserModel user) {
    return user.totalReviews;
  }

  void _handlePrivacyToggle(
    String setting,
    bool newValue,
    AuthProvider authProvider,
  ) async {
    setState(() {
      if (setting == 'fullName') _showFullName = newValue;
      if (setting == 'course') _showCourse = newValue;
      if (setting == 'photo') _showPhoto = newValue;
    });

    try {
      await authProvider.updatePrivacySettings(
        showFullName: _showFullName,
        showCourse: _showCourse,
        showPhoto: _showPhoto,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update privacy settings: $e')),
      );
      _initializePrivacySettings();
      setState(() {});
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));

    if (result is bool && result) {
      _initializePrivacySettings();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          return ListView(
            children: [
              // ─────────────── HERO SECTION ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEDE9F6), Color(0xFFF5F3FF)],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    // Avatar with initials
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full name
                    Text(
                      _getDisplayName(user.firstName, user.lastName),
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Course (respects privacy)
                    if (_showCourse) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.course,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Star rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stars
                        Row(
                          children: List.generate(5, (index) {
                            final isFilled = index < user.rating;
                            return Icon(
                              isFilled ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),

                        // Rating number
                        Text(
                          user.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Review count
                        Text(
                          '(${_getReviewCount(user)} reviews)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          'Sessions',
                          user.sessionsCompleted.toString(),
                          'Completed',
                        ),
                        _buildDivider(),
                        _buildStatColumn(
                          'Rating',
                          user.rating.toStringAsFixed(1),
                          'Average',
                        ),
                        _buildDivider(),
                        _buildStatColumn('Skills', '2', 'Offered'),
                      ],
                    ),
                  ],
                ),
              ),

              // ─────────────── ABOUT SECTION ────────────────────────────────
              if (user.bio.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ─────────────── CONTACT SECTION ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Member since
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatMemberSince(user.memberSince),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─────────────── SKILLS SECTION ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Skills',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Can Teach Section
                    _buildSkillsSubsection(
                      title: 'Can Teach',
                      skills: user.canTeach,
                    ),
                    const SizedBox(height: 16),

                    // Wants to Learn Section
                    _buildSkillsSubsection(
                      title: 'Wants to Learn',
                      skills: user.wantsToLearn,
                    ),
                    const SizedBox(height: 12),

                    // Edit Skills Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToEditSkills,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Skills'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─────────────── PRIVACY SETTINGS ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Privacy Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Toggle 1: Show full name
                    _buildPrivacyToggle(
                      title: 'Show my full name',
                      subtitle: 'Visible to other students',
                      value: _showFullName,
                      onChanged:
                          (value) => _handlePrivacyToggle(
                            'fullName',
                            value,
                            authProvider,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Toggle 2: Show course
                    _buildPrivacyToggle(
                      title: 'Show my course',
                      subtitle: 'Display your program info',
                      value: _showCourse,
                      onChanged:
                          (value) => _handlePrivacyToggle(
                            'course',
                            value,
                            authProvider,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Toggle 3: Show profile picture
                    _buildPrivacyToggle(
                      title: 'Show my profile picture',
                      subtitle: 'Avatar visible publicly',
                      value: _showPhoto,
                      onChanged:
                          (value) => _handlePrivacyToggle(
                            'photo',
                            value,
                            authProvider,
                          ),
                    ),
                  ],
                ),
              ),

              // ─────────────── EDIT PROFILE BUTTON ────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _navigateToEditProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // ─────────────── SIGN OUT BUTTON ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton(
                  onPressed: () => _handleSignOut(authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String sublabel) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sublabel,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  void _handleSignOut(AuthProvider authProvider) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await authProvider.signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully')),
                    );
                    // Navigate to login screen after signing out
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  Widget _buildSkillsSubsection({
    required String title,
    required List<String> skills,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (skills.isEmpty)
          Text(
            'No skills selected yet',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                skills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentVeryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  void _navigateToEditSkills() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditSkillsScreen()));

    if (result is bool && result) {
      setState(() {});
    }
  }
}
