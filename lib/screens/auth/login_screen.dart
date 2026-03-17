import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              decoration: BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  // Logo and header section
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Graduation cap icon
                        Text(
                          '🎓',
                          style: TextStyle(fontSize: 48),
                        ),
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

                  // Form card placeholder
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
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Demo mode hint
                          Text(
                            '● Demo mode — enter any email & password',
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
