import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/notification_icon_button.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
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
      appBar: AppBar(
        title: const Text('Requests'),
        backgroundColor: AppColors.surface,
        actions: const [NotificationIconButton()],
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, _) {
          final requests = requestProvider.incoming;
          
          if (requests.isEmpty) {
            return const Center(
              child: Text('No incoming requests'),
            );
          }
          
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Request from User'),
                subtitle: const Text('Status: Pending'),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
