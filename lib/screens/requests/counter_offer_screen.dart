import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/time_slot.dart';
import '../../theme/app_theme.dart';

class CounterOfferScreen extends StatefulWidget {
  final MockRequest originalRequest;

  const CounterOfferScreen({
    super.key,
    required this.originalRequest,
  });

  @override
  State<CounterOfferScreen> createState() => _CounterOfferScreenState();
}

class _CounterOfferScreenState extends State<CounterOfferScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  List<TimeSlot> _selectedTimeSlots = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Counter Offer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOriginalRequestCard(),
              SizedBox(height: AppSpacing.lg),
              // Time slot picker will go here
              // Message field will go here
              // Submit button will go here
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginalRequestCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Request',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '${widget.originalRequest.skillName}',
            style: AppTextStyles.h3,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Requested by: ${widget.originalRequest.senderName}',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Status: ${widget.originalRequest.status}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
