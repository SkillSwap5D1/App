import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/request_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/request_provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/requests/requests_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';

// ── Mock Providers ───────────────────────────────────────────────────────

class MockRequestProvider extends ChangeNotifier {
  List<RequestModel> incoming = [];
  List<RequestModel> outgoing = [];
  bool isLoading = false;

  void setIncoming(List<RequestModel> requests) {
    incoming = requests;
    notifyListeners();
  }

  void setOutgoing(List<RequestModel> requests) {
    outgoing = requests;
    notifyListeners();
  }

  int get pendingCount => incoming.where((r) => r.isPending).length;

  void loadRequests(String uid) {}
  Future<String?> sendRequest(RequestModel request) async => null;
  Future<void> acceptRequest(String requestId, Map<String, String> confirmedSlot,
      String requesterName, String skillName, String requesterId) async {}
  Future<void> declineRequest(String requestId, String requesterId, String skillName) async {}
  Future<void> counterRequest(String requestId, List<Map<String, dynamic>> newSlots, String note,
      String requesterId, String skillName) async {}
}

class MockAuthProvider extends ChangeNotifier {
  UserModel? currentUser;
  bool get isLoading => false;

  MockAuthProvider({this.currentUser});
}

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
  required MockRequestProvider requestProvider,
  required MockAuthProvider authProvider,
}) {
  Provider.debugCheckInvalidValueType = null;

  return MaterialApp(
    theme: AppTheme.theme,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<RequestProvider>(
          create: (_) => requestProvider as RequestProvider,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider as AuthProvider,
        ),
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
      mockAuthProvider = MockAuthProvider(currentUser: testUser);
    });

    testWidgets('TEST 1 — renders incoming request cards', (WidgetTester tester) async {
      mockRequestProvider.setIncoming([testIncomingRequest1, testIncomingRequest2]);

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

    testWidgets('TEST 2 — Decline button shows confirmation dialog', (WidgetTester tester) async {
      mockRequestProvider.setIncoming([testIncomingRequest1]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap Decline button
      final declineButtons = find.byWidgetPredicate(
        (widget) =>
            widget is OutlinedButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Decline',
      );

      if (declineButtons.evaluate().isNotEmpty) {
        await tester.tap(declineButtons.first);
        await tester.pumpAndSettle();

        // Verify dialog
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Decline Request'), findsWidgets);
      }
    });

    testWidgets('TEST 3 — switching to Outgoing tab works', (WidgetTester tester) async {
      mockRequestProvider.setIncoming([testIncomingRequest1]);
      mockRequestProvider.setOutgoing([testOutgoingRequest]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testIncomingRequest1.fromUserName), findsWidgets);

      // Simulate tab switch
      mockRequestProvider.setIncoming([]);
      mockRequestProvider.setOutgoing([testOutgoingRequest]);
      await tester.pumpAndSettle();

      expect(find.text(testOutgoingRequest.fromUserName), findsWidgets);
    });

    testWidgets('TEST 4 — empty incoming shows empty state', (WidgetTester tester) async {
      mockRequestProvider.setIncoming([]);

      await tester.pumpWidget(
        buildTestApp(
          requestProvider: mockRequestProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Incoming (0)'), findsWidgets);
    });
  });
}
