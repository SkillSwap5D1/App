import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _selectedCourse;

  final List<String> _courses = [
    'Computer Science',
    'Business',
    'Psychology',
    'Engineering',
    'Medicine',
    'Law',
    'Architecture',
    'Nursing',
    'Pharmacy',
    'Economics',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!value.endsWith('@myport.ac.uk')) {
        _emailError = 'Please use your @myport.ac.uk email';
      } else {
        _emailError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Floating emoji decorations
          _buildFloatingEmojis(),

          // Main content
          SingleChildScrollView(
            child: Container(
              minHeight: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: AppColors.background),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? AppSpacing.md : 40,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Logo and header section
                    Text('🎓', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'SkillSwap',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: isMobile ? 24 : 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Form card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Create account heading
                          Text(
                            'Create account',
                            style: AppTextStyles.h2.copyWith(
                              fontSize: isMobile ? 18 : 22,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Join SkillSwap to start learning and sharing',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // First name and Last name (side by side)
                          Row(
                            children: [
                              // First name field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'First name',
                                      style: AppTextStyles.label,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _buildFirstNameField(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // Last name field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last name',
                                      style: AppTextStyles.label,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _buildLastNameField(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Email field
                          Text('University email', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.sm),
                          _buildEmailField(),
                          if (_emailError != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                _emailError!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),

                          // Course dropdown
                          Text('Course', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCourseDropdown(),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Demo mode hint
                    Text(
                      '● Demo mode — use any details with @myport.ac.uk email',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCourse,
          hint: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              'Select your course',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          ),
          iconSize: 24,
          elevation: 16,
          style: AppTextStyles.bodyMedium,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCourse = newValue;
            });
          },
          items:
              _courses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Text(value),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: _validateEmail,
      decoration: InputDecoration(
        hintText: 'you@myport.ac.uk',
        prefixIcon: const Icon(Icons.mail_outline),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }

  Widget _buildFirstNameField() {
    return TextField(
      controller: _firstNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'John',
        prefixIcon: const Icon(Icons.person_outline),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }

  Widget _buildLastNameField() {
    return TextField(
      controller: _lastNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'Doe',
        prefixIcon: const Icon(Icons.person_outline),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }

  Widget _buildFloatingEmojis() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top left - Handshake
          Positioned(
            top: 60,
            left: 20,
            child: Opacity(
              opacity: 0.15,
              child: Text('🤝', style: TextStyle(fontSize: 48)),
            ),
          ),
          // Top right - Rocket
          Positioned(
            top: 80,
            right: 30,
            child: Opacity(
              opacity: 0.15,
              child: Text('🚀', style: TextStyle(fontSize: 40)),
            ),
          ),
          // Bottom left - Star
          Positioned(
            bottom: 200,
            left: 30,
            child: Opacity(
              opacity: 0.15,
              child: Text('⭐', style: TextStyle(fontSize: 44)),
            ),
          ),
          // Bottom right - Sparkles
          Positioned(
            bottom: 250,
            right: 20,
            child: Opacity(
              opacity: 0.15,
              child: Text('✨', style: TextStyle(fontSize: 48)),
            ),
          ),
        ],
      ),
    );
  }
}
