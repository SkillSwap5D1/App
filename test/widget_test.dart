// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skillswap_app/theme/app_theme.dart';

void main() {
  testWidgets('SkillSwap theme loads correctly', (WidgetTester tester) async {
    // Build a simple app with SkillSwap theme
    await tester.pumpWidget(
      MaterialApp(
        title: 'SkillSwap Test',
        theme: AppTheme.theme,
        home: Scaffold(
          appBar: AppBar(title: const Text('SkillSwap')),
          body: const Center(child: Text('SkillSwap App')),
        ),
      ),
    );

    // Verify that the theme is applied
    expect(find.text('SkillSwap'), findsWidgets);
    expect(find.text('SkillSwap App'), findsOneWidget);
  });
}
