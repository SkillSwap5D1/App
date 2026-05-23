import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/review_tile.dart';
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
  String? _loadedReviewsForUserId;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _showFullName = authProvider.currentUser?.showFullName ?? true;
    _showCourse = authProvider.currentUser?.showCourse ?? true;
    _showPhoto = authProvider.currentUser?.showPhoto ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId != null && _loadedReviewsForUserId != userId) {
      _loadedReviewsForUserId = userId;
      context.read<ReviewProvider>().loadReviewsForUser(userId);
    }
  }

  String _getDisplayName(String firstName, String lastName) {
    if (!_showFullName) {
      return '$firstName ${lastName[0]}.';
    }
    return '$firstName $lastName';
  }

  String _formatMemberSince(DateTime date) {
    const months = [
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

  int _getReviewCount(UserModel user) => user.totalReviews;

  Future<void> _handlePrivacyToggle(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update privacy settings: $e')),
      );
      final currentUser = authProvider.currentUser;
      if (currentUser != null) {
        _showFullName = currentUser.showFullName;
        _showCourse = currentUser.showCourse;
        _showPhoto = currentUser.showPhoto;
      }
      setState(() {});
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result is bool && result) {
      setState(() {});
    }
  }

  Future<void> _navigateToEditSkills() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditSkillsScreen()),
    );

    if (result is bool && result) {
      setState(() {});
    }
  }

  Future<void> _handleSignOut(AuthProvider authProvider) async {
    await authProvider.signOut();
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFB7DEC7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, String sublabel) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFB7DEC7),
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
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (skills.isEmpty)
          const Text(
            'No skills added yet.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFDFFBF1)),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Consumer2<AuthProvider, ReviewProvider>(
            builder: (context, authProvider, reviewProvider, _) {
              final user = authProvider.currentUser;
              if (user == null) {
                return const Center(child: Text('No user data'));
              }

              final reviews = reviewProvider.reviews;

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildCard(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB7DEC7),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getDisplayName(user.firstName, user.lastName),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (user.course.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.course,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              user.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${_getReviewCount(user)} reviews)',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              _buildStat('Sessions', user.sessionsCompleted.toString(), 'Completed'),
                              Container(width: 1, height: 56, color: const Color(0xFFE2E8F0)),
                              _buildStat('Rating', user.rating.toStringAsFixed(1), 'Average'),
                              Container(width: 1, height: 56, color: const Color(0xFFE2E8F0)),
                              _buildStat('Skills', '${user.canTeach.length}', 'Offered'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user.bio.isNotEmpty)
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFB7DEC7), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'About',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.bio,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.mail_outline, color: Color(0xFFB7DEC7), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Contact',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPill(Icons.mail_outline, user.email),
                        const SizedBox(height: 8),
                        _buildPill(Icons.calendar_today_outlined, _formatMemberSince(user.memberSince)),
                      ],
                    ),
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school_outlined, color: Color(0xFFB7DEC7), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Skills',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSkillsSubsection(title: 'Can Teach', skills: user.canTeach),
                        const SizedBox(height: 16),
                        _buildSkillsSubsection(title: 'Wants to Learn', skills: user.wantsToLearn),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToEditSkills,
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit Skills'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFB7DEC7),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline, color: Color(0xFFB7DEC7), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Privacy Settings',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPrivacyToggle(
                          title: 'Show my full name',
                          subtitle: 'Visible to other students',
                          value: _showFullName,
                          onChanged: (value) => _handlePrivacyToggle('fullName', value, authProvider),
                        ),
                        const SizedBox(height: 12),
                        _buildPrivacyToggle(
                          title: 'Show my course',
                          subtitle: 'Display your program info',
                          value: _showCourse,
                          onChanged: (value) => _handlePrivacyToggle('course', value, authProvider),
                        ),
                        const SizedBox(height: 12),
                        _buildPrivacyToggle(
                          title: 'Show my profile picture',
                          subtitle: 'Avatar visible publicly',
                          value: _showPhoto,
                          onChanged: (value) => _handlePrivacyToggle('photo', value, authProvider),
                        ),
                      ],
                    ),
                  ),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.star_outline, color: Color(0xFFB7DEC7), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Reviews',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${reviews.length}',
                              style: const TextStyle(
                                color: Color(0xFFB7DEC7),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (reviews.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'No reviews yet.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              final reviewer = reviewProvider.reviewers[review.reviewerId];
                              final reviewerName = reviewer?.displayName ?? 'Unknown User';
                              final reviewerInitial = reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?';

                              return FutureBuilder<UserModel?>(
                                future: reviewer != null
                                    ? Future.value(reviewer)
                                    : UserService().getUser(review.reviewerId),
                                builder: (context, snapshot) {
                                  final loadedReviewer = snapshot.data;
                                  final resolvedName = loadedReviewer?.displayName ?? reviewerName;
                                  final resolvedInitial = resolvedName.isNotEmpty ? resolvedName[0].toUpperCase() : reviewerInitial;

                                  return ReviewTile(
                                    review: review,
                                    reviewerName: resolvedName,
                                    reviewerInitial: resolvedInitial,
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToEditProfile,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB7DEC7),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ElevatedButton(
                      onPressed: () => _handleSignOut(authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}