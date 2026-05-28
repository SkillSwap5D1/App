import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../chat/chat_thread_screen.dart';
import '../reviews/rate_review_screen.dart';
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
      builder:
          (dialogContext) => AlertDialog(
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
        const SnackBar(
          content: Text('You must be signed in to end a session.'),
        ),
      );
      return;
    }

    final requestProvider = context.read<RequestProvider>();
    await requestProvider.endRequest(request.id, currentUser.uid);

    if (!context.mounted) return;

    if (requestProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(requestProvider.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session marked as completed')),
    );

    // Open rate/review screen so the user can leave a review immediately
    final isFrom = currentUser.uid == request.fromUserId;
    final otherUserId = isFrom ? request.toUserId : request.fromUserId;
    final otherUserName = isFrom ? request.toUserName : request.fromUserName;
    final sessionDate =
        request.proposedTimes.isNotEmpty
            ? request.proposedTimes.first
            : request.createdAt.toLocal().toString().split(' ').first;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => RateReviewScreen(
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requests',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your skill exchange requests',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    _buildTab('Received', _tabController.index == 0),
                    _buildTab('Sent', _tabController.index == 1),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<RequestProvider>(
                  builder: (context, requestProvider, _) {
                    if (requestProvider.isLoading &&
                        requestProvider.incoming.isEmpty &&
                        requestProvider.outgoing.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (requestProvider.errorMessage != null &&
                        requestProvider.incoming.isEmpty &&
                        requestProvider.outgoing.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            requestProvider.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReceivedRequestsList(
                          requestProvider.incoming,
                          context,
                        ),
                        _buildSentRequestsList(
                          requestProvider.outgoing,
                          context,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return GestureDetector(
      onTap:
          () => setState(
            () => _tabController.animateTo(label == 'Received' ? 0 : 1),
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF064E3B) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF064E3B) : const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedRequestsList(
    List<RequestModel> requests,
    BuildContext context,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentVeryLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No requests received yet',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Incoming requests will show here when someone wants to swap skills with you.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(
          requests[index],
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
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentVeryLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No requests sent yet',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Requests you send to other users will appear here with their status.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceived ? request.fromUserName : request.skillName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isReceived
                            ? 'wants to learn ${request.skillName}'
                            : 'from ${request.toUserName}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
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
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (request.proposedTimes.isNotEmpty) ...[
              const Text(
                'Proposed Times:',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...request.proposedTimes.take(2).map((time) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF064E3B).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF064E3B),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          time,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
            if (isReceived) ...[
              if (request.isPending)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed:
                              () => _handleDeclineRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                              () => _handleAcceptRequest(context, request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF064E3B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                              () => _openChatForRequest(
                                context,
                                request,
                                otherUserId: request.fromUserId,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF064E3B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Open Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _handleEndRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Mark ended',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
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
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                        () => _openChatForRequest(
                          context,
                          request,
                          otherUserId: request.fromUserId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Open Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                              () => _openChatForRequest(
                                context,
                                request,
                                otherUserId: request.toUserId,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF064E3B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Open Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _handleEndRequest(context, request),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Mark ended',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
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
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                        () => _openChatForRequest(
                          context,
                          request,
                          otherUserId: request.toUserId,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Open Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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

  // _showRequestDetails removed (unused) to reduce dead code.

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
