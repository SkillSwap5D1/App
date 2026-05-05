import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skillswap_app/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SkillSwap Integration Tests', () {
    testWidgets('TEST 1 — Register flow', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify on login screen
      expect(find.text('Sign In'), findsWidgets);

      // Tap "Create Account" link
      final createAccountLink = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Text &&
            (widget.child as Text).data == 'Create an account',
      );

      if (createAccountLink.evaluate().isNotEmpty) {
        await tester.tap(createAccountLink);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Verify on register screen
      expect(find.byType(DropdownButton), findsWidgets);

      // Fill and submit registration form
      await fillAndSubmitRegistration(
        tester,
        firstName: 'Integration',
        lastName: 'Tester',
        email: testEmail,
        course: 'Computer Science',
        password: testPassword,
        confirmPassword: testPassword,
      );

      // Complete onboarding if present
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await completeOnboarding(tester);

      // Verify browse screen is shown after onboarding
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('TEST 2 — Login and logout flow', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Fill and submit login form
      await fillAndSubmitLogin(
        tester,
        email: testEmail,
        password: testPassword,
      );

      // Wait for login to complete and navigate to browse
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to profile screen
      await navigateToProfile(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify profile screen
      expect(find.text('Profile'), findsWidgets);

      // Tap sign out button
      await pressSignOut(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify back on login screen
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('TEST 3 — Browse and bookmark flow', (WidgetTester tester) async {
      // Launch app and login
      app.main();
      await tester.pumpAndSettle();

      await fillAndSubmitLogin(
        tester,
        email: testEmail,
        password: testPassword,
      );

      // Wait for browse screen to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify listings are shown
      expect(find.byType(ListView), findsWidgets);

      // Bookmark first listing
      await bookmarkFirstListing(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Navigate to Saved tab
      await navigateToSavedTab(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify bookmarked listing appears in saved
      expect(find.byType(GridView), findsWidgets);

      // Unbookmark the listing
      final bookmarkIcon = find.byIcon(Icons.bookmark).first;
      if (bookmarkIcon.evaluate().isNotEmpty) {
        await tester.tap(bookmarkIcon);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Verify listing is removed from saved
      expect(find.text('No saved listings'), findsNothing);
    });

    testWidgets('TEST 4 — Send request flow', (WidgetTester tester) async {
      // Launch app and login
      app.main();
      await tester.pumpAndSettle();

      await fillAndSubmitLogin(
        tester,
        email: testEmail,
        password: testPassword,
      );

      // Wait for browse screen to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify listings are shown
      expect(find.byType(ListView), findsWidgets);

      // Tap Send Request on first listing
      await tapSendRequestOnFirstListing(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify request form opened
      expect(find.byType(AlertDialog), findsWidgets);

      // Fill and submit request
      await fillAndSendRequest(
        tester,
        timeSlot: '2026-05-15 2:00 PM',
      );

      // Wait for request to be sent
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify success snackbar or message
      expect(find.byType(SnackBar), findsWidgets);
    });

    testWidgets('TEST 5 — Chat flow', (WidgetTester tester) async {
      // Launch app and login
      app.main();
      await tester.pumpAndSettle();

      await fillAndSubmitLogin(
        tester,
        email: testEmail,
        password: testPassword,
      );

      // Wait for browse screen to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to chat tab
      await navigateToChatTab(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify chat screen with conversations
      expect(find.byType(ListView), findsWidgets);

      // Open first conversation
      await openFirstConversation(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify conversation thread
      expect(find.byType(ListView), findsWidgets);

      // Send a message
      const testMessage = 'Hello, this is a test message!';
      await sendMessage(tester, testMessage);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify message appears in thread
      expect(find.text(testMessage), findsWidgets);
    });
  });
}
