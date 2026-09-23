import 'package:flutter/material.dart';

import '../models/shuttering_result.dart';
import 'engineering_drawing.dart';

/// Presentation-only engineering views of the surfaces used in shuttering area.
class ShutteringDiagram extends StatelessWidget {
  const ShutteringDiagram({super.key, required this.type, this.wallSides = 2});

  final ShutteringType type;
  final int wallSides;

  String get dimensionLabels => switch (type) {
    ShutteringType.column => 'L W H',
    ShutteringType.beam => 'L B D',
    ShutteringType.footing => 'L W D',
    ShutteringType.wall => 'L H T',
    ShutteringType.slab => 'L W T',
  };

  String get countedSurfaces => switch (type) {
    ShutteringType.column =>
      'four vertical formwork faces; top and bottom excluded',
    ShutteringType.beam => 'two side forms and soffit; top open',
    ShutteringType.footing =>
      'perimeter side formwork; top and bottom excluded',
    ShutteringType.wall =>
      wallSides == 1 ? 'one formwork face' : 'two formwork faces',
    ShutteringType.slab => 'soffit formwork only; edges excluded',
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Shuttering ${type.name} dimensions $dimensionLabels',
    hint: countedSurfaces,
    child: AspectRatio(
      aspectRatio: 2.1,
      child: CustomPaint(
        painter: switch (type) {
          ShutteringType.column => const _ColumnFormworkPainter(),
          ShutteringType.beam => const _BeamFormworkPainter(),
          ShutteringType.footing => const _FootingFormworkPainter(),
          ShutteringType.wall => _WallFormworkPainter(wallSides),
          ShutteringType.slab => const _SlabFormworkPainter(),
        },
      ),
    ),
  );
}

/// Shared drafting primitives; each element below owns its own geometry.
abstract class _FormworkPainter extends CustomPainter {
  const _FormworkPainter();
  static const ink = EngineeringDrawing.ink;
  static const rccColor = EngineeringDrawing.fill;
  static const formColor = EngineeringDrawing.accent;
  static const formLight = EngineeringDrawing.fillDark;
  Paint get stroke => Paint()
    ..color = ink
    ..strokeWidth = 1.15
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 150);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 320, 150),
      Paint()..color = Colors.white,
    );
    draw(canvas);
    canvas.restore();
  }

  void draw(Canvas canvas);

  void rcc(Canvas c, Rect r) {
    c.drawRect(r, Paint()..color = rccColor);
    c.drawRect(r, stroke);
  }

  void panel(Canvas c, Rect r, {bool light = false}) {
    c.drawRect(r, Paint()..color = light ? formLight : formColor);
    c.drawRect(r, stroke);
  }

  void rule(Canvas c, Offset a, Offset b, {bool dashed = false}) {
    if (!dashed) {
      c.drawLine(a, b, stroke);
      return;
    }
    final v = b - a;
    final u = v / v.distance;
    for (double t = 0; t < v.distance; t += 6) {
      c.drawLine(a + u * t, a + u * (t + 3).clamp(0, v.distance), stroke);
    }
  }

  void text(
    Canvas c,
    String value,
    Offset center, {
    double size = 9.5,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: ink,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void arrow(Canvas c, Offset tip, Offset toward) {
    final u = (toward - tip) / (toward - tip).distance;
    final n = Offset(-u.dy, u.dx);
    rule(c, tip, tip + u * 5 + n * 2.5);
    rule(c, tip, tip + u * 5 - n * 2.5);
  }

  void horizontalDimension(
    Canvas c,
    double left,
    double right,
    double y,
    double objectY,
    String value,
  ) {
    rule(
      c,
      Offset(left, objectY + (y > objectY ? 2 : -2)),
      Offset(left, y + (y > objectY ? 3 : -3)),
    );
    rule(
      c,
      Offset(right, objectY + (y > objectY ? 2 : -2)),
      Offset(right, y + (y > objectY ? 3 : -3)),
    );
    final a = Offset(left, y), b = Offset(right, y);
    rule(c, a, b);
    arrow(c, a, b);
    arrow(c, b, a);
    text(c, value, Offset((left + right) / 2, y - 8), size: 10.5, bold: true);
  }

  void verticalDimension(
    Canvas c,
    double x,
    double top,
    double bottom,
    double objectX,
    String value,
  ) {
    rule(
      c,
      Offset(objectX + (x > objectX ? 2 : -2), top),
      Offset(x + (x > objectX ? 3 : -3), top),
    );
    rule(
      c,
      Offset(objectX + (x > objectX ? 2 : -2), bottom),
      Offset(x + (x > objectX ? 3 : -3), bottom),
    );
    final a = Offset(x, top), b = Offset(x, bottom);
    rule(c, a, b);
    arrow(c, a, b);
    arrow(c, b, a);
    text(
      c,
      value,
      Offset(x < objectX ? x - 8 : x + 8, (top + bottom) / 2),
      size: 10.5,
      bold: true,
    );
  }

  void caption(Canvas c, String value, double x) =>
      text(c, value, Offset(x, 16), size: 9, bold: true);

  void legend(Canvas c, {double x = 198}) {
    panel(c, Rect.fromLTWH(x, 133, 9, 7));
    text(c, 'FORMWORK', Offset(x + 47, 136.5), size: 8);
    rcc(c, Rect.fromLTWH(x + 89, 133, 9, 7));
    text(c, 'RCC', Offset(x + 115, 136.5), size: 8);
  }

  @override
  bool shouldRepaint(covariant _FormworkPainter oldDelegate) =>
      runtimeType != oldDelegate.runtimeType;
}

/// Plan: four surrounding panels. Elevation: vertical panels and height.
class _ColumnFormworkPainter extends _FormworkPainter {
  const _ColumnFormworkPainter();
  @override
  void draw(Canvas c) {
    caption(c, 'PLAN · 4 SIDES', 76);
    caption(c, 'ELEVATION', 228);
    rcc(c, const Rect.fromLTWH(45, 49, 54, 48));
    panel(c, const Rect.fromLTWH(40, 44, 64, 5));
    panel(c, const Rect.fromLTWH(40, 97, 64, 5));
    panel(c, const Rect.fromLTWH(40, 49, 5, 48));
    panel(c, const Rect.fromLTWH(99, 49, 5, 48));
    horizontalDimension(c, 40, 104, 124, 102, 'L');
    verticalDimension(c, 23, 44, 102, 40, 'W');
    rcc(c, const Rect.fromLTWH(204, 39, 48, 69));
    panel(c, const Rect.fromLTWH(198, 39, 6, 69));
    panel(c, const Rect.fromLTWH(252, 39, 6, 69));
    for (final y in [49.0, 73.0, 97.0]) {
      rule(c, Offset(195, y), Offset(261, y));
    }
    verticalDimension(c, 283, 39, 108, 258, 'H');
    legend(c, x: 174);
  }
}

/// A long side/soffit view plus an open-top section with both side panels.
class _BeamFormworkPainter extends _FormworkPainter {
  const _BeamFormworkPainter();
  @override
  void draw(Canvas c) {
    caption(c, 'LONGITUDINAL SECTION', 103);
    caption(c, 'CROSS SECTION', 261);
    horizontalDimension(c, 22, 184, 39, 56, 'L');
    rcc(c, const Rect.fromLTWH(22, 56, 162, 35));
    panel(c, const Rect.fromLTWH(22, 60, 162, 31), light: true);
    panel(c, const Rect.fromLTWH(22, 91, 162, 6));
    for (final x in [58.0, 148.0]) {
      rule(c, Offset(x - 10, 98), Offset(x + 10, 98));
      rule(c, Offset(x, 98), Offset(x, 122));
      rule(c, Offset(x - 10, 122), Offset(x + 10, 122));
    }
    rcc(c, const Rect.fromLTWH(244, 55, 40, 38));
    panel(c, const Rect.fromLTWH(237, 55, 7, 44));
    panel(c, const Rect.fromLTWH(284, 55, 7, 44));
    panel(c, const Rect.fromLTWH(237, 93, 54, 6));
    horizontalDimension(c, 244, 284, 43, 55, 'B');
    verticalDimension(c, 220, 55, 93, 237, 'D');
    text(c, 'OPEN TOP', const Offset(264, 107), size: 8);
    legend(c, x: 174);
  }
}

/// Footing perimeter is paneled in plan; elevation leaves top/base unshuttered.
class _FootingFormworkPainter extends _FormworkPainter {
  const _FootingFormworkPainter();
  @override
  void draw(Canvas c) {
    caption(c, 'PLAN · PERIMETER', 87);
    caption(c, 'ELEVATION', 247);
    rcc(c, const Rect.fromLTWH(43, 45, 91, 53));
    panel(c, const Rect.fromLTWH(38, 40, 101, 5));
    panel(c, const Rect.fromLTWH(38, 98, 101, 5));
    panel(c, const Rect.fromLTWH(38, 45, 5, 53));
    panel(c, const Rect.fromLTWH(134, 45, 5, 53));
    rcc(c, const Rect.fromLTWH(80, 58, 17, 24));
    horizontalDimension(c, 38, 139, 124, 103, 'L');
    verticalDimension(c, 22, 40, 103, 38, 'W');
    rcc(c, const Rect.fromLTWH(207, 70, 83, 27));
    rcc(c, const Rect.fromLTWH(241, 41, 16, 29));
    panel(c, const Rect.fromLTWH(201, 70, 6, 27));
    panel(c, const Rect.fromLTWH(290, 70, 6, 27));
    rule(c, const Offset(193, 104), const Offset(304, 104));
    verticalDimension(c, 309, 70, 97, 296, 'D');
    legend(c, x: 174);
  }
}

/// Elevation sizes the wall; the section changes from one to two blue faces.
class _WallFormworkPainter extends _FormworkPainter {
  const _WallFormworkPainter(this.sides);
  final int sides;
  @override
  void draw(Canvas c) {
    caption(c, 'ELEVATION', 105);
    caption(c, 'SECTION', 254);
    rcc(c, const Rect.fromLTWH(37, 41, 148, 60));
    panel(c, const Rect.fromLTWH(37, 41, 148, 60), light: true);
    for (final x in [74.0, 111.0, 148.0]) {
      rule(c, Offset(x, 41), Offset(x, 101));
    }
    horizontalDimension(c, 37, 185, 124, 101, 'L');
    verticalDimension(c, 21, 41, 101, 37, 'H');
    rcc(c, const Rect.fromLTWH(239, 48, 31, 53));
    panel(c, const Rect.fromLTWH(232, 48, 7, 53));
    if (sides == 2) {
      panel(c, const Rect.fromLTWH(270, 48, 7, 53));
    }
    horizontalDimension(c, 239, 270, 36, 48, 'T');
    text(
      c,
      sides == 1 ? '1 FACE' : '2 FACES',
      const Offset(254, 116),
      size: 9,
      bold: true,
    );
    legend(c, x: 174);
  }

  @override
  bool shouldRepaint(covariant _FormworkPainter oldDelegate) =>
      oldDelegate is! _WallFormworkPainter || oldDelegate.sides != sides;
}

/// Plan gives L/W; section colors only the underside, supported by props.
class _SlabFormworkPainter extends _FormworkPainter {
  const _SlabFormworkPainter();
  @override
  void draw(Canvas c) {
    caption(c, 'PLAN', 89);
    caption(c, 'SECTION · SOFFIT', 247);
    rcc(c, const Rect.fromLTWH(43, 43, 101, 55));
    horizontalDimension(c, 43, 144, 120, 98, 'L');
    verticalDimension(c, 23, 43, 98, 43, 'W');
    rcc(c, const Rect.fromLTWH(201, 53, 91, 16));
    panel(c, const Rect.fromLTWH(201, 69, 91, 7));
    for (final x in [225.0, 269.0]) {
      rule(c, Offset(x - 11, 77), Offset(x + 11, 77));
      rule(c, Offset(x, 77), Offset(x, 113));
      rule(c, Offset(x - 10, 113), Offset(x + 10, 113));
    }
    verticalDimension(c, 307, 53, 69, 292, 'T');
    legend(c, x: 174);
  }
}
