import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
            // Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.otherUserName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.conversation.isOnline ? 'Online' : 'Offline',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── MESSAGES LIST ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: widget.conversation.messages.length,
              itemBuilder: (context, index) {
                final message = widget.conversation.messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // ── MESSAGE INPUT ──────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Send message
                      _messageController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Icon(Icons.send),
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

// ── MESSAGE BUBBLE WIDGET ──────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MockMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: message.isMe ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: message.isMe ? AppColors.primary : AppColors.border,
            ),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: message.isMe
                      ? AppColors.surface
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message.timestamp,
                style: AppTextStyles.caption.copyWith(
                  color: message.isMe
                      ? AppColors.primaryLight.withOpacity(0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
