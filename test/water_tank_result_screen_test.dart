import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/water_tank_input.dart';
import 'package:site_quant/screens/water_tank_result_screen.dart';
import 'package:site_quant/services/water_tank_calculator.dart';
import 'package:site_quant/theme/app_theme.dart';

void main() {
  testWidgets(
    'result has concise summary and expandable RCC/details at phone width',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final result = WaterTankCalculator.calculate(
        WaterTankInput(
          type: WaterTankType.rectangular,
          internalLength: 4,
          internalWidthOrDiameter: 3,
          waterDepth: 2,
          wallThickness: .2,
          baseSlabThickness: .25,
          topSlabThickness: .15,
          quantity: 1,
          rccRatePerCubicMetre: 100,
          masonDaysPerCubicMetre: 1.2,
          helperDaysPerCubicMetre: 1.5,
          crew: {LabourRole.mason: 1, LabourRole.helper: 1},
          dailyWages: {LabourRole.mason: 900, LabourRole.helper: 650},
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: WaterTankResultScreen(result: result),
        ),
      );
      for (final label in [
        'RCC Quantity',
        'Material Cost',
        'Labour Cost',
        'Total Cost',
        'Cost / m³',
        'Crew',
        'Working Days',
        'RCC Breakdown',
        'Calculation Details',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('Base Slab'), findsNothing);
      await tester.ensureVisible(find.text('RCC Breakdown'));
      await tester.tap(find.text('RCC Breakdown'));
      await tester.pumpAndSettle();
      expect(find.text('Base Slab'), findsOneWidget);
      await tester.ensureVisible(find.text('Calculation Details'));
      await tester.tap(find.text('Calculation Details'));
      await tester.pumpAndSettle();
      expect(find.text('Mason mandays'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
