import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/masonry_input.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/screens/masonry_calculator_screen.dart';
import 'package:site_quant/screens/masonry_v2_result_screen.dart';
import 'package:site_quant/services/analytics_service.dart';
import 'package:site_quant/services/masonry_reference_defaults.dart';
import 'package:site_quant/services/masonry_v2_calculator.dart';

class _Logger implements AnalyticsEventLogger {
  final names = <String>[];
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async => names.add(name);
}

void main() {
  tearDown(AnalyticsService.resetLoggerForTesting);
  testWidgets('each masonry type displays its existing standard dimensions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const expected = <MasonryType, String>{
      MasonryType.clayBrick: '190 × 90 × 90 mm',
      MasonryType.aacBlock: '600 × 200 × 200 mm',
      MasonryType.concreteBlock: '400 × 200 × 200 mm',
      MasonryType.lateriteStone: '355.6 × 228.6 × 177.8 mm',
    };

    for (final entry in expected.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: MasonryCalculatorScreen(
            key: ValueKey(entry.key),
            type: entry.key,
          ),
        ),
      );
      expect(
        find.text('Standard dimensions: ${entry.value}'),
        findsOneWidget,
        reason: entry.key.name,
      );
      expect(find.byKey(const Key('Wall thickness')), findsOneWidget);
    }
  });

  testWidgets('custom dimensions are prefilled, editable and restorable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: MasonryCalculatorScreen(type: MasonryType.clayBrick),
      ),
    );
    expect(find.text('Standard dimensions: 190 × 90 × 90 mm'), findsOneWidget);
    await tester.tap(find.text('Customize dimensions'));
    await tester.pump();

    TextField field(String key) =>
        tester.widget<TextField>(find.byKey(Key(key)));
    expect(field('Unit length').controller!.text, '190');
    expect(field('Unit width').controller!.text, '90');
    expect(field('Unit height').controller!.text, '90');
    await tester.enterText(find.byKey(const Key('Unit length')), '250');
    await tester.enterText(find.byKey(const Key('Unit width')), '125');
    await tester.enterText(find.byKey(const Key('Unit height')), '100');
    expect(field('Unit length').controller!.text, '250');

    await tester.ensureVisible(find.text('Use Standard Dimensions'));
    await tester.tap(find.text('Use Standard Dimensions'));
    await tester.pump();
    expect(find.byKey(const Key('Unit length')), findsNothing);
    await tester.tap(find.text('Customize dimensions'));
    await tester.pump();
    expect(field('Unit length').controller!.text, '190');
    expect(field('Unit width').controller!.text, '90');
    expect(field('Unit height').controller!.text, '90');
  });

  testWidgets('custom dimensions flow into the existing result path', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: MasonryCalculatorScreen(type: MasonryType.clayBrick),
      ),
    );
    await tester.tap(find.text('Direct area mode'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('Wall area')), '10');
    await tester.tap(find.text('Customize dimensions'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('Unit length')), '250');
    await tester.enterText(find.byKey(const Key('Unit width')), '125');
    await tester.enterText(find.byKey(const Key('Unit height')), '100');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate Masonry').last);
    await tester.pumpAndSettle();

    final screen = tester.widget<MasonryV2ResultScreen>(
      find.byType(MasonryV2ResultScreen),
    );
    expect(screen.result.input.unitSize.lengthMm, 250);
    expect(screen.result.input.unitSize.widthMm, 125);
    expect(screen.result.input.unitSize.heightMm, 100);
    final standard = MasonryV2Calculator.calculate(
      _input(MasonryReferenceDefaults.forType(MasonryType.clayBrick).unitSize),
    );
    expect(screen.result.takeoff.unitCount, isNot(standard.takeoff.unitCount));
    expect(screen.result.materialCost, isNot(standard.materialCost));
    await tester.scrollUntilVisible(find.text('Edit Calculation'), 300);
    await tester.tap(find.text('Edit Calculation'));
    await tester.pumpAndSettle();
    expect(find.byType(MasonryCalculatorScreen), findsOneWidget);
    expect(find.byKey(const Key('Unit length')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('Unit length')))
          .controller!
          .text,
      '250',
    );
  });

  for (final invalid in ['0', '-1', 'not-a-number']) {
    testWidgets('custom unit length rejects $invalid', (tester) async {
      final logger = _Logger();
      AnalyticsService.setLoggerForTesting(logger);
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(
          home: MasonryCalculatorScreen(type: MasonryType.clayBrick),
        ),
      );
      await tester.tap(find.text('Direct area mode'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('Wall area')), '10');
      await tester.tap(find.text('Customize dimensions'));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('Unit length')), invalid);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculate Masonry').last);
      await tester.pump();

      expect(find.byType(MasonryV2ResultScreen), findsNothing);
      expect(find.text('Enter a valid unit length.'), findsOneWidget);
      expect(
        logger.names.where((name) => name == 'calculation_error'),
        hasLength(1),
      );
    });
  }

  test(
    'unit dimensions change materials but not labour or crew calculations',
    () {
      final preset = MasonryReferenceDefaults.forType(MasonryType.clayBrick);
      final standard = MasonryV2Calculator.calculate(_input(preset.unitSize));
      final custom = MasonryV2Calculator.calculate(
        _input(
          const MasonryUnitSize(lengthMm: 250, widthMm: 125, heightMm: 100),
        ),
      );

      expect(custom.takeoff.masonryVolume, standard.takeoff.masonryVolume);
      expect(custom.takeoff.unitCount, isNot(standard.takeoff.unitCount));
      expect(custom.takeoff.mortarVolume, isNot(standard.takeoff.mortarVolume));
      expect(custom.takeoff.cementBags, isNot(standard.takeoff.cementBags));
      expect(custom.takeoff.sandM3, isNot(standard.takeoff.sandM3));
      expect(custom.materialCost, isNot(standard.materialCost));
      expect(custom.productivity.mandays, standard.productivity.mandays);
      expect(custom.productivity.crew, standard.productivity.crew);
      expect(
        custom.productivity.workingDays,
        standard.productivity.workingDays,
      );
      expect(custom.labour.totalCost, standard.labour.totalCost);
    },
  );
}

MasonryInput _input(MasonryUnitSize size) {
  final preset = MasonryReferenceDefaults.forType(MasonryType.clayBrick);
  return MasonryInput(
    type: MasonryType.clayBrick,
    grossArea: 10,
    thicknessMm: preset.thicknessMm,
    unitSize: size,
    cementPart: 1,
    sandPart: 6,
    wastagePercent: preset.wastagePercent,
    unitRate: preset.unitRate,
    cementRatePerBag: preset.cementRatePerBag,
    sandRatePerM3: preset.sandRatePerM3,
    masonDaysPerM3: preset.masonDaysPerM3,
    helperDaysPerM3: preset.helperDaysPerM3,
    masonDailyWage: preset.masonWage,
    helperDailyWage: preset.helperWage,
    masons: 2,
    helpers: 2,
  );
}
