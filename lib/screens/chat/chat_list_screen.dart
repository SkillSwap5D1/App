import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/notification_icon_button.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
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
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.surface,
        actions: const [NotificationIconButton()],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final conversations = chatProvider.conversations;
          
          if (conversations.isEmpty) {
            return const Center(
              child: Text('No messages yet'),
            );
          }
          
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return ListTile(
                title: Text(conv.participants.isNotEmpty ? conv.participants.first : 'User'),
                subtitle: Text(conv.lastMessage),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
