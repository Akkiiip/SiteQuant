import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/screens/app_shell.dart';
import 'package:site_quant/screens/tile_calculator_screen.dart';
import 'package:site_quant/screens/tile_screen.dart';
import 'package:site_quant/widgets/sitequant_calculator_icon.dart';

void main() {
  testWidgets('Home has Tiles, not Steel; browser retains both', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
    expect(find.byKey(const ValueKey('home-calculator-tiles')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-calculator-steel')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-calculator-tiles')));
    await tester.pumpAndSettle();
    expect(find.byType(TileScreen), findsOneWidget);
    await tester.tap(find.text('Floor Tiles').first);
    await tester.pumpAndSettle();
    expect(find.byType(TileCalculatorScreen), findsOneWidget);
    expect(
      tester
          .widget<TileCalculatorScreen>(find.byType(TileCalculatorScreen))
          .type,
      TileWorkType.floorTiles,
    );
    Navigator.of(tester.element(find.byType(TileCalculatorScreen))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(TileScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculators').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Tiles');
    await tester.pumpAndSettle();
    expect(find.text('Tiles & Flooring'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Steel');
    await tester.pumpAndSettle();
    expect(find.text('Steel Weight Calculator'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Tiles icon is a dedicated mapped artwork', () {
    expect(
      SiteQuantCalculatorIcon.kindFor('Tiles & Flooring'),
      CalculatorArtwork.tiles,
    );
    expect(
      SiteQuantCalculatorIcon.kindFor('Steel Weight Calculator'),
      CalculatorArtwork.steel,
    );
  });
}
