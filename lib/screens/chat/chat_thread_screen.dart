import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../safety/report_blocked_screen.dart';

class ChatThreadScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;

  const ChatThreadScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  bool _isComposing = false;
  bool _isUserBlocked = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Listen for text changes to enable/disable send button
    _messageController.addListener(_handleTextChanged);

    // Load messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().openConversation(widget.conversationId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {
      _isComposing = _messageController.text.trim().isNotEmpty;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (!_isComposing) return;

    final text = _messageController.text.trim();
    final authProvider = context.read<AuthProvider>();
    final currentUid = authProvider.currentUser?.uid;
    final senderName = authProvider.currentUser?.fullName ?? 'Unknown';

    if (currentUid == null) return;

    _messageController.clear();
    setState(() => _isComposing = false);

    await context.read<ChatProvider>().sendMessage(
      conversationId: widget.conversationId,
      senderId: currentUid,
      senderName: senderName,
      text: text,
    );

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _showReportSheet(String otherUserName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ReportBlockedScreen(
              userName: otherUserName,
              userId: widget.otherUserId,
              onBlock: () {
                setState(() => _isUserBlocked = true);
              },
            ),
      ),
    );
  }

  void _showBlockDialog(String otherUserName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ReportBlockedScreen(
              userName: otherUserName,
              userId: widget.otherUserId,
              onBlock: () {
                setState(() => _isUserBlocked = true);
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userService.getUser(widget.otherUserId),
      builder: (context, snapshot) {
        final otherUser = snapshot.data;
        final otherUserName = otherUser?.displayName ?? 'Unknown';
        final otherUserInitial =
            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?';

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: Center(
                    child: Text(
                      otherUserInitial,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 24),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.flag,
                                  color: AppColors.error,
                                ),
                                title: const Text('Report User'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showReportSheet(otherUserName);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.block,
                                  color: AppColors.error,
                                ),
                                title: const Text('Block User'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showBlockDialog(otherUserName);
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── BLOCKED NOTIFICATION
              if (_isUserBlocked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'You have blocked $otherUserName. Messages are hidden.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── MESSAGES LIST
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    final messages = chatProvider.currentMessages;
                    final currentUid =
                        context.read<AuthProvider>().currentUser?.uid ?? '';

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.mail_outline_rounded,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation with $otherUserName',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isCurrentUser = message.senderId == currentUid;

                        return Align(
                          alignment:
                              isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  isCurrentUser
                                      ? AppColors.accentGradient
                                      : null,
                              color:
                                  isCurrentUser
                                      ? null
                                      : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(
                                  isCurrentUser ? 16 : 4,
                                ),
                                bottomRight: Radius.circular(
                                  isCurrentUser ? 4 : 16,
                                ),
                              ),
                              border: Border.all(
                                color:
                                    isCurrentUser
                                        ? Colors.transparent
                                        : AppColors.border,
                              ),
                              boxShadow: isCurrentUser ? AppShadows.card : null,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isCurrentUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color:
                                        isCurrentUser
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: AppTextStyles.caption.copyWith(
                                    color:
                                        isCurrentUser
                                            ? AppColors.textSecondary
                                            : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ── MESSAGE INPUT ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    // Text field
                    Expanded(
                      child: TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                        ),
                        style: AppTextStyles.bodyMedium,
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient:
                            _isComposing ? AppColors.accentGradient : null,
                        color: _isComposing ? null : AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        boxShadow: _isComposing ? AppShadows.card : null,
                        border: Border.all(
                          color:
                              _isComposing
                                  ? Colors.transparent
                                  : AppColors.border,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, size: 18),
                        color:
                            _isComposing ? Colors.white : AppColors.textMuted,
                        onPressed: _isComposing ? _sendMessage : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
