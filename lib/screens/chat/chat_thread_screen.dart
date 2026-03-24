import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/message_bubble.dart';
import '../safety/report_blocked_screen.dart';

class ChatThreadScreen extends StatefulWidget {
  final MockConversation conversation;

  const ChatThreadScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  bool _isComposing = false;
  bool _isUserBlocked = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    
    // Listen for text changes to enable/disable send button
    _messageController.addListener(_handleTextChanged);
    
    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _showReportSheet() {
    final reportBlocked = ReportBlockedScreen(
      userName: widget.conversation.otherUserName,
      userId: widget.conversation.otherUserId,
      onBlock: () {
        setState(() => _isUserBlocked = true);
      },
    );
    reportBlocked._showReportForm();
  }

  void _showBlockDialog() {
    final reportBlocked = ReportBlockedScreen(
      userName: widget.conversation.otherUserName,
      userId: widget.conversation.otherUserId,
      onBlock: () {
        setState(() => _isUserBlocked = true);
      },
    );
    reportBlocked._showBlockConfirmation();
  }

  // Get category emoji
  static String _getEmojiForCategory(String category) {
    switch (category) {
      case 'Programming':
        return '💻';
      case 'Languages':
        return '🗣️';
      case 'Design':
        return '🎨';
      case 'Music':
        return '🎵';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  _getEmojiForCategory(widget.conversation.category),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Name and Online Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.otherUserName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.conversation.isOnline
                              ? AppColors.success
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.conversation.isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.caption,
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
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {
              // Open menu for Report/Block
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.sm),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag, color: AppColors.error),
                        title: const Text('Report User'),
                        onTap: () {
                          Navigator.pop(context);
                          _showReportSheet();
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.block, color: AppColors.error),
                        title: const Text('Block User'),
                        onTap: () {
                          Navigator.pop(context);
                          _showBlockDialog();
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
          // ── MESSAGES LIST ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: widget.conversation.messages.length,
              addAutomaticKeepAlives: true,
              itemBuilder: (context, index) {
                final message = widget.conversation.messages[index];
                return MessageBubble(
                  message: message,
                  showDeliveryStatus: true,
                );
              },
            ),
          ),

          // ── MESSAGE INPUT ──────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _isComposing ? (_) {
                      _messageController.clear();
                      _scrollToBottom();
                    } : null,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isComposing
                        ? () {
                            // Clear and scroll to bottom
                            _messageController.clear();
                            _scrollToBottom();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      elevation: _isComposing ? 2 : 0,
                    ),
                    child: Icon(
                      Icons.send,
                      color: _isComposing
                          ? AppColors.surface
                          : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
