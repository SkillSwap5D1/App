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

class _ChatListScreenState extends State<ChatListScreen>
    with WidgetsBindingObserver {
  final UserService _userService = UserService();
  late VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // On first frame try to load conversations if user is already signed in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUid = authProvider.currentUser?.uid;
      if (currentUid != null) {
        print('🔵 ChatListScreen loading conversations for $currentUid');
        context.read<ChatProvider>().loadConversations(currentUid);
      }

      // Also listen for future auth state changes so conversations are loaded
      // automatically when the user signs in after this screen is mounted.
      _authListener = () {
        final uid = authProvider.currentUser?.uid;
        if (uid != null) {
          print(
            '🔵 ChatListScreen detected sign-in for $uid, loading conversations',
          );
          context.read<ChatProvider>().loadConversations(uid);
        }
      };
      authProvider.addListener(_authListener);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authProvider = context.read<AuthProvider>();
      final currentUid = authProvider.currentUser?.uid;
      if (currentUid != null) {
        print(
          '🔵 ChatListScreen resumed, refreshing conversations for $currentUid',
        );
        context.read<ChatProvider>().loadConversations(currentUid);
      }
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final conversations = chatProvider.conversations;

          print(
            '🔵 ChatListScreen rebuilding with ${conversations.length} conversations',
          );

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation by sending a message',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final otherUserId = conv.getOtherUserId(currentUid);

              return FutureBuilder(
                future: _userService.getUser(otherUserId),
                builder: (context, snapshot) {
                  final otherUser = snapshot.data;
                  final otherUserName = otherUser?.displayName ?? 'Unknown';
                  final otherUserInitial =
                      otherUserName.isNotEmpty
                          ? otherUserName[0].toUpperCase()
                          : '?';

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('🔵 Tapping conversation: ${conv.id}');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatThreadScreen(
                                    conversationId: conv.id,
                                    otherUserId: otherUserId,
                                  ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.card,
                                ),
                                child: Center(
                                  child: Text(
                                    otherUserInitial,
                                    style: AppTextStyles.h3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            otherUserName,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(conv.lastMessageTime),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conv.lastMessage,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (conv.getUnreadCount(currentUid) > 0)
                                          const SizedBox(width: 8),
                                        if (conv.getUnreadCount(currentUid) > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${conv.getUnreadCount(currentUid)}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove auth listener if it was added.
    try {
      final authProvider = context.read<AuthProvider>();
      authProvider.removeListener(_authListener);
    } catch (_) {}
    super.dispose();
  }
}
