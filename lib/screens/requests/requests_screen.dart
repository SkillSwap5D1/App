import 'package:flutter/material.dart';
import 'package:skillswap_app/data/mock_data.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class RequestsScreen extends StatefulWidget {
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedTab = 'Incoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabToggle(),
            Expanded(
              child: _selectedTab == 'Incoming'
                  ? _buildIncomingTab()
                  : _buildOutgoingTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.mail, color: AppColors.primary),
              ),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requests',
                    style: AppTextStyles.h2,
                  ),
                  Text(
                    'Manage your skill exchange requests',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 'Incoming'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'Incoming'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Incoming (2)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedTab == 'Incoming'
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 'Outgoing'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _selectedTab == 'Outgoing'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Outgoing',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedTab == 'Outgoing'
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingTab() {
    return _buildEmptyState('No incoming requests',
        'You don\'t have any pending requests yet.');
  }

  Widget _buildOutgoingTab() {
    return _buildEmptyState('No outgoing requests',
        'You haven\'t sent any requests yet.');
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
