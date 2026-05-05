import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) {
        _emailError = null;
      } else if (!normalized.endsWith('@myport.ac.uk')) {
        _emailError =
            'Please use your @myport.ac.uk email (University of Portsmouth)';
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _handleSignIn() async {
    // Validate email field
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }

    // Validate password field
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password is required')));
      return;
    }

    // Validate email format
    if (!email.endsWith('@myport.ac.uk')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use your @myport.ac.uk email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<AuthProvider>().signIn(email, _passwordController.text);

    if (mounted) {
      // Give a moment for state to fully propagate
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() => _isLoading = false);
        final authProvider = context.read<AuthProvider>();
        
        if (authProvider.errorMessage != null && authProvider.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (authProvider.currentUser != null && authProvider.currentUser!.uid.isNotEmpty) {
          // Sign-in successful - navigate to home
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        } else {
          // This shouldn't happen, but handle it gracefully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _navigateToRegister() {
    // Navigate to register screen
    Navigator.of(context).pushNamed('/register');
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
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
            ),
          ),
          _buildPremiumBackground(),

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: AppShadows.hover,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'SkillSwap',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: isMobile ? 32 : 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Learn and trade skills in a bright, premium space.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          decoration: AppColors.glassCard(borderRadius: 28),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome back',
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: isMobile ? 22 : 24,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Sign in to continue learning',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Divider(color: AppColors.borderLight),
                              const SizedBox(height: AppSpacing.md),
                              Text('Email', style: AppTextStyles.label),
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
                              Text('Password', style: AppTextStyles.label),
                              const SizedBox(height: AppSpacing.sm),
                              _buildPasswordField(),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSignInButton(isLoading),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'or',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: GestureDetector(
                                  onTap: _navigateToRegister,
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        const TextSpan(text: 'New here? '),
                                        TextSpan(
                                          text: 'Create an account',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
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
                    Text(
                      'Use your University of Portsmouth email ending in @myport.ac.uk or continue with Google.',
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

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: _validateEmail,
      decoration: InputDecoration(
        hintText: 'you@myport.ac.uk',
        prefixIcon: const Icon(Icons.mail_outline),
        prefixIconColor: AppColors.accentLight,
        fillColor: const Color(0xCCFFFFFF),
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
          borderSide: const BorderSide(
            color: AppColors.borderActive,
            width: 1.5,
          ),
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        prefixIconColor: AppColors.accentLight,
        fillColor: const Color(0xCCFFFFFF),
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
          borderSide: const BorderSide(
            color: AppColors.borderActive,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildSignInButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.accentGradient,
          color: _isLoading ? AppColors.surfaceElevated : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: _isLoading ? null : AppShadows.hover,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
          child:
              isLoading
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
                      Text('Sign In', style: AppTextStyles.button),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
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
          Positioned(
            top: 120,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentLight.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentUltraLight.withOpacity(0.9),
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
