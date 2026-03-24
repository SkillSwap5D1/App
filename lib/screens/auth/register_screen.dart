import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
