import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/app_shell.dart';
import 'package:site_quant/screens/settings_screen.dart';
import 'package:site_quant/screens/tile_calculator_screen.dart';
import 'package:site_quant/services/analytics_service.dart';
import 'package:site_quant/services/quiz_reminder_service.dart';

class _Event {
  const _Event(this.name, this.parameters);

  final String name;
  final Map<String, Object>? parameters;
}

class _Logger implements AnalyticsEventLogger {
  final events = <_Event>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add(_Event(name, parameters));
  }
}

void main() {
  setUp(() {
    QuizReminderService.navigationRequest.value = 0;
  });

  tearDown(() {
    AnalyticsService.resetLoggerForTesting();
    QuizReminderService.navigationRequest.value = 0;
  });

  testWidgets('Home searches all calculators but keeps eight quick cards', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));

    expect(find.byKey(const ValueKey('home-calculator-tiles')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-calculator-steel')), findsNothing);
    expect(find.byKey(const ValueKey('home-calculator-volume')), findsNothing);

    final search = find.byType(TextField).first;
    await tester.enterText(search, 'Steel');
    await tester.pump();
    expect(find.byKey(const ValueKey('home-calculator-steel')), findsOneWidget);

    await tester.enterText(search, 'Volume');
    await tester.pump();
    expect(
      find.byKey(const ValueKey('home-calculator-volume')),
      findsOneWidget,
    );

    await tester.enterText(search, '');
    await tester.pump();
    expect(find.byKey(const ValueKey('home-calculator-steel')), findsNothing);
    expect(find.byKey(const ValueKey('home-calculator-volume')), findsNothing);
  });

  testWidgets('every registry calculator logs one standardized open event', (
    tester,
  ) async {
    final logger = _Logger();
    AnalyticsService.setLoggerForTesting(logger);
    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
    await tester.tap(find.text('Calculators').last);
    await tester.pumpAndSettle();

    const calculators = <String, String>{
      'Concrete': 'concrete',
      'Masonry': 'masonry',
      'Plaster': 'plaster',
      'Paint': 'paint',
      'Tiles': 'tiles',
      'Shuttering': 'shuttering',
      'Water Tank': 'water_tank',
      'Excavation': 'excavation',
      'Steel Weight': 'steel_weight',
      'Volume': 'volume',
    };

    for (final entry in calculators.entries) {
      await tester.enterText(find.byType(TextField).last, entry.key);
      await tester.pumpAndSettle();
      final before = logger.events.length;
      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();
      final opened = logger.events
          .skip(before)
          .where((event) => event.name == 'calculator_opened');
      expect(opened.length, 1, reason: entry.key);
      expect(opened.single.parameters, {'calculator': entry.value});

      if (entry.value == 'tiles') {
        await tester.tap(find.text('Floor Tiles').first);
        await tester.pumpAndSettle();
        expect(find.byType(TileCalculatorScreen), findsOneWidget);
        expect(
          logger.events
              .skip(before)
              .where((event) => event.name == 'calculator_opened')
              .length,
          1,
        );
        Navigator.of(tester.element(find.byType(TileCalculatorScreen))).pop();
        await tester.pumpAndSettle();
      }

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Unit Converter logs calculator_opened from Tools', (
    tester,
  ) async {
    final logger = _Logger();
    AnalyticsService.setLoggerForTesting(logger);
    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
    await tester.tap(find.text('Tools').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unit Converter'));
    await tester.pumpAndSettle();

    final opens = logger.events.where(
      (event) => event.name == 'calculator_opened',
    );
    expect(opens.length, 1);
    expect(opens.single.parameters, {'calculator': 'unit_converter'});
  });

  testWidgets('cold notification start uses the shared Learn analytics path', (
    tester,
  ) async {
    final logger = _Logger();
    AnalyticsService.setLoggerForTesting(logger);
    QuizReminderService.navigationRequest.value = 1;

    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
    await tester.pump();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(logger.events.map((event) => event.name), [
      'quiz_notification_opened',
      'quiz_opened',
    ]);
    await tester.pump();
    expect(logger.events.length, 2);
  });

  testWidgets(
    'unavailable rows are disabled and functional rows remain clear',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
      await tester.tap(find.text('Tools').last);
      await tester.pumpAndSettle();

      for (final label in [
        'Rate Analysis',
        'BOQ Generator',
        'Project Tracker',
      ]) {
        final tile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, label),
        );
        expect(tile.enabled, isFalse);
        expect(tile.trailing, isNull);
      }

      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      for (final label in [
        'Saved Calculations',
        'My Projects',
        'Rate Library',
      ]) {
        final tile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, label),
        );
        expect(tile.enabled, isFalse);
        expect(tile.trailing, isNull);
      }
      final pro = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'SiteQuant Pro'),
      );
      expect(pro.trailing, isNull);
      expect(find.text('Coming soon'), findsWidgets);

      await tester.tap(find.text('Settings, support & about'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );
}
