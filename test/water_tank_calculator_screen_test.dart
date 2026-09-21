import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/water_tank_input.dart';
import 'package:site_quant/screens/water_tank_calculator_screen.dart';
import 'package:site_quant/screens/water_tank_result_screen.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/water_tank_diagram.dart';

Future<void> enter(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> fillValid(WidgetTester tester, WaterTankType type) async {
  if (type == WaterTankType.circular) {
    await enter(tester, 'Diameter', '3');
  } else {
    await enter(tester, 'Length', '4');
    await enter(tester, 'Width', '3');
  }
  for (final item in const {
    'Depth': '2',
    'Wall thickness': '.2',
    'Base slab thickness': '.25',
    'Top slab thickness': '.15',
  }.entries) {
    await enter(tester, item.key, item.value);
  }
}

void main() {
  for (final type in WaterTankType.values) {
    testWidgets('${type.name} calculator renders, validates and calculates', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: WaterTankCalculatorScreen(type: type),
        ),
      );
      expect(find.byType(WaterTankDiagram), findsOneWidget);
      expect(find.text('Internal dimensions'), findsOneWidget);
      expect(
        find.byKey(
          ValueKey(type == WaterTankType.circular ? 'Diameter' : 'Length'),
        ),
        findsOneWidget,
      );
      expect(find.text('Material & Labour Settings'), findsOneWidget);
      expect(find.text('Reference values — editable'), findsNothing);
      await tester.ensureVisible(find.text('Material & Labour Settings'));
      await tester.tap(find.text('Material & Labour Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Reference values — editable'), findsOneWidget);
      await fillValid(tester, type);
      final button = find.text('Calculate Water Tank');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(WaterTankResultScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invalid dimensions and quantity stay on input with feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WaterTankCalculatorScreen(type: WaterTankType.rectangular),
      ),
    );
    await enter(tester, 'Length', '0');
    await enter(tester, 'Quantity', '0');
    final button = find.text('Calculate Water Tank');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(WaterTankResultScreen), findsNothing);
    expect(find.textContaining('Enter a valid'), findsWidgets);
    expect(find.text('Quantity must be at least 1.'), findsOneWidget);
  });
}
