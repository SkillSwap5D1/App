import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/time_slot.dart';
import '../../theme/app_theme.dart';
import '../../widgets/time_slot_picker.dart';

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

  // ── VALIDATION ─────────────────────────────────────────────────────────────
  bool get _isValid => _selectedTimeSlots.isNotEmpty;

  void _handleSubmit() {
    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Counter offer sent successfully!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to Requests screen after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

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
              _buildProposeHeading(),
              SizedBox(height: AppSpacing.md),
              TimeSlotPicker(
                selectedSlots: _selectedTimeSlots,
                onSlotsChanged: (slots) {
                  setState(() => _selectedTimeSlots = slots);
                },
              ),
              SizedBox(height: AppSpacing.lg),
              _buildMessageField(),
              SizedBox(height: AppSpacing.lg),
              _buildSubmitButton(),
              SizedBox(height: AppSpacing.lg),
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

  Widget _buildProposeHeading() {
    return Text(
      'Propose New Times',
      style: AppTextStyles.h3,
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message (Optional)',
          style: AppTextStyles.label,
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Explain why you need different times...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.md),
            ),
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isValid ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
        child: Text(
          'Send Counter Offer',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
