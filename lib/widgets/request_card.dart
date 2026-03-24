import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class RequestCard extends StatelessWidget {
  final String senderName;
  final String skillToLearn;
  final String avatarInitial;
  final String timestamp;
  final String status;
  final String? message;
  final List<String> proposedTimeSlots;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCounter;

  const RequestCard({
    required this.senderName,
    required this.skillToLearn,
    required this.avatarInitial,
    required this.timestamp,
    required this.status,
    this.message,
    required this.proposedTimeSlots,
    this.onAccept,
    this.onDecline,
    this.onCounter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (message != null) ...[
            SizedBox(height: 12.0),
            _buildMessage(),
          ],
          SizedBox(height: 12.0),
          _buildTimeSlots(),
          if (onAccept != null && onDecline != null) ...[
            SizedBox(height: 12.0),
            _buildActionButtons(),
            if (onCounter != null) ...[
              SizedBox(height: 8.0),
              _buildCounterLink(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proposed times:',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.0),
        ...proposedTimeSlots.map((slot) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                SizedBox(width: 6.0),
                Text(
                  slot,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAccept,
            icon: Icon(Icons.check, size: 14),
            label: Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDecline,
            icon: Icon(Icons.close, size: 14),
            label: Text('Decline'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterLink() {
    return Center(
      child: GestureDetector(
        onTap: onCounter,
        child: Text(
          'Counter',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message!,
        style: AppTextStyles.bodySmall,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            avatarInitial,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                senderName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'wants to learn $skillToLearn',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              timestamp,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.textMuted;
      case 'accepted':
        return AppColors.success;
      case 'declined':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
