import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/screens/tile_result_screen.dart';
import 'package:site_quant/services/tile_calculator.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';

TileResult result() => TileCalculator.calculate(
  workType: TileWorkType.floorTiles,
  grossArea: 20,
  tileLengthMm: 600,
  tileWidthMm: 600,
  tileWastagePercent: 7,
  tileRatePerSquareMetre: 850,
  includeAdhesive: true,
  adhesiveConsumptionKgPerSquareMetre: 4.5,
  adhesiveWastagePercent: 5,
  adhesiveRatePerKg: 18,
  includeGrout: true,
  groutConsumptionKgPerSquareMetre: .25,
  groutWastagePercent: 5,
  groutRatePerKg: 90,
  includeBedding: false,
  beddingThicknessMm: 20,
  cementRatePerBag: 450,
  sandRatePerCubicMetre: 1800,
  tileMasonDaysPer10M2: 1.25,
  helperDaysPer10M2: .9,
  crew: {LabourRole.tileMason: 1, LabourRole.helper: 1},
  dailyWages: {LabourRole.tileMason: 1000, LabourRole.helper: 650},
  referenceNote: 'Reference estimate.',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() => MeasurementPreferences.system.value = null);
  testWidgets(
    'tile result keeps labour details collapsed and expands at phone width',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: TileResultScreen(result: result()),
        ),
      );
      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        find.text('Crew'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('Crew'), findsOneWidget);
      expect(find.text('Working Days'), findsOneWidget);
      expect(find.text('Labour Cost'), findsWidgets);
      expect(find.text('Tile Mason mandays'), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(ExpansionTile),
        250,
        scrollable: scrollable,
      );
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();
      expect(find.text('Tile Mason mandays'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
