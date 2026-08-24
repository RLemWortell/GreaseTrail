import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:greasetrail/main.dart';

void main() {
  testWidgets('GreaseTrail loads the garage tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GreaseTrailApp());
    await tester.pumpAndSettle();

    expect(find.text('GARAGE'), findsNWidgets(2)); // title + tab bar label
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
