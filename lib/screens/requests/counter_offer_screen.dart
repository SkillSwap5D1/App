import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/time_slot.dart';
import '../../theme/app_theme.dart';

class CounterOfferScreen extends StatefulWidget {
  final MockRequest originalRequest;

  const CounterOfferScreen({
    super.key,
    required this.originalRequest,
  });

  @override
  State<CounterOfferScreen> createState() => _CounterOfferScreenState();
}

class _CounterOfferScreenState extends State<CounterOfferScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────────
  List<TimeSlot> _selectedTimeSlots = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Counter Offer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original request details will go here
              // Time slot picker will go here
              // Message field will go here
              // Submit button will go here
            ],
          ),
        ),
      ),
    );
  }
}
