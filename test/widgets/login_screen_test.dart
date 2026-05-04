import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/auth/login_screen.dart';
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
    routes: {
      '/register': (_) => const RegisterScreen(),
      '/home': (_) => const Scaffold(body: Text('Home')),
    },
    home: Provider<AuthProvider>.value(
      value: authProvider,
      child: const LoginScreen(),
    ),
  );
}

void main() {
  Provider.debugCheckInvalidValueType = null;

  group('LoginScreen', () {
    testWidgets('renders email field, password field, and Sign In button', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('submitting with @gmail.com email shows red error text under email field', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      await tester.enterText(find.byType(TextField).at(0), 'student@gmail.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pump();
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      final errorFinder = find.text('Please use your @port.ac.uk email (University of Portsmouth)');
      expect(errorFinder, findsOneWidget);

      final errorText = tester.widget<Text>(errorFinder);
      expect(errorText.style?.color, AppColors.error);
    });

    testWidgets('submitting with empty password shows required error', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      await tester.ensureVisible(find.text('Sign In'));
      await tester.enterText(find.byType(TextField).at(0), 'student@port.ac.uk');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('when AuthProvider.isLoading = true button shows CircularProgressIndicator', (tester) async {
      final authProvider = MockAuthProvider();
      authProvider.loading = true;

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('tapping Create an account link navigates to RegisterScreen', (tester) async {
      final authProvider = MockAuthProvider();

      await tester.pumpWidget(_buildTestApp(authProvider: authProvider));

      final linkFinder = find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('Create an account'),
      );

      expect(linkFinder, findsOneWidget);
      await tester.ensureVisible(linkFinder);
      await tester.tap(linkFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}