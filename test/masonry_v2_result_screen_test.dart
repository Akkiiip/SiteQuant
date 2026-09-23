import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/masonry_input.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/services/masonry_reference_defaults.dart';
import 'package:site_quant/services/masonry_v2_calculator.dart';
import 'package:site_quant/screens/masonry_v2_result_screen.dart';

void main() {
  testWidgets('result has concise labour and collapsed details', (
    tester,
  ) async {
    final p = MasonryReferenceDefaults.forType(MasonryType.clayBrick);
    final r = MasonryV2Calculator.calculate(
      MasonryInput(
        type: MasonryType.clayBrick,
        grossArea: 10,
        thicknessMm: p.thicknessMm,
        unitSize: p.unitSize,
        cementPart: 1,
        sandPart: 6,
        wastagePercent: p.wastagePercent,
        unitRate: p.unitRate,
        cementRatePerBag: p.cementRatePerBag,
        sandRatePerM3: p.sandRatePerM3,
        masonDaysPerM3: p.masonDaysPerM3,
        helperDaysPerM3: p.helperDaysPerM3,
        masonDailyWage: p.masonWage,
        helperDailyWage: p.helperWage,
        masons: 1,
        helpers: 1,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MasonryV2ResultScreen(result: r)),
    );
    await tester.scrollUntilVisible(find.text('LABOUR & TIME'), 180);
    expect(find.text('LABOUR & TIME'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Calculation Details'), 180);
    expect(find.text('Calculation Details'), findsOneWidget);
    expect(find.text('Mason mandays'), findsNothing);
  });
}
