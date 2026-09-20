import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/models/paint_result.dart';
import 'package:site_quant/screens/paint_result_screen.dart';
import 'package:site_quant/screens/paint_screen.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> enter(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), value);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillPaintOnly(WidgetTester tester) async {
  await enter(tester, 'Surface length', '10');
  await enter(tester, 'Surface height / width', '10');
  await enter(tester, 'Paint Coverage (m² / L / coat)', '10');
  await enter(tester, 'Paint rate', '300');
  await enter(tester, 'Painter coefficient', '1');
  await enter(tester, 'Helper coefficient', '.5');
  await enter(tester, 'Painter daily wage', '900');
  await enter(tester, 'Helper daily wage', '600');
}

Future<void> choosePaintOnly(WidgetTester tester) async {
  final workType = find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<PaintWorkType>,
  );
  await tapVisible(tester, workType);
  await tester.tap(find.text('Paint Only').last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);

  testWidgets('Paint Only produces a transparent estimate from net area', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    await choosePaintOnly(tester);
    await enter(tester, 'Surface length', '10');
    await enter(tester, 'Surface height / width', '10');
    await tapVisible(tester, find.text('Add opening'));
    await enter(tester, 'Opening width', '1');
    await enter(tester, 'Opening height', '2');
    await enter(tester, 'Paint Coverage (m² / L / coat)', '10');
    await enter(tester, 'Paint rate', '300');
    await enter(tester, 'Painter coefficient', '1');
    await enter(tester, 'Helper coefficient', '.5');
    await enter(tester, 'Painter daily wage', '900');
    await enter(tester, 'Helper daily wage', '600');
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    final result = tester.widget<PaintResultScreen>(
      find.byType(PaintResultScreen),
    );
    expect(result.result.netArea, 98);
    expect(result.result.materials.single.finalQuantity, closeTo(10.29, 1e-10));
    await tester.scrollUntilVisible(find.text('Estimated Working Days'), 300);
    expect(find.text('Estimated Working Days'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cost per m²'), 300);
    expect(find.text('Cost per m²'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imperial direct-area input displays ft² without hard-coded m²', (
    tester,
  ) async {
    MeasurementPreferences.system.value = MeasurementSystem.imperial;
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    await tapVisible(tester, find.text('Direct Area'));
    await choosePaintOnly(tester);
    await enter(tester, 'Gross paint area', '100');
    await enter(tester, 'Paint Coverage (m² / L / coat)', '10');
    await enter(tester, 'Paint rate', '300');
    await enter(tester, 'Painter coefficient', '1');
    await enter(tester, 'Helper coefficient', '.5');
    await enter(tester, 'Painter daily wage', '900');
    await enter(tester, 'Helper daily wage', '600');
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    expect(find.text('100 ft²'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Cost per ft²'), 300);
    expect(find.text('Cost per ft²'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layout with enlarged text has no Paint overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.2)),
          child: child!,
        ),
        home: const PaintScreen(),
      ),
    );
    await choosePaintOnly(tester);
    await fillPaintOnly(tester);
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    await tester.scrollUntilVisible(find.text('Total Project Cost'), 300);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid coverage remains on input with a useful message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    await choosePaintOnly(tester);
    await enter(tester, 'Surface length', '10');
    await enter(tester, 'Surface height / width', '10');
    await enter(tester, 'Paint Coverage (m² / L / coat)', '0');
    await enter(tester, 'Paint rate', '300');
    await enter(tester, 'Painter coefficient', '1');
    await enter(tester, 'Helper coefficient', '.5');
    await enter(tester, 'Painter daily wage', '900');
    await enter(tester, 'Helper daily wage', '600');
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    expect(
      find.text('Paint coverage must be a finite number greater than zero.'),
      findsWidgets,
    );
    expect(find.byType(PaintResultScreen), findsNothing);
  });
}
