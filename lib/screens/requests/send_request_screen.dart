import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../models/time_slot.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/time_slot_picker.dart';

class SendRequestScreen extends StatefulWidget {
  final ListingModel listing;

  const SendRequestScreen({
    super.key,
    required this.listing,
  });

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  late List<TimeSlot> _timeSlots;
  final TextEditingController _noteController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _timeSlots = [TimeSlot()];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _removeTimeSlot(int index) {
    if (_timeSlots.length > 1) {
      setState(() {
        _timeSlots.removeAt(index);
        _errorMessage = '';
      });
    }
  }

  void _addTimeSlot() {
    if (_timeSlots.length < 3) {
      setState(() {
        _timeSlots.add(TimeSlot());
        _errorMessage = '';
      });
    }
  }

  void _submitRequest() {
    // Validate at least one time slot is filled and valid
    if (_timeSlots.isEmpty) {
      setState(() {
        _errorMessage = 'Add at least one time slot';
      });
      return;
    }

    final validSlots = _timeSlots.where((slot) => slot.isValid).toList();
    if (validSlots.isEmpty) {
      setState(() {
        _errorMessage = 'Please fix errors in time slots';
      });
      return;
    }

    _sendRequestToBackend(validSlots);
  }

  Future<void> _sendRequestToBackend(List<TimeSlot> validSlots) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be signed in to send a request';
      });
      return;
    }

    final proposedTimes = validSlots.map(_formatTimeSlot).toList();

    final request = RequestModel(
      id: '',
      fromUserId: currentUser.uid,
      fromUserName: currentUser.fullName,
      toUserId: widget.listing.ownerId,
      listingId: widget.listing.id,
      skillName: widget.listing.title,
      message: _noteController.text.trim(),
      status: 'pending',
      proposedTimes: proposedTimes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final requestProvider = context.read<RequestProvider>();
    final requestId = await requestProvider.sendRequest(request);

    if (!mounted) return;

    if (requestId == null) {
      setState(() {
        _errorMessage = requestProvider.errorMessage ?? 'Failed to send request';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent successfully'),
        duration: Duration(milliseconds: 1500),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  String _formatTimeSlot(TimeSlot slot) {
    final date = slot.date!;
    final start = _formatTime(slot.startTime!);
    final end = _formatTime(slot.endTime!);
    return '${date.month}/${date.day}/${date.year} $start - $end';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? AppSpacing.md : AppSpacing.lg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: CircleAvatar(
            backgroundColor: AppColors.accentLight,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.accent),
              onPressed: () => Navigator.pop(context),
              splashRadius: 20,
            ),
          ),
        ),
        title: Text(
          'Send Request',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.md),

              // Listing Summary Section
              _buildListingSummary(),
              SizedBox(height: AppSpacing.xl),

              // Time Slots Section
              _buildTimeSlotsSection(),
              SizedBox(height: AppSpacing.lg),

              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.error, width: 1),
                  ),
                  child: Text(
                    _errorMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(height: AppSpacing.lg),

              // Note field
              _buildNoteField(),
              SizedBox(height: AppSpacing.xl),

              // Send Request button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Send Request',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and provider
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.listing.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'with ${widget.listing.ownerName}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.accentLight,
                child: Text(
                  widget.listing.ownerName
                      .split(' ')
                      .map((n) => n[0])
                      .take(2)
                      .join()
                      .toUpperCase(),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Tags
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.listing.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Propose Time Slots',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // Time slot items
        Column(
          children: List.generate(
            _timeSlots.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TimeSlotPicker(
                slot: _timeSlots[index],
                onRemove: () => _removeTimeSlot(index),
                showRemove: _timeSlots.length > 1,
              ),
            ),
          ),
        ),

        // Add another time slot button
        if (_timeSlots.length < 3)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add),
              label: const Text('Add another time slot'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message (optional)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add a note for the provider...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }
}
