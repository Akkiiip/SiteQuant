import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/screens/tile_calculator_screen.dart';
import 'package:site_quant/screens/tile_result_screen.dart';
import 'package:site_quant/services/ad_consent_manager.dart';
import 'package:site_quant/services/analytics_service.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/widgets/bottom_banner_slot.dart';
import 'package:site_quant/widgets/tile_diagram.dart';

class _Logger implements AnalyticsEventLogger {
  final names = <String>[];
  final parameters = <Map<String, Object>?>[];
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    names.add(name);
    this.parameters.add(parameters);
  }
}

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

void main() {
  setUp(() {
    AdConsentManager.canRequestAds.value = false;
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() {
    AnalyticsService.resetLoggerForTesting();
    MeasurementPreferences.system.value = null;
  });

  testWidgets('three tile types render a compact specific diagram at 360x800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final type in TileWorkType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: TileCalculatorScreen(key: ValueKey(type), type: type),
        ),
      );
      expect(
        find.byWidgetPredicate((w) => w is TileDiagram && w.type == type),
        findsOneWidget,
      );
      expect(find.byType(BottomBannerSlot), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('direct area calculates and emits privacy-safe completion', (
    tester,
  ) async {
    final logger = _Logger();
    AnalyticsService.setLoggerForTesting(logger);
    await tester.pumpWidget(
      const MaterialApp(
        home: TileCalculatorScreen(type: TileWorkType.floorTiles),
      ),
    );
    await tester.tap(find.text('Direct Area'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Gross tile area'), '10');
    await tester.scrollUntilVisible(
      find.text('Calculate Tiles & Flooring'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Calculate Tiles & Flooring').last);
    await tester.pumpAndSettle();
    expect(find.byType(TileResultScreen), findsOneWidget);
    expect(logger.names, contains('calculator_opened'));
    expect(logger.names, contains('calculation_completed'));
    final event = logger.names.indexOf('calculation_completed');
    expect(logger.parameters[event], {
      'calculator': 'tiles',
      'work_type': 'floorTiles',
    });
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dimension quantity reaches the wall result without changing the engine',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TileCalculatorScreen(type: TileWorkType.wallTiles),
        ),
      );
      await tester.enterText(field('Wall length'), '2');
      await tester.enterText(field('Wall height'), '3');
      await tester.enterText(field('Quantity'), '2');
      await tester.scrollUntilVisible(
        find.text('Calculate Tiles & Flooring'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Calculate Tiles & Flooring').last);
      await tester.pumpAndSettle();
      final result = tester
          .widget<TileResultScreen>(find.byType(TileResultScreen))
          .result;
      expect(result.grossArea, 12);
      expect(result.workType, TileWorkType.wallTiles);
    },
  );
  testWidgets('invalid dimensions stay on input and log a safe error', (
    tester,
  ) async {
    final logger = _Logger();
    AnalyticsService.setLoggerForTesting(logger);
    await tester.pumpWidget(
      const MaterialApp(
        home: TileCalculatorScreen(type: TileWorkType.wallTiles),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Calculate Tiles & Flooring'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Calculate Tiles & Flooring').last);
    await tester.pump();
    expect(find.byType(TileResultScreen), findsNothing);
    expect(logger.names, contains('calculation_error'));
  });
}
