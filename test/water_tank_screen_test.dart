import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/water_tank_calculator_screen.dart';
import 'package:site_quant/screens/water_tank_screen.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/water_tank_diagram.dart';

void main() {
  testWidgets('selector renders both tank cards and navigates at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const WaterTankScreen()),
    );
    expect(find.text('Rectangular RCC Tank'), findsOneWidget);
    expect(find.text('Circular RCC Tank'), findsOneWidget);
    expect(find.byType(WaterTankDiagram), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('water-tank-rectangular')));
    await tester.pumpAndSettle();
    expect(find.byType(WaterTankCalculatorScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('water-tank-circular')));
    await tester.pumpAndSettle();
    expect(find.byType(WaterTankCalculatorScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
