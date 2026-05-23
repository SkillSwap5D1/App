import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/request_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/request_provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/requests/requests_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import '../mocks.mocks.dart';

// ── Test Fixtures ───────────────────────────────────────────────────────

final testUser = UserModel(
  uid: 'user123',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@myport.ac.uk',
  course: 'Computer Science',
  bio: 'Test user',
  rating: 4.8,
  sessionsCompleted: 5,
  memberSince: DateTime.now(),
  showFullName: true,
  showCourse: true,
  showPhoto: true,
);

final testIncomingRequest1 = RequestModel(
  id: 'req1',
  fromUserId: 'user456',
  fromUserName: 'Alice Smith',
  toUserId: 'user123',
  toUserName: 'Test User',
  listingId: 'listing1',
  skillName: 'Python',
  message: 'Want to learn Python',
  status: 'pending',
  proposedTimes: ['Monday 2pm'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final testIncomingRequest2 = RequestModel(
  id: 'req2',
  fromUserId: 'user789',
  fromUserName: 'Bob Johnson',
  toUserId: 'user123',
  toUserName: 'Test User',
  listingId: 'listing2',
  skillName: 'Spanish',
  message: 'Can we start lessons?',
  status: 'pending',
  proposedTimes: ['Friday 1pm'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final testOutgoingRequest = RequestModel(
  id: 'req3',
  fromUserId: 'user123',
  fromUserName: 'John Doe',
  toUserId: 'user101',
  toUserName: 'Target User',
  listingId: 'listing3',
  skillName: 'Web Design',
  message: 'Interested in learning',
  status: 'pending',
  proposedTimes: ['Saturday 10am'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// ── Test Widget Builder ──────────────────────────────────────────────────

Widget buildTestApp({
  required RequestProvider requestProvider,
  required AuthProvider authProvider,
}) {
  Provider.debugCheckInvalidValueType = null;

  return MaterialApp(
    theme: AppTheme.theme,
    home: MultiProvider(
      providers: [
        Provider<RequestProvider>.value(value: requestProvider),
        Provider<AuthProvider>.value(value: authProvider),
      ],
      child: const RequestsScreen(),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────

void main() {
  group('RequestsScreen Tests', () {
    late MockRequestProvider mockRequestProvider;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockRequestProvider = MockRequestProvider();
      mockAuthProvider = MockAuthProvider();
      when(mockRequestProvider.incoming).thenReturn([]);
      when(mockRequestProvider.outgoing).thenReturn([]);
      when(mockRequestProvider.isLoading).thenReturn(false);
      when(mockRequestProvider.errorMessage).thenReturn(null);
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.currentUser).thenReturn(testUser);
    });

    testWidgets('renders incoming request cards', (WidgetTester tester) async {
      when(mockRequestProvider.incoming).thenReturn([testIncomingRequest1, testIncomingRequest2]);
      when(mockRequestProvider.outgoing).thenReturn([]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testIncomingRequest1.fromUserName), findsWidgets);
      expect(find.text(testIncomingRequest2.fromUserName), findsWidgets);
    });

    testWidgets('decline button shows confirmation dialog', (WidgetTester tester) async {
      when(mockRequestProvider.incoming).thenReturn([testIncomingRequest1]);
      when(mockRequestProvider.outgoing).thenReturn([]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Decline').first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Decline Request'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Decline').last);
      await tester.pumpAndSettle();

      verify(
        mockRequestProvider.declineRequest(
          testIncomingRequest1.id,
          testIncomingRequest1.fromUserId,
          testIncomingRequest1.skillName,
        ),
      ).called(1);
    });

    testWidgets('switching to outgoing tab works', (WidgetTester tester) async {
      when(mockRequestProvider.incoming).thenReturn([testIncomingRequest1]);
      when(mockRequestProvider.outgoing).thenReturn([testOutgoingRequest]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testIncomingRequest1.fromUserName), findsWidgets);

      await tester.tap(find.text('Sent'));
      await tester.pumpAndSettle();

      expect(find.text(testOutgoingRequest.skillName), findsWidgets);
    });

    testWidgets('empty incoming shows empty state', (WidgetTester tester) async {
      when(mockRequestProvider.incoming).thenReturn([]);
      when(mockRequestProvider.outgoing).thenReturn([]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No requests received yet'), findsOneWidget);
    });
  });
}
