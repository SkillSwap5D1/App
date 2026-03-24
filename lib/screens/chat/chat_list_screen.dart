import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import 'chat_thread_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  String? _selectedConversationId;

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final conversations = MockData.conversations;
    final conversationCount = conversations.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$conversationCount conversation${conversationCount != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // ── CONVERSATION LIST ──────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final isSelected = _selectedConversationId == conversation.id;

                  return _ConversationRow(
                    conversation: conversation,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedConversationId = conversation.id;
                      });

                      // Navigate to chat thread
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatThreadScreen(
                            conversation: conversation,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CONVERSATION ROW WIDGET ────────────────────────────────────────────────
class _ConversationRow extends StatelessWidget {
  final MockConversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationRow({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── AVATAR ──────────────────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getEmojiForCategory(conversation.category),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── MESSAGE CONTENT ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name in bold
                    Text(
                      conversation.otherUserName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Last message preview in grey, 1 line truncated
                    Text(
                      conversation.lastMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── UNREAD BADGE ────────────────────────────────────────────
              if (conversation.unreadCount > 0)
                _UnreadBadge(count: conversation.unreadCount),
            ],
          ),
        ),
      ),
    );
  }
}

// ── UNREAD BADGE WIDGET ────────────────────────────────────────────────────
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
