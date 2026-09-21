import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/screens/shuttering_screen.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/shuttering_diagram.dart';

void main() {
  testWidgets(
    'shuttering selector renders types, selection and diagrams at phone width',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const ShutteringScreen()),
      );

      final list = find.byType(ListView);
      expect(list, findsOneWidget);
      expect(find.text('Column'), findsOneWidget);
      expect(find.byType(ShutteringDiagram), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('shuttering-beam')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Footing'), findsOneWidget);
      expect(find.text('Wall'), findsOneWidget);

      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Slab'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every diagram painter renders at a bounded size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            for (final type in ShutteringType.values)
              SizedBox(
                width: 120,
                height: 70,
                child: ShutteringDiagram(type: type),
              ),
          ],
        ),
      ),
    );
    expect(find.byType(ShutteringDiagram), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
