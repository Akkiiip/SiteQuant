import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/screens/shuttering_calculator_screen.dart';
import 'package:site_quant/screens/shuttering_result_screen.dart';
import 'package:site_quant/services/analytics_service.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/shuttering_diagram.dart';

class _Logger implements AnalyticsEventLogger {
  final names = <String>[];
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async => names.add(name);
}

Future<void> pumpInput(WidgetTester tester, ShutteringType type) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: ShutteringCalculatorScreen(type: type),
    ),
  );
}

Future<void> enter(WidgetTester t, String key, String value) async {
  final f = find.byKey(ValueKey(key));
  await t.ensureVisible(f);
  await t.enterText(f, value);
  await t.pumpAndSettle();
}

Future<void> calculate(WidgetTester t) async {
  final b = find.text('Calculate Shuttering');
  await t.ensureVisible(b);
  await t.tap(b);
  await t.pumpAndSettle();
}

void main() {
  setUp(() => MeasurementPreferences.system.value = MeasurementSystem.metric);
  tearDown(() {
    AnalyticsService.resetLoggerForTesting();
    MeasurementPreferences.system.value = null;
  });
  for (final type in ShutteringType.values) {
    testWidgets(
      '${type.name} renders correct fields and calculates at 360 px',
      (t) async {
        await pumpInput(t, type);
        expect(find.byType(ShutteringDiagram), findsOneWidget);
        expect(
          find.byKey(const ValueKey('Height')),
          type == ShutteringType.slab ? findsNothing : findsOneWidget,
        );
        if (type == ShutteringType.wall) {
          expect(find.text('Thickness'), findsOneWidget);
          expect(find.text('Two Sides'), findsOneWidget);
        }
        if (type == ShutteringType.beam || type == ShutteringType.footing) {
          expect(find.text('Depth'), findsOneWidget);
        }
        await enter(t, 'Length', '4');
        await enter(t, 'Width', '2');
        if (type != ShutteringType.slab) {
          await enter(t, 'Height', '3');
        }
        await calculate(t);
        expect(find.byType(ShutteringResultScreen), findsOneWidget);
        final r = t
            .widget<ShutteringResultScreen>(find.byType(ShutteringResultScreen))
            .result;
        expect(r.contactArea, switch (type) {
          ShutteringType.column || ShutteringType.footing => 36,
          ShutteringType.beam => 32,
          ShutteringType.wall => 24,
          ShutteringType.slab => 8,
        });
        if (type == ShutteringType.column) {
          await t.scrollUntilVisible(find.text('Edit Calculation'), 300);
          await t.tap(find.text('Edit Calculation'));
          await t.pumpAndSettle();
          expect(find.byType(ShutteringCalculatorScreen), findsOneWidget);
          expect(
            t
                .widget<TextFormField>(find.byKey(const ValueKey('Length')))
                .controller!
                .text,
            '4',
          );
        }
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'invalid dimensions and quantity show feedback without navigating',
    (t) async {
      final logger = _Logger();
      AnalyticsService.setLoggerForTesting(logger);
      await pumpInput(t, ShutteringType.column);
      await enter(t, 'Length', '0');
      await enter(t, 'Width', '-2');
      await enter(t, 'Height', 'abc');
      await enter(t, 'Quantity', '0');
      await calculate(t);
      expect(find.byType(ShutteringResultScreen), findsNothing);
      expect(find.textContaining('Enter a valid'), findsWidgets);
      expect(find.textContaining('Quantity must be at least'), findsOneWidget);
      expect(
        logger.names.where((name) => name == 'calculation_error'),
        hasLength(1),
      );
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('imperial inputs convert once and retain metric result', (
    t,
  ) async {
    MeasurementPreferences.system.value = MeasurementSystem.imperial;
    await pumpInput(t, ShutteringType.slab);
    await enter(t, 'Length', '10');
    await enter(t, 'Width', '10');
    await calculate(t);
    final r = t
        .widget<ShutteringResultScreen>(find.byType(ShutteringResultScreen))
        .result;
    expect(r.contactArea, closeTo(9.290304, .000001));
    expect(find.text('9.29 m²'), findsWidgets);
  });
  testWidgets('wall side selection and editable settings reach engine', (
    t,
  ) async {
    await pumpInput(t, ShutteringType.wall);
    await enter(t, 'Length', '4');
    await enter(t, 'Width', '.2');
    await enter(t, 'Height', '3');
    await t.ensureVisible(find.text('One Side'));
    await t.tap(find.text('One Side'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Material & Labour Settings'));
    await t.tap(find.text('Material & Labour Settings'));
    await t.pumpAndSettle();
    await enter(t, 'Material rate', '100');
    await enter(t, 'Panel wastage', '0');
    await calculate(t);
    final r = t
        .widget<ShutteringResultScreen>(find.byType(ShutteringResultScreen))
        .result;
    expect(r.contactArea, 12);
    expect(r.materialCost, 1200);
  });
}
