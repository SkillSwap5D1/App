import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/time_slot.dart';
import '../../theme/app_theme.dart';
import '../../widgets/time_slot_picker.dart';

class CounterOfferScreen extends StatefulWidget {
  final MockRequest originalRequest;

  const CounterOfferScreen({super.key, required this.originalRequest});

  @override
  State<CounterOfferScreen> createState() => _CounterOfferScreenState();
}

class _CounterOfferScreenState extends State<CounterOfferScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  List<TimeSlot> _selectedTimeSlots = [];
  final TextEditingController _messageController = TextEditingController();

  // ── VALIDATION ─────────────────────────────────────────────────────────────
  bool get _isValid {
    if (_selectedTimeSlots.isEmpty) return false;
    return _selectedTimeSlots.any((slot) => slot.isValid);
  }

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
  void initState() {
    super.initState();
    _selectedTimeSlots = [TimeSlot()];
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
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.sm),
                _buildOriginalRequestCard(),
                SizedBox(height: AppSpacing.xl),
                _buildProposeHeading(),
                SizedBox(height: AppSpacing.md),
                _buildTimeSlotsSection(),
                SizedBox(height: AppSpacing.xl),
                _buildMessageField(),
                SizedBox(height: AppSpacing.lg),
                _buildSubmitButton(),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOriginalRequestCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Request',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            widget.originalRequest.skillName,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Requested by: ${widget.originalRequest.fromUserName}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Status: ${widget.originalRequest.status}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProposeHeading() {
    return Text('Propose New Times', style: AppTextStyles.h3);
  }

  void _removeTimeSlot(int index) {
    if (_selectedTimeSlots.length > 1) {
      setState(() {
        _selectedTimeSlots.removeAt(index);
      });
    }
  }

  void _addTimeSlot() {
    if (_selectedTimeSlots.length < 3) {
      setState(() {
        _selectedTimeSlots.add(TimeSlot());
      });
    }
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(
            _selectedTimeSlots.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TimeSlotPicker(
                slot: _selectedTimeSlots[index],
                onRemove: () => _removeTimeSlot(index),
                showRemove: _selectedTimeSlots.length > 1,
              ),
            ),
          ),
        ),
        if (_selectedTimeSlots.length < 3)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text('Add another time slot'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderLight, width: 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message (Optional)', style: AppTextStyles.label),
        SizedBox(height: AppSpacing.sm),
        Container(
          color: Colors.white,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(18),
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
          disabledBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Send Counter Offer',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
