import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/screens/tile_result_screen.dart';
import 'package:site_quant/services/ad_consent_manager.dart';
import 'package:site_quant/services/tile_calculator.dart';

void main() {
  testWidgets(
    'result keeps the concise summary and expandable technical detail at 360x800',
    (tester) async {
      AdConsentManager.canRequestAds.value = false;
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final result = TileCalculator.calculate(
        workType: TileWorkType.floorTiles,
        grossArea: 10,
        tileLengthMm: 600,
        tileWidthMm: 600,
        tileWastagePercent: 10,
        tileRatePerSquareMetre: 1000,
        includeAdhesive: false,
        adhesiveConsumptionKgPerSquareMetre: 4,
        adhesiveWastagePercent: 5,
        adhesiveRatePerKg: 18,
        includeGrout: false,
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
        referenceNote: 'Editable reference.',
      );
      await tester.pumpWidget(
        MaterialApp(home: TileResultScreen(result: result)),
      );
      expect(find.text('NET AREA'), findsOneWidget);
      expect(find.text('10 m²'), findsOneWidget);
      expect(find.text('Tile Quantity'), findsOneWidget);
      expect(find.text('31 pieces'), findsOneWidget);
      expect(find.text('LABOUR & TIME'), findsOneWidget);
      expect(find.text('TOTAL COST'), findsOneWidget);
      expect(find.text('Labour & Time Details'), findsNothing);
      expect(find.text('Tile Mason mandays'), findsNothing);
      await tester.scrollUntilVisible(find.text('Calculation Details'), 250);
      await tester.tap(find.text('Calculation Details'));
      await tester.pumpAndSettle();
      expect(find.text('Gross Area'), findsOneWidget);
      expect(find.text('Base Pieces'), findsOneWidget);
      expect(find.text('Tile Mason mandays'), findsOneWidget);
      expect(find.text('Helper mandays'), findsOneWidget);
      expect(find.textContaining('.00'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
