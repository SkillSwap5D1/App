import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/browse/browse_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const BrowseScreen(),
    );
  }
}
