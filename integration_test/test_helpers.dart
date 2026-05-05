import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for integration testing
/// These functions provide common setup and interaction patterns
/// used across multiple integration tests

// ── Test User Credentials ──────────────────────────────────────────────

const testEmail = 'testuser@myport.ac.uk';
const testPassword = 'TestPassword123!';
const testUserName = 'Test User';

const testEmail2 = 'testuser2@myport.ac.uk';
const testPassword2 = 'TestPassword456!';
const testUserName2 = 'Second User';

// ── Common Test Settings ──────────────────────────────────────────────

const verificationTimeout = Duration(seconds: 5);
const animationDelay = Duration(milliseconds: 500);

// ── Authentication Helpers ──────────────────────────────────────────

/// Fill and submit the registration form with provided credentials
Future<void> fillAndSubmitRegistration(
  WidgetTester tester, {
  required String firstName,
  required String lastName,
  required String email,
  required String course,
  required String password,
  required String confirmPassword,
}) async {
  // Fill first name
  await tester.enterText(find.byType(TextFormField).at(0), firstName);
  await tester.pumpAndSettle(animationDelay);

  // Fill last name
  await tester.enterText(find.byType(TextFormField).at(1), lastName);
  await tester.pumpAndSettle(animationDelay);

  // Fill email
  await tester.enterText(find.byType(TextFormField).at(2), email);
  await tester.pumpAndSettle(animationDelay);

  // Select course (tap dropdown - index 3)
  await tester.tap(find.byType(DropdownButton).first);
  await tester.pumpAndSettle(animationDelay);

  // Select first course option
  await tester.tap(find.byType(DropdownMenuItem).first);
  await tester.pumpAndSettle(animationDelay);

  // Fill password
  final passwordFields = find.byType(TextFormField);
  await tester.enterText(passwordFields.at(3), password);
  await tester.pumpAndSettle(animationDelay);

  // Fill confirm password
  await tester.enterText(passwordFields.at(4), confirmPassword);
  await tester.pumpAndSettle(animationDelay);

  // Scroll to submit button and tap
  await tester.ensureVisible(find.byType(ElevatedButton).first);
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle(animationDelay);
}

/// Fill and submit the login form
Future<void> fillAndSubmitLogin(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  // Fill email
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.pumpAndSettle(animationDelay);

  // Fill password
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.pumpAndSettle(animationDelay);

  // Tap sign in button
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle(animationDelay);
}

// ── Navigation Helpers ──────────────────────────────────────────────

/// Navigate to a tab by its name in bottom navigation
Future<void> tapBottomNavTab(WidgetTester tester, String tabName) async {
  final tabFinder = find.byWidgetPredicate(
    (widget) =>
        widget is BottomNavigationBarItem ||
        (widget is Tooltip && widget.message.contains(tabName)),
  );

  if (tabFinder.evaluate().isNotEmpty) {
    await tester.tap(tabFinder.first);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Navigate to profile screen
Future<void> navigateToProfile(WidgetTester tester) async {
  // Tap profile icon in bottom nav
  final profileTab = find.byIcon(Icons.person);
  if (profileTab.evaluate().isNotEmpty) {
    await tester.tap(profileTab);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Tap sign out button
Future<void> pressSignOut(WidgetTester tester) async {
  final signOutButton = find.byWidgetPredicate(
    (widget) =>
        widget is TextButton && widget.child is Text && 
        (widget.child as Text).data == 'Sign Out',
  );

  if (signOutButton.evaluate().isNotEmpty) {
    await tester.tap(signOutButton);
    await tester.pumpAndSettle(animationDelay);
  }
}

// ── Browse Screen Helpers ──────────────────────────────────────────

/// Tap bookmark icon on first listing
Future<void> bookmarkFirstListing(WidgetTester tester) async {
  final bookmarkIcon = find.byIcon(Icons.bookmark_outline).first;
  if (bookmarkIcon.evaluate().isNotEmpty) {
    await tester.ensureVisible(bookmarkIcon);
    await tester.tap(bookmarkIcon);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Navigate to Saved tab
Future<void> navigateToSavedTab(WidgetTester tester) async {
  final savedTab = find.byWidgetPredicate(
    (widget) =>
        widget is BottomNavigationBarItem ||
        (widget is Text && widget.data == 'Saved'),
  );

  if (savedTab.evaluate().isNotEmpty) {
    await tester.tap(savedTab.first);
    await tester.pumpAndSettle(animationDelay);
  }
}

// ── Request Helpers ──────────────────────────────────────────────

/// Tap "Send Request" on first listing
Future<void> tapSendRequestOnFirstListing(WidgetTester tester) async {
  final sendRequestButton = find.byWidgetPredicate(
    (widget) =>
        widget is ElevatedButton ||
        (widget is Text && widget.data == 'Send Request'),
  ).first;

  if (sendRequestButton.evaluate().isNotEmpty) {
    await tester.ensureVisible(sendRequestButton);
    await tester.tap(sendRequestButton);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Fill request form with time slot and submit
Future<void> fillAndSendRequest(
  WidgetTester tester, {
  required String timeSlot,
}) async {
  // Select time slot from picker/dropdow
  final timeInput = find.byType(TextFormField).first;
  await tester.tap(timeInput);
  await tester.pumpAndSettle(animationDelay);

  // Enter time
  await tester.enterText(timeInput, timeSlot);
  await tester.pumpAndSettle(animationDelay);

  // Submit form
  final submitButton = find.byType(ElevatedButton).first;
  if (submitButton.evaluate().isNotEmpty) {
    await tester.tap(submitButton);
    await tester.pumpAndSettle(animationDelay);
  }
}

// ── Chat Helpers ───────────────────────────────────────────────

/// Navigate to chat tab
Future<void> navigateToChatTab(WidgetTester tester) async {
  final chatTab = find.byIcon(Icons.chat);
  if (chatTab.evaluate().isNotEmpty) {
    await tester.tap(chatTab);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Open first conversation
Future<void> openFirstConversation(WidgetTester tester) async {
  final firstConversation = find.byType(ListTile).first;
  if (firstConversation.evaluate().isNotEmpty) {
    await tester.tap(firstConversation);
    await tester.pumpAndSettle(animationDelay);
  }
}

/// Send a message in chat
Future<void> sendMessage(WidgetTester tester, String message) async {
  // Find message input field
  final messageInput = find.byType(TextField).first;
  if (messageInput.evaluate().isNotEmpty) {
    await tester.tap(messageInput);
    await tester.enterText(messageInput, message);
    await tester.pumpAndSettle(animationDelay);

    // Tap send button
    final sendButton = find.byIcon(Icons.send);
    if (sendButton.evaluate().isNotEmpty) {
      await tester.tap(sendButton);
      await tester.pumpAndSettle(animationDelay);
    }
  }
}

// ── Verification Helpers ───────────────────────────────────────────

/// Wait for text to appear on screen
Future<void> waitForText(WidgetTester tester, String text) async {
  await tester.pumpUntilFound(
    find.text(text),
    verificationTimeout,
  );
}

/// Verify snackbar message appears
Future<void> verifySnackbarMessage(WidgetTester tester, String message) async {
  expect(find.byType(SnackBar), findsWidgets);
  expect(find.text(message), findsWidgets);
}

/// Verify we're on a specific screen by looking for key widgets
Future<void> verifyScreenContent(WidgetTester tester, String screenName) async {
  switch (screenName) {
    case 'browse':
      expect(find.text('Browse'), findsWidgets);
      break;
    case 'requests':
      expect(find.text('Requests'), findsWidgets);
      break;
    case 'chat':
      expect(find.byType(ListView), findsWidgets);
      break;
    case 'profile':
      expect(find.text('Profile'), findsWidgets);
      break;
    case 'login':
      expect(find.byType(TextFormField), findsWidgets);
      break;
    case 'register':
      expect(find.byType(DropdownButton), findsWidgets);
      break;
  }
}

// ── Onboarding Helpers ──────────────────────────────────────────

/// Skip or complete onboarding screens
Future<void> completeOnboarding(WidgetTester tester) async {
  // Look for onboarding screens and skip/next through them
  while (find.byIcon(Icons.navigate_next).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.navigate_next).first);
    await tester.pumpAndSettle(animationDelay);
  }

  // Tap final "Get Started" or similar button
  final getStartedButton = find.byWidgetPredicate(
    (widget) =>
        widget is ElevatedButton ||
        (widget is Text && widget.data == 'Get Started'),
  );

  if (getStartedButton.evaluate().isNotEmpty) {
    await tester.tap(getStartedButton.first);
    await tester.pumpAndSettle(animationDelay);
  }
}
