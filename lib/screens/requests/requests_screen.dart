import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../chat/chat_thread_screen.dart';
import '../reviews/rate_review_screen.dart';
import '../../widgets/notification_icon_button.dart';
import '../../models/request_model.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _loadedForUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _handleEndRequest(
    BuildContext context,
    RequestModel request,
  ) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End session'),
        content: Text(
          'Mark the session for ${request.skillName} as completed? This will allow both users to leave a review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('End', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (shouldEnd != true || !context.mounted) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to end a session.')),
      );
      return;
    }

    final requestProvider = context.read<RequestProvider>();
    await requestProvider.endRequest(request.id, currentUser.uid);

    if (!context.mounted) return;

    if (requestProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(requestProvider.errorMessage!)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session marked as completed')),
    );

    // Open rate/review screen so the user can leave a review immediately
    final isFrom = currentUser.uid == request.fromUserId;
    final otherUserId = isFrom ? request.toUserId : request.fromUserId;
    final otherUserName = isFrom ? request.toUserName : request.fromUserName;
    final sessionDate = request.proposedTimes.isNotEmpty
        ? request.proposedTimes.first
        : request.createdAt.toLocal().toString().split(' ').first;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RateReviewScreen(
          requestId: request.id,
          skillTitle: request.skillName,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          sessionDate: sessionDate,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.watch<AuthProvider>();
    final currentUid = authProvider.currentUser?.uid;

    if (currentUid == null ||
        authProvider.isLoading ||
        currentUid == _loadedForUid) {
      return;
    }

    _loadedForUid = currentUid;
    context.read<RequestProvider>().loadRequests(currentUid);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [NotificationIconButton()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentLight,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.label,
          tabs: [const Tab(text: 'Received'), const Tab(text: 'Sent')],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Consumer2<RequestProvider, AuthProvider>(
          builder: (context, requestProvider, authProvider, _) {
            return TabBarView(
              controller: _tabController,
              children: [
                // ═════════════════════════════════════════════════════════════
                // RECEIVED TAB - Requests from other users
                // ═════════════════════════════════════════════════════════════
                _buildReceivedRequestsList(requestProvider.incoming, context),

                // ═════════════════════════════════════════════════════════════
                // SENT TAB - Requests you sent to other users
                // ═════════════════════════════════════════════════════════════
                _buildSentRequestsList(requestProvider.outgoing, context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceivedRequestsList(
    List<RequestModel> requests,
    BuildContext context,
  ) {
    final visibleRequests =
        requests.where((request) => !request.isDeclined).toList();

    if (visibleRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppColors.accentLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No requests received yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visibleRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(
          visibleRequests[index],
          isReceived: true,
          context: context,
        );
      },
    );
  }

  Widget _buildSentRequestsList(
    List<RequestModel> requests,
    BuildContext context,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: 48,
              color: AppColors.accentLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No requests sent yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(
          requests[index],
          isReceived: false,
          context: context,
        );
      },
    );
  }

  Widget _buildRequestCard(
    RequestModel request, {
    required bool isReceived,
    required BuildContext context,
  }) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppColors.glassCard(borderRadius: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceived ? request.fromUserName : request.skillName,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isReceived
                            ? 'wants to learn ${request.skillName}'
                            : 'from ${request.toUserId}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Proposed times
            if (request.proposedTimes.isNotEmpty) ...[
              Text(
                'Proposed Times:',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5F3FF), Color(0xFFEAF2FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        request.proposedTimes.take(2).map((time) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    time,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              if (request.proposedTimes.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${request.proposedTimes.length - 2} more',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 10),

            // Message preview
            if (request.message.isNotEmpty) ...[
              Text(
                request.message,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
            ],

            // Actions based on whether it's received or sent
            if (isReceived) ...[
              if (request.isPending)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed:
                              () => _handleDeclineRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed:
                              () => _handleAcceptRequest(context, request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Accept',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (request.isAccepted)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _openChatForRequest(
                            context,
                            request,
                            otherUserId: request.fromUserId,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Open Chat',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () => _handleEndRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Mark ended',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed:
                        () => _openChatForRequest(
                          context,
                          request,
                          otherUserId: request.fromUserId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Open Chat',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ] else ...[
              if (request.isAccepted)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _showRequestDetails(context, request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'View Details',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () => _handleEndRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Mark ended',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _showRequestDetails(context, request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeclineRequest(
    BuildContext context,
    RequestModel request,
  ) async {
    final shouldDecline = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Decline Request'),
            content: Text(
              'Decline the request from ${request.fromUserName} for ${request.skillName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'Decline',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (shouldDecline != true || !context.mounted) return;

    final requestProvider = context.read<RequestProvider>();
    await requestProvider.declineRequest(
      request.id,
      request.fromUserId,
      request.skillName,
    );

    if (!context.mounted) return;

    if (requestProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(requestProvider.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request declined')));
  }

  Future<void> _handleAcceptRequest(
    BuildContext context,
    RequestModel request,
  ) async {
    if (request.proposedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No proposed time is available to accept.'),
        ),
      );
      return;
    }

    String selectedTime = request.proposedTimes.first;

    final confirmedTime = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Accept Request'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose the time slot to confirm for ${request.fromUserName}.',
                      ),
                      const SizedBox(height: 12),
                      ...request.proposedTimes.map((time) {
                        return RadioListTile<String>(
                          value: time,
                          groupValue: selectedTime,
                          contentPadding: EdgeInsets.zero,
                          title: Text(time),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedTime = value);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, selectedTime),
                    child: const Text('Accept'),
                  ),
                ],
              );
            },
          ),
    );

    if (confirmedTime == null || !context.mounted) return;

    final confirmedSlot = _buildConfirmedSlot(confirmedTime);
    final requestProvider = context.read<RequestProvider>();

    await requestProvider.acceptRequest(
      request.id,
      confirmedSlot,
      request.fromUserName,
      request.skillName,
      request.fromUserId,
    );

    if (!context.mounted) return;

    if (requestProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(requestProvider.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request accepted')));
  }

  void _showRequestDetails(BuildContext context, RequestModel request) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(request.skillName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: ${request.fromUserName}'),
                const SizedBox(height: 8),
                Text('Status: ${request.status}'),
                if (request.message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Message: ${request.message}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _openChatForRequest(
    BuildContext context,
    RequestModel request, {
    required String otherUserId,
  }) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to open chat.')),
      );
      return;
    }

    try {
      final conversationId = await ChatService().getOrCreateConversation(
        currentUser.uid,
        otherUserId,
      );

      if (!context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatThreadScreen(
                conversationId: conversationId,
                otherUserId: otherUserId,
              ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
    }
  }

  Map<String, String> _buildConfirmedSlot(String proposedTime) {
    final match = RegExp(
      r'^(\d{1,2}/\d{1,2}/\d{4})\s+(\d{1,2}:\d{2}\s+[AP]M)\s+-\s+(\d{1,2}:\d{2}\s+[AP]M)$',
    ).firstMatch(proposedTime);

    if (match != null) {
      final datePart = match.group(1)!;
      final startDateTime = _parseDateTime(datePart, match.group(2)!);
      final endDateTime = _parseDateTime(datePart, match.group(3)!);

      return {
        'startTime': startDateTime.toIso8601String(),
        'endTime': endDateTime.toIso8601String(),
      };
    }

    final fallbackStart = DateTime.now();
    final fallbackEnd = fallbackStart.add(const Duration(hours: 1));

    return {
      'startTime': fallbackStart.toIso8601String(),
      'endTime': fallbackEnd.toIso8601String(),
    };
  }

  DateTime _parseDateTime(String datePart, String timePart) {
    final dateSegments = datePart.split('/');
    final timeMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AP]M)$',
    ).firstMatch(timePart.trim());

    if (dateSegments.length != 3 || timeMatch == null) {
      return DateTime.now();
    }

    final month = int.tryParse(dateSegments[0]) ?? DateTime.now().month;
    final day = int.tryParse(dateSegments[1]) ?? DateTime.now().day;
    final year = int.tryParse(dateSegments[2]) ?? DateTime.now().year;
    var hour = int.tryParse(timeMatch.group(1)!) ?? 0;
    final minute = int.tryParse(timeMatch.group(2)!) ?? 0;
    final period = timeMatch.group(3)!;

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF10B981);
      case 'declined':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'declined':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
