import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heart_game/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Splash screen appears initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Heart Game'), findsOneWidget);
  });
}
