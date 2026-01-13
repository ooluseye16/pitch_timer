// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitch_timer/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PitchTimerApp());

    // Verify that the app title is displayed
    expect(find.text('Pitch Timer'), findsOneWidget);

    // Verify that the timer setup UI is displayed
    expect(find.text('Set Timer Duration'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
