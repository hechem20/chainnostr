/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suiviedeschaine/main.dart'; // Remplacez "your_app_name" par le nom de votre projet.

void main() {
  group('LoginPage Tests', () {
    testWidgets('should display all widgets on the LoginPage',
        (WidgetTester tester) async {
      // Build the LoginPage widget
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Check for the presence of the logo (large icon)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.local_shipping &&
              widget.size == 80.0,
        ),
        findsOneWidget,
      );

      // Check for the app title
      expect(find.text("Logistics App"), findsOneWidget);

      // Check for the email input field
      expect(find.widgetWithText(TextField, "Email"), findsOneWidget);

      // Check for the password input field
      expect(find.widgetWithText(TextField, "Password"), findsOneWidget);

      // Check for the login button
      expect(find.widgetWithText(ElevatedButton, "Login"), findsOneWidget);

      // Check for the "Forgot Password?" link
      expect(find.text("Forgot Password?"), findsOneWidget);

      // Check for the "Sign Up" link
      expect(find.text("Sign Up"), findsOneWidget);
    });

    testWidgets('should trigger actions when buttons are pressed',
        (WidgetTester tester) async {
      // Build the LoginPage widget
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Tap the "Forgot Password?" link
      await tester.tap(find.text("Forgot Password?"));
      await tester.pump(); // Rebuild after the tap
      // Add expected behavior for the "Forgot Password?" link here

      // Tap the "Sign Up" link
      await tester.tap(find.text("Sign Up"));
      await tester.pump(); // Rebuild after the tap
      // Add expected behavior for the "Sign Up" link here

      // Tap the "Login" button
      await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
      await tester.pump(); // Rebuild after the tap
      // Add expected behavior for the "Login" button here
    });
  });
}*/
