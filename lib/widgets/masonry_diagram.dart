import 'package:flutter/material.dart';

import '../models/masonry_result.dart';
import 'engineering_drawing.dart';

class MasonryDiagram extends StatelessWidget {
  const MasonryDiagram({super.key, required this.type});
  final MasonryType type;

  String get dimensionLabels => switch (type) {
    MasonryType.clayBrick ||
    MasonryType.aacBlock ||
    MasonryType.concreteBlock => 'L H T',
    MasonryType.lateriteStone => 'L H T',
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Masonry ${type.name} dimensions $dimensionLabels',
    child: SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(painter: _MasonryPainter(type)),
    ),
  );
}

class _MasonryPainter extends CustomPainter {
  const _MasonryPainter(this.type);
  final MasonryType type;

  @override
  void paint(Canvas c, Size s) {
    final front = Rect.fromLTWH(
      s.width * .16,
      s.height * .19,
      s.width * .59,
      s.height * .58,
    );
    final depth = Offset(s.width * .10, -s.height * .10);
    final outline = EngineeringDrawing.stroke();
    final face = Paint()
      ..color = switch (type) {
        MasonryType.clayBrick => const Color(0xffe9c5b6),
        MasonryType.aacBlock => const Color(0xffe1e9ec),
        MasonryType.concreteBlock => const Color(0xffc5d1da),
        MasonryType.lateriteStone => const Color(0xffc9896e),
      };
    final side = Paint()
      ..color = switch (type) {
        MasonryType.clayBrick => const Color(0xffcf9b8c),
        MasonryType.aacBlock => const Color(0xffb7c8ce),
        MasonryType.concreteBlock => const Color(0xff9fb2c1),
        MasonryType.lateriteStone => const Color(0xffa86955),
      };
    c.drawRect(front, face);
    c.drawRect(front, outline);
    final sidePath = Path()
      ..addPolygon([
        front.topRight,
        front.topRight + depth,
        front.bottomRight + depth,
        front.bottomRight,
      ], true);
    c.drawPath(sidePath, side);
    c.drawPath(sidePath, outline);
    final topPath = Path()
      ..addPolygon([
        front.topLeft,
        front.topRight,
        front.topRight + depth,
        front.topLeft + depth,
      ], true);
    c.drawPath(topPath, Paint()..color = const Color(0xffedf7ff));
    c.drawPath(topPath, outline);
    _courses(c, front, outline);
    _dim(
      c,
      Offset(front.left, s.height * .91),
      Offset(front.right, s.height * .91),
      'L',
      objectA: front.bottomLeft,
      objectB: front.bottomRight,
    );
    _dim(
      c,
      Offset(front.left - s.width * .08, front.top),
      Offset(front.left - s.width * .08, front.bottom),
      'H',
      objectA: front.topLeft,
      objectB: front.bottomLeft,
    );
    _dim(
      c,
      front.topRight + const Offset(4, -4),
      front.topRight + depth + const Offset(4, -4),
      'T',
      objectA: front.topRight,
      objectB: front.topRight + depth,
    );
  }

  void _courses(Canvas c, Rect r, Paint line) {
    final rows = switch (type) {
      MasonryType.clayBrick => 6,
      MasonryType.aacBlock => 3,
      MasonryType.concreteBlock => 3,
      MasonryType.lateriteStone => 4,
    };
    final rowH = r.height / rows;
    final blocks = switch (type) {
      MasonryType.clayBrick => 7,
      MasonryType.aacBlock => 3,
      MasonryType.concreteBlock => 3,
      MasonryType.lateriteStone => 4,
    };
    for (var row = 0; row < rows; row++) {
      final y = r.top + row * rowH;
      c.drawLine(Offset(r.left, y), Offset(r.right, y), line);
      final offset = row.isEven ? 0.0 : r.width / blocks / 2;
      for (var column = 0; column <= blocks; column++) {
        final x = r.left + offset + column * r.width / blocks;
        if (x > r.left && x < r.right) {
          final wobble = type == MasonryType.lateriteStone
              ? (row.isEven ? 2.0 : -2.0)
              : 0.0;
          c.drawLine(Offset(x, y), Offset(x + wobble, y + rowH), line);
        }
      }
    }
    c.drawLine(Offset(r.left, r.bottom), Offset(r.right, r.bottom), line);
  }

  void _dim(
    Canvas c,
    Offset a,
    Offset b,
    String label, {
    required Offset objectA,
    required Offset objectB,
  }) => EngineeringDrawing.dimension(
    c,
    a,
    b,
    label,
    objectFrom: objectA,
    objectTo: objectB,
    labelAt: label == 'H'
        ? Offset(a.dx - 10, (a.dy + b.dy) / 2)
        : label == 'T'
        ? (a + b) / 2 + const Offset(0, -9)
        : (a + b) / 2 + const Offset(0, -9),
  );
  @override
  bool shouldRepaint(covariant _MasonryPainter old) => old.type != type;
}
