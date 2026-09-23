import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/screens/concrete_result_screen.dart';
import 'package:site_quant/screens/concrete_screen.dart';
import 'package:site_quant/screens/app_shell.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/calculator_ui.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);

  testWidgets('calculator list opens Concrete', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SiteQuantShell()),
    );
    await tester.tap(find.text('Calculators'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concrete Calculator').first);
    await tester.pumpAndSettle();
    expect(find.byType(ConcreteScreen), findsOneWidget);
    expect(find.byType(CalculatorCalculateButton), findsOneWidget);
  });

  testWidgets('Concrete types, units and result retain existing values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ConcreteScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Custom Volume'), findsWidgets);
    await tester.tap(find.text('Slab'));
    await tester.pumpAndSettle();
    expect(find.text('Thickness'), findsOneWidget);
    await tester.tap(find.text('Imperial'));
    await tester.pumpAndSettle();
    expect(MeasurementPreferences.system.value, MeasurementSystem.imperial);
    await tester.tap(find.text('Metric'));
    await tester.pumpAndSettle();
    for (final entry in {
      'Length': '4.5',
      'Width': '3',
      'Thickness': '0.15',
    }.entries) {
      final finder = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == entry.key,
      );
      await tester.ensureVisible(finder);
      await tester.enterText(finder, entry.value);
    }
    await tester.ensureVisible(find.byType(CalculatorCalculateButton));
    await tester.tap(find.byType(CalculatorCalculateButton));
    await tester.pumpAndSettle();
    final result = tester.widget<ConcreteResultScreen>(
      find.byType(ConcreteResultScreen),
    );
    expect(result.result.volume, closeTo(2.025, 0.000001));
    expect(find.text('2.02 m³'), findsOneWidget);
    expect(find.text('Material Requirement'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Calculation Details'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ConcreteResultScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Calculation Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Concrete screen and result fit 360x800', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ConcreteScreen()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(CalculatorCalculateButton));
    expect(tester.takeException(), isNull);
  });
}
