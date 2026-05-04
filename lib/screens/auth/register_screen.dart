import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

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
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) {
        _emailError = null;
      } else if (!normalized.endsWith('@port.ac.uk')) {
        _emailError = 'Please use your @port.ac.uk email (University of Portsmouth)';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate last name
    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate email field
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate email format
    if (!email.endsWith('@port.ac.uk')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use your @port.ac.uk email (University of Portsmouth)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate password field
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate confirm password field
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm your password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate course selection
    if (_selectedCourse == null || _selectedCourse!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your course'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Call AuthProvider.register()
    if (mounted) {
      await context.read<AuthProvider>().register(
        email: email,
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            course: _selectedCourse!,
          );

      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (authProvider.currentUser != null) {
          // Navigate straight to browse after successful account creation
          Navigator.of(context).pushReplacementNamed('/browse');
        }
      }
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final providerLoading = context.watch<AuthProvider>().isLoading;
    final isLoading = _isLoading || providerLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
          ),

          // Subtle decorative glow accents
          _buildDecorativeGlow(),

          // Main content
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? AppSpacing.md : 40,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Logo and header section
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: AppShadows.hover,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'SkillSwap',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: isMobile ? 24 : 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Form card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: AppColors.glassCard(borderRadius: 28),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create account',
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: isMobile ? 22 : 24,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Join SkillSwap to start learning and sharing',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Divider(color: AppColors.borderLight),
                              const SizedBox(height: AppSpacing.lg),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('First name', style: AppTextStyles.label),
                                        const SizedBox(height: AppSpacing.sm),
                                        _buildFirstNameField(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Last name', style: AppTextStyles.label),
                                        const SizedBox(height: AppSpacing.sm),
                                        _buildLastNameField(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              Text('University email', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildEmailField(),
                              if (_emailError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    _emailError!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.md),

                              Text('Course', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildCourseDropdown(),
                              const SizedBox(height: AppSpacing.md),

                              Text('Password', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildPasswordField(),
                              const SizedBox(height: AppSpacing.md),

                              Text('Confirm password', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildConfirmPasswordField(),
                              if (_passwordError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    _passwordError!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.lg),

                              _buildCreateAccountButton(isLoading),
                              const SizedBox(height: AppSpacing.md),

                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppColors.borderLight)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: Text('or', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                  ),
                                  Expanded(child: Divider(color: AppColors.borderLight)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              _buildGoogleSignInButton(isLoading),
                              const SizedBox(height: AppSpacing.md),

                              Center(
                                child: GestureDetector(
                                  onTap: _navigateToSignIn,
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      children: [
                                        const TextSpan(text: 'Already have an account? '),
                                        TextSpan(
                                          text: 'Sign in',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Sign-up guidance
                    Text(
                      'Please sign up using your University of Portsmouth email (ending in @port.ac.uk) or use Google.',
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

  Widget _buildCreateAccountButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.accentGradient,
          color: isLoading ? AppColors.accentUltraLight : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isLoading ? null : AppShadows.hover,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleCreateAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
            child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create Account', style: AppTextStyles.button),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderLight),
          backgroundColor: AppColors.accentUltraLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined, size: 20, color: AppColors.accentLight),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Sign up with Google',
              style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    print('🔵 Starting Google Sign-In...');
    if (mounted) {
      try {
        final authProvider = context.read<AuthProvider>();
        print('🔵 Calling signInWithGoogle()...');
        await authProvider.signInWithGoogle();
        print('🔵 signInWithGoogle() completed');
        
        // Check for errors
        if (mounted) {
          print('🔵 Error message: ${authProvider.errorMessage}');
          if (authProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.errorMessage!),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            print('✅ Google Sign-In successful!');
          }
        }
      } catch (e) {
        print('❌ Google Sign-In exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      onChanged: (_) => _validatePasswords(''),
      decoration: InputDecoration(
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        prefixIconColor: AppColors.accentLight,
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
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
        prefixIconColor: AppColors.accentLight,
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(AppRadius.md),
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
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.accentLight),
          ),
          iconSize: 24,
          elevation: 16,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
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
                    child: Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
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
        hintText: 'you@port.ac.uk',
        prefixIcon: const Icon(Icons.mail_outline),
        prefixIconColor: AppColors.accentLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildFirstNameField() {
    return TextField(
      controller: _firstNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'John',
        prefixIcon: const Icon(Icons.person_outline),
        prefixIconColor: AppColors.accentLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildLastNameField() {
    return TextField(
      controller: _lastNameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: 'Doe',
        prefixIcon: const Icon(Icons.person_outline),
        prefixIconColor: AppColors.accentLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderActive, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildDecorativeGlow() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top left glow
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentVeryLight.withOpacity(0.95),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Top right glow
          Positioned(
            top: 80,
            right: 30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentLight.withOpacity(0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom left glow
          Positioned(
            bottom: 200,
            left: 30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentUltraLight.withOpacity(0.95),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom right glow
          Positioned(
            bottom: 250,
            right: 20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentVeryLight.withOpacity(0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
