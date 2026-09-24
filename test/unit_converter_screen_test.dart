import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/unit_converter_screen.dart';

void main() {
  testWidgets('primary input precedes the live converted result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: UnitConverterScreen()));

    final input = find.widgetWithText(TextField, 'Enter Value');
    final result = find.text('Converted Value');
    expect(input, findsOneWidget);
    expect(result, findsOneWidget);
    expect(tester.getTopLeft(input).dy, lessThan(tester.getTopLeft(result).dy));

    await tester.enterText(input, '1');
    await tester.pump();
    expect(find.text('0.1'), findsOneWidget);
    expect(find.text('From: 1 mm'), findsOneWidget);
  });
}
