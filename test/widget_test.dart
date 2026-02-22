// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/onboarding/onboarding_view.dart';

void main() {
  testWidgets('Onboarding flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: OnboardingPage(),
    ));

    // Verify that the first onboarding screen is shown.
    expect(find.text('Selamat Datang!'), findsOneWidget);

    // Tap the 'Next' button.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify that the second onboarding screen is shown.
    expect(find.text('Keamanan Terjamin'), findsOneWidget);

    // Tap the 'Next' button.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify that the third onboarding screen is shown.
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    // Tap the 'Get Started' button.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that we are on the login page.
    expect(find.text('Login Gatekeeper'), findsOneWidget);
  });
}
