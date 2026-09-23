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

Finder resultScrollable() => find
    .descendant(
      of: find.byType(PlasterResultScreen),
      matching: find.byType(ListView),
    )
    .first;
Future<void> scrollResult(WidgetTester tester, Finder target) async {
  final scrollable = resultScrollable();
  final viewport = tester.getRect(scrollable);
  for (var attempt = 0; attempt < 16; attempt++) {
    final matches = target.evaluate();
    if (matches.isNotEmpty) {
      final rect = tester.getRect(target.first);
      if (rect.center.dy >= viewport.top + 8 &&
          rect.center.dy <= viewport.bottom - 12) {
        return;
      }
      final delta = rect.center.dy > viewport.bottom - 12
          ? const Offset(0, -220)
          : const Offset(0, 220);
      await tester.drag(scrollable, delta);
    } else {
      await tester.drag(scrollable, const Offset(0, -220));
    }
    await tester.pumpAndSettle();
  }
  fail('Could not bring the requested result control into the viewport.');
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
      await scrollResult(tester, find.text('Thickness'));
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
      await tapVisible(tester, find.text('Calculators'));
      await tapVisible(tester, find.text('Plaster Calculator').first);
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
      await scrollResult(tester, find.text('Total Plaster Cost'));
      expect(find.text('₹25386.67'), findsOneWidget);
      expect(find.text('Cost per m²'), findsOneWidget);
      await scrollResult(tester, find.text('Edit Calculation'));
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
  testWidgets('imperial input converts once and keeps primary result in m²', (
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
    await tapVisible(tester, find.text('Calculate Plaster'));
    final screen = tester.widget<PlasterResultScreen>(
      find.byType(PlasterResultScreen),
    );
    expect(screen.result.area, closeTo(94 * .3048 * .3048, 1e-9));
    expect(find.textContaining('8.73 m²'), findsWidgets);
    await scrollResult(tester, find.text('Cost per m²'));
    expect(find.text('Cost per m²'), findsOneWidget);
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
    await scrollResult(tester, find.text('Working Days'));
    expect(tester.takeException(), isNull);
    await scrollResult(tester, find.text('Cost per m²'));
    expect(tester.takeException(), isNull);
  });
  testWidgets('plaster result keeps labour details collapsed until requested', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PlasterScreen()),
    );
    await enter(tester, 'Wall Length', '10');
    await enter(tester, 'Wall Height', '10');
    await rates(tester);
    await tapVisible(tester, find.text('Calculate Plaster'));
    expect(find.text('Crew'), findsOneWidget);
    expect(find.text('Working Days'), findsOneWidget);
    expect(find.text('Mason mandays'), findsNothing);
    final details = find.byType(ExpansionTile);
    await scrollResult(tester, details);
    await tester.tap(details);
    await tester.pumpAndSettle();
    expect(find.text('Mason mandays'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
