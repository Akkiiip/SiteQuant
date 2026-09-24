import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/screens/masonry_calculator_screen.dart';

void main() {
  testWidgets(
    'calculator supports direct area, openings and editable settings',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(
          home: MasonryCalculatorScreen(type: MasonryType.clayBrick),
        ),
      );

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Wall area')), findsOneWidget);

      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -520));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add opening'));
      await tester.pumpAndSettle();
      expect(find.text('Opening 1'), findsOneWidget);
      expect(find.text('Opening width'), findsOneWidget);
      expect(find.text('Opening height'), findsOneWidget);
      expect(find.text('Opening quantity'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Opening width'),
        '1.2',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Opening height'),
        '2.1',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Opening quantity'),
        '2',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Remove opening 1'));
      await tester.pumpAndSettle();
      expect(find.text('Opening 1'), findsNothing);

      await tester.drag(scroll, const Offset(0, -520));
      await tester.pumpAndSettle();
      expect(find.text('Advanced Options'), findsOneWidget);
      await tester.tap(find.text('Advanced Options'));
      await tester.pumpAndSettle();
      expect(find.text('Reference values — editable'), findsOneWidget);
      expect(find.textContaining('Estimating defaults only'), findsOneWidget);
      expect(find.byKey(const Key('Material rate')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('Material rate')), '25');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
