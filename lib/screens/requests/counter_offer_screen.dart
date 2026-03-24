import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Counter Offer'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Counter Offer Screen'),
      ),
    );
  }
}
