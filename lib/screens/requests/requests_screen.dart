import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/request_model.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedTab = 'Incoming';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUid = authProvider.currentUser?.uid;
      if (currentUid != null) {
        context.read<RequestProvider>().loadRequests(currentUid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.editorialGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTabToggle(),
              Expanded(
                child: Consumer2<RequestProvider, AuthProvider>(
                  builder: (context, requestProvider, authProvider, _) {
                    final incomingRequests = requestProvider.incoming;
                    final outgoingRequests = requestProvider.outgoing;
                    final currentUid = authProvider.currentUser?.uid ?? '';

                    return _selectedTab == 'Incoming'
                        ? _buildIncomingTab(incomingRequests, requestProvider, currentUid)
                        : _buildOutgoingTab(outgoingRequests);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(Icons.mark_email_unread_rounded, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requests',
                    style: AppTextStyles.h2,
                  ),
                  Text(
                    'Incoming and outgoing skill exchanges',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
      child: Consumer<RequestProvider>(
        builder: (context, requestProvider, _) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 'Incoming'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 'Incoming' ? AppColors.accentGradient : null,
                        color: _selectedTab == 'Incoming' ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Incoming (${requestProvider.incoming.length})',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _selectedTab == 'Incoming'
                              ? Colors.white
                              : AppColors.textSecondary,
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
                        gradient: _selectedTab == 'Outgoing' ? AppColors.accentGradient : null,
                        color: _selectedTab == 'Outgoing' ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Outgoing (${requestProvider.outgoing.length})',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _selectedTab == 'Outgoing'
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomingTab(
    List<RequestModel> requests,
    RequestProvider provider,
    String currentUid,
  ) {
    if (requests.isEmpty) {
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
              'No incoming requests',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'You don\'t have any pending requests yet.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final status = request.status;
        final isLast = index == requests.length - 1;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with sender name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                              backgroundColor: AppColors.surface,
                            child: Text(
                              request.fromUserName.isNotEmpty
                                  ? request.fromUserName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.fromUserName,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Wants to learn: ${request.skillName}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Skill and message
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Message:',
                          style: AppTextStyles.label,
                        ),
                        SizedBox(height: 4),
                        Text(
                          request.message,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Proposed time slots
                  if (request.proposedTimes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proposed Time Slots:',
                          style: AppTextStyles.label,
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: request.proposedTimes.asMap().entries.map((e) {
                            return Chip(
                              label: Text(e.value),
                              backgroundColor: AppColors.accentLight,
                              labelStyle:
                                  AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accent,
                                  ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ),

                  // Action buttons
                  if (status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _declineRequest(
                              context,
                              request.id,
                              request.fromUserId,
                              request.skillName,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side:
                                  BorderSide(color: AppColors.error),
                            ),
                            child: Text('Decline'),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _acceptRequest(
                              context,
                              request,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text('Accept'),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Text(
                        'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
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

  Widget _buildOutgoingTab(List<RequestModel> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No outgoing requests',
              style: AppTextStyles.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'You haven\'t sent any requests yet.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final status = request.status;
        final isLast = index == requests.length - 1;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surface,
                            child: const Icon(Icons.person_outline_rounded, color: AppColors.accentLight, size: 20),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request sent',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'For: ${request.skillName}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Sent: ${_formatDate(request.createdAt)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
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

  Widget _buildStatusBadge(String status) {
    final bgColor = status == 'pending'
      ? const Color(0x1AA78BFA)
      : status == 'accepted'
        ? const Color(0x1910B981)
        : const Color(0x19EF4444);
    final textColor = status == 'pending'
        ? AppColors.accent
        : status == 'accepted'
            ? AppColors.primary
            : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context, RequestModel request) async {
    if (request.proposedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No time slots available')),
      );
      return;
    }

    // Show dialog to select time slot
    String? selectedSlot = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select a Time Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: request.proposedTimes.map((slot) {
              return ListTile(
                title: Text(slot),
                onTap: () => Navigator.pop(context, slot),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedSlot != null) {
      // Call provider to accept
      await context.read<RequestProvider>().acceptRequest(
            request.id,
            {'time': selectedSlot},
            request.fromUserName,
            request.skillName,
            request.fromUserId,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request accepted!')),
        );
      }
    }
  }

  Future<void> _declineRequest(
    BuildContext context,
    String requestId,
    String requesterId,
    String skillName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Decline Request'),
        content: Text('Are you sure you want to decline this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<RequestProvider>().declineRequest(
            requestId,
            requesterId,
            skillName,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request declined')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return date.toString().split(' ')[0];
    }
  }
}
