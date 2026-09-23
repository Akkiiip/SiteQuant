import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/widgets/engineering_drawing.dart';
import 'package:site_quant/widgets/sitequant_calculator_icon.dart';
import 'package:site_quant/widgets/tile_diagram.dart';

Future<Uint8List> _pixels(
  WidgetTester tester,
  TileWorkType type, {
  bool opening = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 296,
            child: RepaintBoundary(
              key: const ValueKey('drawing'),
              child: TileDiagram(type: type, showOpening: opening),
            ),
          ),
        ),
      ),
    ),
  );
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('drawing')),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return Uint8List.fromList(data!.buffer.asUint8List());
  });
  return bytes!;
}

void main() {
  testWidgets(
    'tile work types have distinct technical drawings and opening changes wall',
    (tester) async {
      final floor = await _pixels(tester, TileWorkType.floorTiles);
      final wall = await _pixels(tester, TileWorkType.wallTiles);
      final plainWall = await _pixels(
        tester,
        TileWorkType.wallTiles,
        opening: false,
      );
      final skirting = await _pixels(tester, TileWorkType.skirting);
      expect(floor, isNot(equals(wall)));
      expect(wall, isNot(equals(plainWall)));
      expect(skirting, isNot(equals(floor)));
      expect(
        find.bySemanticsLabel(
          'Skirting technical tile layout, length and height',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tile diagram and icon stay bounded at narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 280,
                child: TileDiagram(
                  type: TileWorkType.floorTiles,
                  tileLengthMm: 600,
                  tileWidthMm: 1200,
                ),
              ),
              SiteQuantCalculatorIcon(kind: CalculatorArtwork.tiles),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(TileDiagram)).height, 120);
    expect(tester.getSize(find.byType(TileDiagram)).width, 280);
    expect(tester.getSize(find.byType(SiteQuantCalculatorIcon)).width, 36);
    expect(tester.takeException(), isNull);
  });

  test(
    'shared technical palette uses restrained distinct line and fill colours',
    () {
      expect(EngineeringDrawing.ink, isNot(EngineeringDrawing.fill));
      expect(EngineeringDrawing.strokeWidth, lessThan(1.5));
    },
  );
}
