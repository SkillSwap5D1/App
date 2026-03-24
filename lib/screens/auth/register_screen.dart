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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  void _validatePasswords(String value) {
    setState(() {
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _passwordError = null;
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = 'Passwords do not match';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleCreateAccount() async {
    // Validate first name
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('First name is required')));
      return;
    }

    // Validate last name
    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Last name is required')));
      return;
    }

    // Validate email field
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }

    // Validate email format
    if (_emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use your @myport.ac.uk email')),
      );
      return;
    }

    // Validate password field
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password is required')));
      return;
    }

    // Validate confirm password field
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm your password')),
      );
      return;
    }

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Validate course selection
    if (_selectedCourse == null || _selectedCourse!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your course')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to onboarding screen
      Navigator.of(context).pushNamed('/onboarding');
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).pop();
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

                          // Password field
                          Text('Password', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPasswordField(),
                          const SizedBox(height: AppSpacing.md),

                          // Confirm password field
                          Text('Confirm password', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.sm),
                          _buildConfirmPasswordField(),
                          if (_passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                _passwordError!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.lg),

                          // Create account button
                          _buildCreateAccountButton(),
                          const SizedBox(height: AppSpacing.md),

                          // Sign in link
                          Center(
                            child: GestureDetector(
                              onTap: _navigateToSignIn,
                              child: Text(
                                'Already have an account? Sign in',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.surface,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create Account', style: AppTextStyles.button),
                    const SizedBox(width: AppSpacing.xs),
                    const Text('→', style: AppTextStyles.button),
                  ],
                ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      onChanged: (_) => _validatePasswords(''),
      decoration: InputDecoration(
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        prefixIconColor: AppColors.textMuted,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textMuted,
          ),
        ),
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

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      onChanged: _validatePasswords,
      decoration: InputDecoration(
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        prefixIconColor: AppColors.textMuted,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(
              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
            );
          },
          child: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textMuted,
          ),
        ),
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
