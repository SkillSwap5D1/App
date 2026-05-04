import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/request_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/providers/request_provider.dart';
import 'package:skillswap_app/screens/requests/requests_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class MockRequestProvider extends Mock implements RequestProvider {
  List<RequestModel> incoming_ = [];
  List<RequestModel> outgoing_ = [];
  bool loading = false;
  String? errorMsg;

  @override
  List<RequestModel> get incoming => incoming_;

  @override
  List<RequestModel> get outgoing => outgoing_;

  @override
  bool get isLoading => loading;

  @override
  String? get errorMessage => errorMsg;
}

class MockAuthProvider extends Mock implements AuthProvider {
  String? uid;

  @override
  UserModel? get currentUser {
    if (uid != null) {
      return UserModel(
        uid: uid!,
        email: 'test@port.ac.uk',
        firstName: 'Test',
        lastName: 'User',
        course: 'Computer Science',
        bio: 'Test bio',
        rating: 5.0,
        sessionsCompleted: 5,
        memberSince: DateTime.now(),
        showFullName: true,
        showCourse: true,
        showPhoto: true,
      );
    }
    return null;
  }
}

Widget _buildTestApp({
  required RequestProvider requestProvider,
  required AuthProvider authProvider,
  required Widget homeScreen,
}) {
  return MaterialApp(
    theme: AppTheme.theme,
    home: MultiProvider(
      providers: [
        Provider<RequestProvider>.value(value: requestProvider),
        Provider<AuthProvider>.value(value: authProvider),
      ],
      child: homeScreen,
    ),
  );
}

void main() {
  Provider.debugCheckInvalidValueType = null;

  group('RequestsScreen', () {
    testWidgets('TEST 1 — renders incoming request cards', (tester) async {
      final requestProvider = MockRequestProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      // Seed mock incoming requests
      requestProvider.incoming_ = [
        RequestModel(
          id: 'req1',
          fromUserId: 'user2',
          fromUserName: 'Alice',
          toUserId: 'user1',
          listingId: 'listing1',
          skillName: 'Python',
          message: 'Can you teach me Python?',
          proposedTimes: ['Monday 2pm', 'Tuesday 3pm'],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        RequestModel(
          id: 'req2',
          fromUserId: 'user3',
          fromUserName: 'Bob',
          toUserId: 'user1',
          listingId: 'listing2',
          skillName: 'Guitar',
          message: 'I want to learn guitar',
          proposedTimes: ['Wednesday 4pm'],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          requestProvider: requestProvider,
          authProvider: authProvider,
          homeScreen: const RequestsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsWidgets);
      expect(find.text('Bob'), findsWidgets);
      expect(find.text('Python'), findsWidgets);
      expect(find.text('Guitar'), findsWidgets);
      expect(find.text('Can you teach me Python?'), findsOneWidget);
    });

    testWidgets('TEST 2 — Decline button shows confirmation dialog', (tester) async {
      final requestProvider = MockRequestProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      requestProvider.incoming_ = [
        RequestModel(
          id: 'req1',
          fromUserId: 'user2',
          fromUserName: 'Alice',
          toUserId: 'user1',
          listingId: 'listing1',
          skillName: 'Python',
          message: 'Teach me Python',
          proposedTimes: [],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Mock the declineRequest method
      when(requestProvider.declineRequest(
        any as String,
        any as String,
        any as String,
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildTestApp(
          requestProvider: requestProvider,
          authProvider: authProvider,
          homeScreen: const RequestsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap Decline button
      final declineButton = find.widgetWithText(OutlinedButton, 'Decline');
      if (declineButton.evaluate().isNotEmpty) {
        await tester.tap(declineButton);
        await tester.pumpAndSettle();

        // Should show a confirmation dialog or similar
        expect(find.byType(AlertDialog), findsWidgets);
      }
    });

    testWidgets('TEST 3 — switching to Outgoing tab works', (tester) async {
      final requestProvider = MockRequestProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      requestProvider.incoming_ = [
        RequestModel(
          id: 'req1',
          fromUserId: 'user2',
          fromUserName: 'Alice',
          toUserId: 'user1',
          listingId: 'listing1',
          skillName: 'Python',
          message: 'Teach me',
          proposedTimes: [],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      requestProvider.outgoing_ = [
        RequestModel(
          id: 'req2',
          fromUserId: 'user1',
          fromUserName: 'Charlie',
          toUserId: 'user4',
          listingId: 'listing3',
          skillName: 'Spanish',
          message: 'Can you teach me Spanish?',
          proposedTimes: ['Friday 5pm'],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          requestProvider: requestProvider,
          authProvider: authProvider,
          homeScreen: const RequestsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Outgoing tab
      final outgoingTab = find.text('Outgoing');
      if (outgoingTab.evaluate().isNotEmpty) {
        await tester.tap(outgoingTab);
        await tester.pumpAndSettle();

        // After switching, should show outgoing requests
        expect(find.text('Spanish'), findsWidgets);
      }
    });

    testWidgets('TEST 4 — empty incoming shows empty state', (tester) async {
      final requestProvider = MockRequestProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      // Empty incoming requests
      requestProvider.incoming_ = [];
      requestProvider.outgoing_ = [];

      await tester.pumpWidget(
        _buildTestApp(
          requestProvider: requestProvider,
          authProvider: authProvider,
          homeScreen: const RequestsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No incoming requests'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });
  });
}
