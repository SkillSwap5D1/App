import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import 'package:skillswap_app/widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedTab = 'Incoming';

  // Mock incoming requests
  late final List<Map<String, dynamic>> _incomingRequests = [
    {
      'senderName': 'Sarah Chen',
      'avatarInitial': 'S',
      'skillToLearn': 'Web Development',
      'timestamp': '2 hours ago',
      'status': 'Pending',
      'message':
          'I\'m interested in learning web development. I can help you with graphic design in return!',
      'proposedTimeSlots': ['Tomorrow, 3 PM', 'Friday, 6 PM', 'Saturday, 10 AM'],
    },
    {
      'senderName': 'Alex Rivera',
      'avatarInitial': 'A',
      'skillToLearn': 'Python Programming',
      'timestamp': '5 hours ago',
      'status': 'Pending',
      'message': 'Would love to learn Python. I can teach you Spanish!',
      'proposedTimeSlots': ['Wednesday, 5 PM', 'Thursday, 6 PM'],
    },
  ];

  // Mock outgoing requests
  late final List<Map<String, dynamic>> _outgoingRequests = [
    {
      'senderName': 'John Doe',
      'avatarInitial': 'J',
      'skillToLearn': 'UI/UX Design',
      'timestamp': '1 day ago',
      'status': 'Accepted',
      'proposedTimeSlots': ['Next Monday, 4 PM'],
    },
  ];

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
                  color: AppColors.accentLight,
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
                    'Incoming (${_incomingRequests.length})',
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
                    'Outgoing (${_outgoingRequests.length})',
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
    if (_incomingRequests.isEmpty) {
      return _buildEmptyState('No incoming requests',
          'You don\'t have any pending requests yet.');
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _incomingRequests.length,
      itemBuilder: (context, index) {
        final request = _incomingRequests[index];
        final isLast = index == _incomingRequests.length - 1;
        return Column(
          children: [
            RequestCard(
              senderName: request['senderName'],
              skillToLearn: request['skillToLearn'],
              avatarInitial: request['avatarInitial'],
              timestamp: request['timestamp'],
              status: request['status'],
              message: request['message'],
              proposedTimeSlots: request['proposedTimeSlots'],
              onAccept: () => _handleAccept(index),
              onDecline: () => _handleDecline(index),
              onCounter: () => _handleCounter(index),
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(color: AppColors.border),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOutgoingTab() {
    if (_outgoingRequests.isEmpty) {
      return _buildEmptyState(
        'No outgoing requests',
        'You haven\'t sent any lesson requests yet.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _outgoingRequests.length,
      itemBuilder: (context, index) {
        final request = _outgoingRequests[index];
        final isLast = index == _outgoingRequests.length - 1;
        return Column(
          children: [
            RequestCard(
              senderName: request['senderName'],
              skillToLearn: request['skillToLearn'],
              avatarInitial: request['avatarInitial'],
              timestamp: request['timestamp'],
              status: request['status'],
              proposedTimeSlots: request['proposedTimeSlots'],
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(color: AppColors.border),
              ),
          ],
        );
      },
    );
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

  void _handleAccept(int index) {
    setState(() {
      _incomingRequests[index]['status'] = 'Accepted';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request accepted!')),
    );
  }

  void _handleDecline(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Decline Request'),
        content: Text('Are you sure you want to decline this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _incomingRequests[index]['status'] = 'Declined';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request declined.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _handleCounter(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Counter offer screen coming soon...')),
    );
  }
}
