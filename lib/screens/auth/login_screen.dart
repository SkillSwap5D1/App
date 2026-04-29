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
      } else if (!normalized.endsWith('@port.ac.uk')) {
        _emailError = 'Please use your @port.ac.uk email (University of Portsmouth)';
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
    if (!email.endsWith('@port.ac.uk')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use your @port.ac.uk email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<AuthProvider>().signIn(
          email,
          _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      final authProvider = context.read<AuthProvider>();
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      } else if (authProvider.currentUser != null) {
        Navigator.of(context).pushReplacementNamed('/home');
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Floating emoji decorations
          _buildFloatingEmojis(),

          // Main content
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: AppColors.background),
              child: Column(
                children: [
                  // Logo and header section
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Graduation cap icon
                        Text('🎓', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'SkillSwap',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: isMobile ? 24 : 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form card
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? AppSpacing.md : 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
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
                                // Welcome heading
                                Text(
                                  'Welcome back',
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: isMobile ? 18 : 22,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Sign in to continue learning',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Email field
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

                                // Password field
                                Text('Password', style: AppTextStyles.label),
                                const SizedBox(height: AppSpacing.sm),
                                _buildPasswordField(),
                                const SizedBox(height: AppSpacing.lg),

                                // Sign in button
                                _buildSignInButton(),
                                const SizedBox(height: AppSpacing.md),

                                // Create account link
                                Center(
                                  child: GestureDetector(
                                    onTap: _navigateToRegister,
                                    child: Text(
                                      'Create an account',
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

                          // Sign-in guidance
                          Text(
                            'Sign in with your University of Portsmouth account (ends with @port.ac.uk) or use Google.',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        hintText: 'you@port.ac.uk',
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
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

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
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
                    Text('Sign In', style: AppTextStyles.button),
                    const SizedBox(width: AppSpacing.xs),
                    const Text('→', style: AppTextStyles.button),
                  ],
                ),
      ),
    );
  }

  Widget _buildFloatingEmojis() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top left - Books
          Positioned(
            top: 60,
            left: 20,
            child: Opacity(
              opacity: 0.15,
              child: Text('📚', style: TextStyle(fontSize: 48)),
            ),
          ),
          // Top right - Music note
          Positioned(
            top: 80,
            right: 30,
            child: Opacity(
              opacity: 0.15,
              child: Text('🎵', style: TextStyle(fontSize: 40)),
            ),
          ),
          // Bottom left - Lightbulb
          Positioned(
            bottom: 200,
            left: 30,
            child: Opacity(
              opacity: 0.15,
              child: Text('💡', style: TextStyle(fontSize: 44)),
            ),
          ),
          // Bottom right - Paint palette
          Positioned(
            bottom: 250,
            right: 20,
            child: Opacity(
              opacity: 0.15,
              child: Text('🎨', style: TextStyle(fontSize: 48)),
            ),
          ),
        ],
      ),
    );
  }
}
