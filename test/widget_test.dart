// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quote_builder/main.dart';

void main() {
  testWidgets('Quote builder smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuoteBuilderApp());

    // Verify that the app title is displayed
    expect(find.text('Product Quote Builder'), findsOneWidget);

    // Verify that client information fields are present
    expect(find.text('Client Name'), findsOneWidget);
    expect(find.text('Client Address'), findsOneWidget);
    expect(find.text('Reference'), findsOneWidget);

    // Verify that line items section is present
    expect(find.text('Line Items'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);

    // Verify that preview section is present
    expect(find.text('Quote Preview'), findsOneWidget);
  });
}
