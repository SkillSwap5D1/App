import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/auth/register_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class MockAuthProvider extends Mock implements AuthProvider {
  bool loading = false;

  @override
  bool get isLoading => loading;
}

Widget _buildTestApp({required AuthProvider authProvider}) {
  return MaterialApp(
    theme: AppTheme.theme,
    home: Provider<AuthProvider>.value(
      value: authProvider,
      child: const RegisterScreen(),
    ),
  );
}

void main() {
  Provider.debugCheckInvalidValueType = null;

  group('RegisterScreen', () {
    testWidgets('renders all fields including first name, last name, email, course, password, confirm password', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
      expect(find.text('University email'), findsOneWidget);
      expect(find.text('Course'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.text('Select your course'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('submit with mismatched passwords shows error message', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jamie');
      await tester.enterText(fields.at(1), 'Smith');
      await tester.enterText(fields.at(2), 'jamie@port.ac.uk');
      await tester.enterText(fields.at(3), 'password123');
      await tester.pump();
      await tester.enterText(fields.at(4), 'password456');
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('submit without course selection shows required error', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jamie');
      await tester.enterText(fields.at(1), 'Smith');
      await tester.enterText(fields.at(2), 'jamie@port.ac.uk');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.pump();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please select your course'), findsOneWidget);
    });

    testWidgets('all fields filled correctly calls AuthProvider.register()', (tester) async {
      final authProvider = MockAuthProvider();
      when(authProvider.register(
        email: 'jamie@port.ac.uk',
        password: 'password123',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      )).thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Jamie');
      await tester.enterText(fields.at(1), 'Smith');
      await tester.enterText(fields.at(2), 'jamie@port.ac.uk');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.pump();

      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Computer Science').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      verify(authProvider.register(
        email: 'jamie@port.ac.uk',
        password: 'password123',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      )).called(1);
    });
  });
}