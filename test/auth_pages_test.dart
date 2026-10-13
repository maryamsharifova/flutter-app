import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/auth/login_page.dart';
import 'package:todo_app/auth/sign_up_page.dart';

Future<void> pumpPage(WidgetTester tester, Widget page) async {
  // A tall test screen so the column never overflows.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: page)),
  );
}

void main() {
  group('LoginPage', () {
    testWidgets('shows the username and password fields', (tester) async {
      await pumpPage(tester, const LoginPage());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows an error when both fields are empty', (tester) async {
      await pumpPage(tester, const LoginPage());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Please fill in both fields'), findsOneWidget);
    });

    testWidgets('has a link to the sign up page', (tester) async {
      await pumpPage(tester, const LoginPage());

      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });
  });

  group('SignUpPage', () {
    testWidgets('shows three input fields', (tester) async {
      await pumpPage(tester, const SignUpPage());

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets("shows an error when passwords don't match", (tester) async {
      await pumpPage(tester, const SignUpPage());

      await tester.enterText(find.byType(TextField).at(0), 'maryam');
      await tester.enterText(find.byType(TextField).at(1), 'abcd');
      await tester.enterText(find.byType(TextField).at(2), 'abce');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text("Passwords don't match"), findsOneWidget);
    });

    testWidgets('has a link back to the login page', (tester) async {
      await pumpPage(tester, const SignUpPage());

      expect(find.text('Already have an account? Login'), findsOneWidget);
    });
  });
}