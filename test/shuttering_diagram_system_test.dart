import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/screens/shuttering_calculator_screen.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/shuttering_diagram.dart';

Future<Uint8List> renderDiagram(
  WidgetTester tester,
  ShutteringType type, {
  int sides = 2,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 296,
            child: RepaintBoundary(
              key: const ValueKey('diagram-boundary'),
              child: ShutteringDiagram(type: type, wallSides: sides),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('diagram-boundary')),
  );
  final pixels = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return Uint8List.fromList(bytes!.buffer.asUint8List());
  });
  return pixels!;
}

void main() {
  final specifications = {
    ShutteringType.column: (
      'L W H',
      'four vertical formwork faces; top and bottom excluded',
    ),
    ShutteringType.beam: ('L B D', 'two side forms and soffit; top open'),
    ShutteringType.footing: (
      'L W D',
      'perimeter side formwork; top and bottom excluded',
    ),
    ShutteringType.wall: ('L H T', 'two formwork faces'),
    ShutteringType.slab: ('L W T', 'soffit formwork only; edges excluded'),
  };

  testWidgets(
    'each element has a separate painter, correct dimensions and counted faces',
    (tester) async {
      final painters = <String>{};
      final renderings = <Uint8List>[];
      for (final entry in specifications.entries) {
        renderings.add(await renderDiagram(tester, entry.key));
        final diagram = tester.widget<ShutteringDiagram>(
          find.byType(ShutteringDiagram),
        );
        expect(diagram.dimensionLabels, entry.value.$1);
        expect(diagram.countedSurfaces, entry.value.$2);
        expect(
          find.bySemanticsLabel(
            'Shuttering ${entry.key.name} dimensions ${entry.value.$1}',
          ),
          findsOneWidget,
        );
        final paint = tester.widget<CustomPaint>(find.byType(CustomPaint).last);
        painters.add(paint.painter.runtimeType.toString());
        expect(tester.takeException(), isNull);
      }
      expect(painters.length, 5);
      for (var i = 0; i < renderings.length; i++) {
        for (var j = i + 1; j < renderings.length; j++) {
          expect(renderings[i], isNot(equals(renderings[j])));
        }
      }
    },
  );

  testWidgets('wall section changes visible panels in one-side mode', (
    tester,
  ) async {
    final oneSide = await renderDiagram(tester, ShutteringType.wall, sides: 1);
    final diagram = tester.widget<ShutteringDiagram>(
      find.byType(ShutteringDiagram),
    );
    expect(diagram.countedSurfaces, 'one formwork face');
    final twoSides = await renderDiagram(tester, ShutteringType.wall, sides: 2);
    expect(
      tester
          .widget<ShutteringDiagram>(find.byType(ShutteringDiagram))
          .countedSurfaces,
      'two formwork faces',
    );
    expect(oneSide, isNot(equals(twoSides)));
  });

  for (final size in [const Size(360, 800), const Size(412, 915)]) {
    testWidgets(
      'diagram stays bounded on a ${size.width.toInt()}x${size.height.toInt()} phone',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ShutteringCalculatorScreen(type: ShutteringType.wall),
          ),
        );
        var diagram = find.byType(ShutteringDiagram);
        expect(diagram, findsOneWidget);
        expect(tester.getSize(diagram).width, lessThan(size.width));
        expect(tester.getSize(diagram).height, lessThan(190));
        await tester.ensureVisible(find.text('One Side'));
        await tester.tap(find.text('One Side'));
        await tester.pumpAndSettle();
        diagram = find.byType(ShutteringDiagram);
        expect(tester.widget<ShutteringDiagram>(diagram).wallSides, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
