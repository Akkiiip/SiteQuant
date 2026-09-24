import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/models/paint_result.dart';
import 'package:site_quant/screens/paint_result_screen.dart';
import 'package:site_quant/screens/paint_screen.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      widget.decoration?.labelText?.contains(label) == true,
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

Future<void> choosePaintOnly(WidgetTester tester) async {
  final dropdown = find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<PaintWorkType>,
  );
  await tapVisible(tester, dropdown);
  await tester.tap(find.text('Interior Emulsion Only').last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);

  testWidgets(
    'standard reference calculates without technical coefficient input',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
      );
      await choosePaintOnly(tester);
      expect(find.textContaining('CPWD DAR item 13.82.2'), findsOneWidget);
      await enter(tester, 'Surface length', '10');
      await enter(tester, 'Surface height / width', '10');
      expect(field('Paint Coverage'), findsNothing);
      expect(field('Painter coefficient'), findsNothing);
      expect(field('Paint rate'), findsOneWidget);
      await tapVisible(tester, find.text('Calculate Paint Estimate'));
      expect(find.byType(PaintResultScreen), findsOneWidget);
      expect(find.text('Working Days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('custom product reveals technical overrides', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    await choosePaintOnly(tester);
    await tapVisible(tester, find.text('Custom Product'));
    expect(field('Paint Coverage'), findsOneWidget);
    expect(field('Painter coefficient'), findsOneWidget);
    await enter(tester, 'Paint Coverage', '10');
    await enter(tester, 'Paint rate', '300');
    await enter(tester, 'Painter coefficient', '1');
    await enter(tester, 'Helper coefficient', '.5');
    expect(tester.takeException(), isNull);
  });

  testWidgets('paint result details expand and collapse without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    await choosePaintOnly(tester);
    await enter(tester, 'Surface length', '10');
    await enter(tester, 'Surface height / width', '10');
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    expect(find.text('Crew'), findsOneWidget);
    expect(find.text('Working Days'), findsOneWidget);
    expect(find.text('Labour Cost'), findsWidgets);
    expect(find.text('Painter mandays'), findsNothing);
    await tester.scrollUntilVisible(
      find.byType(ExpansionTile),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, find.text('Calculation Details').last);
    expect(find.text('Painter mandays'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(ExpansionTile),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, find.text('Calculation Details').last);
    expect(find.text('Painter mandays'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('putty reference shows packaging at phone width', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PaintScreen()),
    );
    final dropdown = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<PaintWorkType>,
    );
    await tapVisible(tester, dropdown);
    await tester.tap(find.text('Putty Only').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('SiteQuant Reference Average'), findsOneWidget);
    expect(find.text('Putty pack size'), findsOneWidget);
    await enter(tester, 'Surface length', '10');
    await enter(tester, 'Surface height / width', '10');
    await tapVisible(tester, find.text('Calculate Paint Estimate'));
    expect(find.byType(PaintResultScreen), findsOneWidget);
    expect(find.text('Putty Packaging'), findsOneWidget);
    expect(find.text('Required quantity'), findsOneWidget);
    expect(find.text('Pack size (editable reference)'), findsOneWidget);
    expect(find.text('Approx. packs/bags'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
