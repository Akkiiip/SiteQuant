import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/screens/excavation_screen.dart';
import 'package:site_quant/screens/excavation_result_screen.dart';
import 'package:site_quant/screens/steel_weight_screen.dart';
import 'package:site_quant/screens/steel_weight_result_screen.dart';
import 'package:site_quant/screens/volume_calculator_screen.dart';
import 'package:site_quant/screens/volume_result_screen.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/calculator_ui.dart';

Finder input(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> enter(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(input(label));
  await tester.enterText(input(label), value);
}

Future<void> calculate(WidgetTester tester) async {
  final button = find.byType(CalculatorCalculateButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);

  testWidgets('Excavation result opens without narrow overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ExcavationScreen()),
    );
    await enter(tester, 'Length', '4');
    await enter(tester, 'Width', '3');
    await enter(tester, 'Depth', '2');
    await calculate(tester);
    expect(find.byType(ExcavationResultScreen), findsOneWidget);
    expect(find.text('24.000 m³'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Steel weight result opens without narrow overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SteelWeightScreen()),
    );
    await enter(tester, 'Bar Length', '6');
    await enter(tester, 'Number of Bars', '3');
    await calculate(tester);
    expect(find.byType(SteelWeightResultScreen), findsOneWidget);
    expect(find.text('Total Weight'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Volume result opens without narrow overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const VolumeCalculatorScreen(),
      ),
    );
    await enter(tester, 'Length', '4');
    await enter(tester, 'Width', '3');
    await enter(tester, 'Height', '2');
    await calculate(tester);
    expect(find.byType(VolumeResultScreen), findsOneWidget);
    expect(find.text('24 m³'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
