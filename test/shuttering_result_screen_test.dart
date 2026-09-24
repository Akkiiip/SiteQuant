import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/services/shuttering_calculator.dart';
import 'package:site_quant/screens/shuttering_result_screen.dart';
import 'package:site_quant/theme/app_theme.dart';

void main() {
  testWidgets(
    'metric summary and concise labour details expand and collapse at 360 px',
    (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final r = ShutteringCalculator.calculate(
        type: ShutteringType.column,
        length: 1,
        width: 1,
        height: 3,
        quantity: 1,
        materialRate: 100,
        wastagePercent: 5,
        carpenterDaysPer10M2: 1.2,
        helperDaysPer10M2: .9,
        crew: {LabourRole.carpenter: 1, LabourRole.helper: 1},
        dailyWages: {LabourRole.carpenter: 1000, LabourRole.helper: 650},
      );
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ShutteringResultScreen(result: r),
        ),
      );
      for (final label in [
        'Contact Area',
        'Material / Panel Area',
        'Material Cost',
        'Labour Cost',
        'Total Cost',
        'Cost / m²',
        'Crew',
        'Working Days',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text('Carpenter mandays'), findsNothing);
      final title = find.text('Calculation Details');
      await t.ensureVisible(title);
      await t.tap(title);
      await t.pumpAndSettle();
      expect(find.text('Carpenter mandays'), findsOneWidget);
      expect(find.text('Controlling role'), findsOneWidget);
      await t.ensureVisible(title);
      await t.tap(title);
      await t.pumpAndSettle();
      expect(find.text('Carpenter mandays'), findsNothing);
      await t.ensureVisible(find.text('Edit Calculation'));
      expect(find.text('Edit Calculation'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
