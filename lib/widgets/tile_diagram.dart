import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/tile_result.dart';
import 'engineering_drawing.dart';

/// Compact plan/elevation. Geometry and grout remain vector-sharp at phone width.
class TileDiagram extends StatelessWidget {
  const TileDiagram({
    super.key,
    required this.type,
    this.tileLengthMm,
    this.tileWidthMm,
    this.showOpening = true,
  });
  final TileWorkType type;
  final double? tileLengthMm;
  final double? tileWidthMm;
  final bool showOpening;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${type.label} technical tile layout, length ${type == TileWorkType.floorTiles ? 'and width' : 'and height'}${type == TileWorkType.wallTiles && showOpening ? ', with opening' : ''}',
    child: SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _TilePainter(type, tileLengthMm, tileWidthMm, showOpening),
      ),
    ),
  );
}

class _TilePainter extends CustomPainter {
  const _TilePainter(
    this.type,
    this.tileLengthMm,
    this.tileWidthMm,
    this.showOpening,
  );
  final TileWorkType type;
  final double? tileLengthMm;
  final double? tileWidthMm;
  final bool showOpening;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 320, size.height / 120);
    canvas.save();
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 120 * scale) / 2,
    );
    canvas.scale(scale);
    final surface = type == TileWorkType.skirting
        ? const Rect.fromLTRB(62, 14, 258, 85)
        : const Rect.fromLTRB(62, 15, 258, 86);
    if (type == TileWorkType.skirting) {
      // Section/elevation: hatched substrate, tiled skirting, floor datum.
      EngineeringDrawing.rect(
        canvas,
        surface,
        color: EngineeringDrawing.fillLight,
      );
      EngineeringDrawing.hatch(
        canvas,
        const Rect.fromLTRB(63, 15, 257, 64),
        spacing: 12,
      );
      EngineeringDrawing.tileGrid(
        canvas,
        const Rect.fromLTRB(62, 65, 258, 81),
        columns: 8,
        rows: 1,
      );
      EngineeringDrawing.line(
        canvas,
        const Offset(48, 85),
        const Offset(272, 85),
      );
      EngineeringDrawing.label(canvas, 'WALL', const Offset(160, 35), size: 8);
      EngineeringDrawing.label(canvas, 'FLOOR', const Offset(270, 93), size: 8);
      EngineeringDrawing.dimension(
        canvas,
        const Offset(44, 65),
        const Offset(44, 81),
        'H',
        objectFrom: const Offset(62, 65),
        objectTo: const Offset(62, 81),
        labelAt: const Offset(32, 73),
      );
    } else {
      final length = tileLengthMm;
      final width = tileWidthMm;
      final valid = length != null && width != null && length > 0 && width > 0;
      final ratio = valid ? length / width : 1.0;
      final columns = ratio >= 1.6 ? 5 : 7;
      final rows = ratio >= 1.6 ? 4 : 3;
      EngineeringDrawing.tileGrid(
        canvas,
        surface,
        columns: columns,
        rows: rows,
      );
      if (type == TileWorkType.wallTiles && showOpening) {
        // An opening is a void in the tiled wall, never a decorative tile.
        EngineeringDrawing.opening(
          canvas,
          const Rect.fromLTRB(169, 43, 205, 86),
        );
        EngineeringDrawing.label(
          canvas,
          'OPENING',
          const Offset(187, 39),
          size: 7,
        );
      }
      EngineeringDrawing.dimension(
        canvas,
        const Offset(43, 15),
        const Offset(43, 86),
        type == TileWorkType.floorTiles ? 'W' : 'H',
        objectFrom: surface.topLeft,
        objectTo: surface.bottomLeft,
        labelAt: const Offset(30, 50),
      );
    }
    EngineeringDrawing.dimension(
      canvas,
      const Offset(62, 105),
      const Offset(258, 105),
      'L',
      objectFrom: const Offset(62, 86),
      objectTo: const Offset(258, 86),
      labelAt: const Offset(160, 96),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TilePainter old) =>
      old.type != type ||
      old.tileLengthMm != tileLengthMm ||
      old.tileWidthMm != tileWidthMm ||
      old.showOpening != showOpening;
}
