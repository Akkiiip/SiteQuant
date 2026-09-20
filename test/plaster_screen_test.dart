import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/main.dart';
import 'package:site_quant/screens/plaster_screen.dart';
import 'package:site_quant/screens/plaster_result_screen.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> enter(WidgetTester tester, String label, String text) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), text);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> rates(WidgetTester tester) async {
  await enter(tester, 'Cement rate', '400');
  await enter(tester, 'Sand rate', '1500');
  await enter(tester, 'Mason daily wage', '900');
  await enter(tester, 'Helper daily wage', '700');
}

Future<void> selectThickness(WidgetTester tester, String text) async {
  final dropdown = find.byWidgetPredicate(
    (widget) =>
        widget is DropdownButtonFormField<String> &&
        widget.decoration.labelText == 'Plaster Thickness',
  );
  await tapVisible(tester, dropdown);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> scrollResult(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    350,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);

  for (final thickness in ['12', '15', '20']) {
    testWidgets('$thickness mm survives input, navigation and result display', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const PlasterScreen()),
      );
      await enter(tester, 'Wall Length', '10');
      await enter(tester, 'Wall Height', '10');
      await selectThickness(tester, '$thickness mm');
      await rates(tester);
      await tapVisible(tester, find.text('Calculate Plaster'));
      final resultScreen = tester.widget<PlasterResultScreen>(
        find.byType(PlasterResultScreen),
      );
      expect(resultScreen.result.thicknessMm, double.parse(thickness));
      await scrollResult(tester, 'Thickness');
      expect(find.text('$thickness mm'), findsOneWidget);
      expect(find.text('2 mm'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'dashboard to plaster, deductions, crew, costs and edit preservation',
    (tester) async {
      await tester.pumpWidget(const SiteQuantApp());
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Plaster Calculator'));
      await enter(tester, 'Wall Length', '10.786');
      await enter(tester, 'Wall Height', '10');
      await tapVisible(tester, find.text('Add opening'));
      await enter(tester, 'Opening width', '1');
      await enter(tester, 'Opening height', '2.1');
      await tapVisible(tester, find.text('Add opening'));
      await tester.ensureVisible(field('Opening type / name').last);
      await tester.enterText(field('Opening type / name').last, 'Window');
      await tester.ensureVisible(field('Opening width').last);
      await tester.enterText(field('Opening width').last, '1.2');
      await tester.ensureVisible(field('Opening height').last);
      await tester.enterText(field('Opening height').last, '1.2');
      await tester.ensureVisible(field('Opening quantity').last);
      await tester.enterText(field('Opening quantity').last, '4');
      await tester.pumpAndSettle();
      expect(find.textContaining('Net Area: 100 m²'), findsOneWidget);
      await selectThickness(tester, '20 mm');
      await rates(tester);
      for (final label in ['Masons in crew', 'Helpers in crew']) {
        final dropdown = find.byWidgetPredicate(
          (widget) =>
              widget is DropdownButtonFormField<int> &&
              widget.decoration.labelText == label,
        );
        await tapVisible(tester, dropdown);
        await tester.tap(find.text('2').last);
        await tester.pumpAndSettle();
      }
      await tapVisible(tester, find.text('Calculate Plaster'));
      final screen = tester.widget<PlasterResultScreen>(
        find.byType(PlasterResultScreen),
      );
      expect(screen.result.area, closeTo(100, 1e-8));
      expect(screen.result.productivity.workingDays, closeTo(5.1, 1e-8));
      expect(screen.result.labour.totalCost, closeTo(15600, 1e-8));
      await scrollResult(tester, 'Total Plaster Cost');
      expect(find.text('₹25386.67'), findsOneWidget);
      expect(find.text('Cost per m²'), findsOneWidget);
      await scrollResult(tester, 'Edit Calculation');
      await tapVisible(tester, find.text('Edit Calculation'));
      expect(find.byType(PlasterScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(field('Wall Length')).controller!.text,
        '10.786',
      );
      expect(field('Opening width'), findsNWidgets(2));
      await tapVisible(tester, find.byTooltip('Remove opening 2'));
      expect(field('Opening width'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('imperial UI converts dimensions once and displays ft² / ft³', (
    tester,
  ) async {
    MeasurementPreferences.system.value = MeasurementSystem.imperial;
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PlasterScreen()),
    );
    expect(
      tester.widget<TextField>(field('Wall Length')).decoration!.suffixText,
      'ft',
    );
    await enter(tester, 'Wall Length', '10');
    await enter(tester, 'Wall Height', '10');
    await tapVisible(tester, find.text('Add opening'));
    await enter(tester, 'Opening width', '2');
    await enter(tester, 'Opening height', '3');
    await rates(tester);
    expect(
      tester.widget<TextField>(field('Sand rate')).decoration!.suffixText,
      '₹ / m³',
    );
    await tapVisible(tester, find.text('Calculate Plaster'));
    final screen = tester.widget<PlasterResultScreen>(
      find.byType(PlasterResultScreen),
    );
    expect(screen.result.area, closeTo(94 * .3048 * .3048, 1e-9));
    expect(find.text('94 ft²'), findsWidgets);
    await scrollResult(tester, 'Wet Volume');
    expect(find.textContaining('ft³'), findsWidgets);
    await scrollResult(tester, 'Cost per ft²');
    expect(find.text('Cost per ft²'), findsOneWidget);
    expect(find.text('Cost per m² (pricing reference)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid input shows useful error without navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlasterScreen()));
    await enter(tester, 'Wall Length', '-1');
    await enter(tester, 'Wall Height', '10');
    await tapVisible(tester, find.text('Calculate Plaster'));
    expect(
      find.text('Length must be a finite number greater than zero.'),
      findsWidgets,
    );
    expect(find.byType(PlasterResultScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom thickness and ceiling retain functionality', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PlasterScreen()),
    );
    await tapVisible(tester, find.text('Ceiling Plaster'));
    expect(field('Number of Walls'), findsNothing);
    await enter(tester, 'Length', '10');
    await enter(tester, 'Width', '10');
    await selectThickness(tester, 'Custom');
    await enter(tester, 'Thickness', '25');
    await tapVisible(tester, find.text('Use site-specific productivity'));
    await enter(tester, 'Mason coefficient', '1.2');
    await enter(tester, 'Helper coefficient', '1.4');
    await rates(tester);
    await tapVisible(tester, find.text('Calculate Plaster'));
    final screen = tester.widget<PlasterResultScreen>(
      find.byType(PlasterResultScreen),
    );
    expect(screen.result.thicknessMm, 25);
    expect(screen.result.productivity.workingDays, closeTo(14, 1e-8));
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow phone layout can calculate and show the full estimate', (
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
        home: const PlasterScreen(),
      ),
    );
    await enter(tester, 'Wall Length', '10');
    await enter(tester, 'Wall Height', '10');
    await rates(tester);
    await tapVisible(tester, find.text('Calculate Plaster'));
    await scrollResult(tester, 'Estimated Working Days');
    expect(tester.takeException(), isNull);
    await scrollResult(tester, 'Cost per m²');
    expect(tester.takeException(), isNull);
  });
}
