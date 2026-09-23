import 'package:flutter/material.dart';
import '../models/water_tank_input.dart';
import 'engineering_drawing.dart';

class WaterTankDiagram extends StatelessWidget {
  const WaterTankDiagram({super.key, required this.type});
  final WaterTankType type;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${type.name} water tank diagram with internal dimensions, wall thickness, base slab and top slab',
    child: AspectRatio(
      aspectRatio: 2,
      child: CustomPaint(painter: _WaterTankPainter(type)),
    ),
  );
}

class _WaterTankPainter extends CustomPainter {
  const _WaterTankPainter(this.type);
  final WaterTankType type;
  static const rcc = EngineeringDrawing.fillDark, water = Color(0x5572a7e8);
  Paint get line => EngineeringDrawing.stroke();
  void text(Canvas c, String label, Offset center) =>
      EngineeringDrawing.label(c, label, center, size: 10);

  void dimension(
    Canvas c,
    Offset a,
    Offset b,
    String label,
    Offset at, {
    Offset? ea,
    Offset? eb,
  }) => EngineeringDrawing.dimension(
    c,
    a,
    b,
    label,
    objectFrom: ea ?? a,
    objectTo: eb ?? b,
    labelAt: at,
  );
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    if (type == WaterTankType.rectangular) {
      final outer = Rect.fromLTWH(w * .25, h * .23, w * .46, h * .54);
      final inner = Rect.fromLTWH(
        outer.left + 10,
        outer.top + 9,
        outer.width - 20,
        outer.height - 20,
      );
      c.drawRect(outer, Paint()..color = rcc);
      c.drawRect(inner, Paint()..color = Colors.white);
      c.drawRect(
        Rect.fromLTRB(
          inner.left,
          inner.top + h * .22,
          inner.right,
          inner.bottom,
        ),
        Paint()..color = water,
      );
      c.drawRect(outer, line);
      c.drawRect(inner, line);
      dimension(
        c,
        Offset(inner.left, h * .86),
        Offset(inner.right, h * .86),
        'Internal L',
        Offset(w * .48, h * .93),
        ea: inner.bottomLeft,
        eb: inner.bottomRight,
      );
      dimension(
        c,
        Offset(w * .79, inner.top),
        Offset(w * .79, inner.bottom),
        'Internal H',
        Offset(w * .88, h * .49),
        ea: inner.topRight,
        eb: inner.bottomRight,
      );
      dimension(
        c,
        Offset(outer.left, h * .15),
        Offset(inner.left, h * .15),
        'T',
        Offset(w * .26, h * .08),
        ea: outer.topLeft,
        eb: inner.topLeft,
      );
      text(c, 'Top slab', Offset(w * .49, h * .19));
      text(c, 'Base slab', Offset(w * .49, h * .81));
      text(c, 'Internal W', Offset(w * .49, h * .51));
    } else {
      final cx = w * .49,
          rx = w * .20,
          topY = h * .26,
          bottomY = h * .74,
          ry = h * .075;
      c.drawRect(
        Rect.fromLTRB(cx - rx, topY, cx + rx, bottomY),
        Paint()..color = rcc,
      );
      c.drawRect(
        Rect.fromLTRB(cx - rx + 9, topY + 8, cx + rx - 9, bottomY - 9),
        Paint()..color = Colors.white,
      );
      c.drawRect(
        Rect.fromLTRB(cx - rx + 9, h * .48, cx + rx - 9, bottomY - 9),
        Paint()..color = water,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(cx, topY),
          width: rx * 2,
          height: ry * 2,
        ),
        Paint()..color = rcc,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(cx, topY),
          width: rx * 2 - 18,
          height: ry * 2 - 7,
        ),
        Paint()..color = Colors.white,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(cx, topY),
          width: rx * 2,
          height: ry * 2,
        ),
        line,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(cx, bottomY),
          width: rx * 2,
          height: ry * 2,
        ),
        line,
      );
      c.drawLine(Offset(cx - rx, topY), Offset(cx - rx, bottomY), line);
      c.drawLine(Offset(cx + rx, topY), Offset(cx + rx, bottomY), line);
      dimension(
        c,
        Offset(cx - rx + 9, h * .13),
        Offset(cx + rx - 9, h * .13),
        'Internal D',
        Offset(cx, h * .06),
        ea: Offset(cx - rx + 9, topY),
        eb: Offset(cx + rx - 9, topY),
      );
      dimension(
        c,
        Offset(cx + rx + 24, topY + 8),
        Offset(cx + rx + 24, bottomY - 9),
        'Internal H',
        Offset(cx + rx + 44, h * .51),
        ea: Offset(cx + rx, topY),
        eb: Offset(cx + rx, bottomY),
      );
      dimension(
        c,
        Offset(cx - rx, h * .85),
        Offset(cx - rx + 9, h * .85),
        'T',
        Offset(cx - rx + 5, h * .93),
      );
      text(c, 'Top slab', Offset(cx, h * .23));
      text(c, 'Base slab', Offset(cx, h * .78));
    }
  }

  @override
  bool shouldRepaint(covariant _WaterTankPainter old) => old.type != type;
}
