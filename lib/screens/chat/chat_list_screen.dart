import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import 'chat_thread_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUid = authProvider.currentUser?.uid;
      if (currentUid != null) {
        context.read<ChatProvider>().loadConversations(currentUid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<ChatProvider, AuthProvider>(
          builder: (context, chatProvider, authProvider, _) {
            final conversations = chatProvider.conversations;
            final currentUid = authProvider.currentUser?.uid ?? '';
            final conversationCount = conversations.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────────────────
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

                // ── CONVERSATION LIST ──────────────────────────────────────
                Expanded(
                  child: conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mail_outline_rounded,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text(
                                'No conversations yet',
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            final otherUserId = conversation.participants
                                .firstWhere(
                                    (uid) => uid != currentUid,
                                    orElse: () => '');

                            return _ConversationRow(
                              conversation: conversation,
                              otherUserId: otherUserId,
                              currentUid: currentUid,
                              userService: _userService,
                              onTap: () {
                                if (otherUserId.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatThreadScreen(
                                        conversationId: conversation.id,
                                        otherUserId: otherUserId,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── CONVERSATION ROW WIDGET ────────────────────────────────────────────────
class _ConversationRow extends StatelessWidget {
  final dynamic conversation;
  final String otherUserId;
  final String currentUid;
  final UserService userService;
  final VoidCallback onTap;

  const _ConversationRow({
    required this.conversation,
    required this.otherUserId,
    required this.currentUid,
    required this.userService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userService.getUser(otherUserId),
      builder: (context, snapshot) {
        final otherUserName =
            snapshot.data?.displayName ?? 'Unknown';
        final initials = otherUserName.isNotEmpty
            ? otherUserName[0].toUpperCase()
            : '?';

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initials,
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.surface),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.lastMessage,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Timestamp
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(conversation.lastMessageTime),
                      style: AppTextStyles.caption,
                    ),
                    if (conversation.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${conversation.unreadCount}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.surface),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }
}
