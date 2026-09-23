import 'package:flutter/material.dart';
import 'engineering_drawing.dart';

/// Presentation-only schematic; the selected calculator shape owns the geometry.
class GeometryDiagram extends StatelessWidget {
  const GeometryDiagram({super.key, required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$kind engineering diagram',
    child: SizedBox(
      height: 142,
      width: double.infinity,
      child: CustomPaint(painter: _GeometryPainter(kind)),
    ),
  );
}

class _GeometryPainter extends CustomPainter {
  const _GeometryPainter(this.kind);
  final String kind;
  static const top = EngineeringDrawing.fillLight;
  static const front = EngineeringDrawing.fill;
  static const side = EngineeringDrawing.fillDark;

  Paint get line => EngineeringDrawing.stroke();

  void face(Canvas c, List<Offset> points, Color fill) =>
      EngineeringDrawing.face(c, points, color: fill);

  void dimension(
    Canvas c,
    Offset a,
    Offset b,
    String value, {
    Offset? extA,
    Offset? extB,
    Offset? textAt,
  }) => EngineeringDrawing.dimension(
    c,
    a,
    b,
    value,
    objectFrom: extA ?? a,
    objectTo: extB ?? b,
    labelAt: textAt,
  );
  @override
  void paint(Canvas c, Size s) {
    switch (kind) {
      case 'Cuboid':
        _cuboid(c, s);
      case 'Cylinder':
        _cylinder(c, s);
      case 'Cone':
        _cone(c, s);
      case 'Sphere':
        _sphere(c, s);
      case 'Rectangular':
        _excavation(c, s, trench: false);
      case 'Trench':
        _excavation(c, s, trench: true);
      case 'Circular Pit':
        _circularPit(c, s);
    }
  }

  void _cuboid(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final a = Offset(w * .24, h * .38),
        b = Offset(w * .65, h * .38),
        e = Offset(w * .12, -h * .10);
    final d = a + e;
    face(c, [a, b, b + e, d], top);
    face(c, [a, b, b + Offset(0, h * .33), a + Offset(0, h * .33)], front);
    face(c, [
      b,
      b + e,
      b + e + Offset(0, h * .33),
      b + Offset(0, h * .33),
    ], side);
    dimension(
      c,
      Offset(a.dx, h * .85),
      Offset(b.dx, h * .85),
      'L',
      extA: a + Offset(0, h * .33),
      extB: b + Offset(0, h * .33),
    );
    dimension(
      c,
      b + Offset(9, -9),
      b + e + Offset(9, -9),
      'W',
      extA: b,
      extB: b + e,
      textAt: Offset(w * .76, h * .19),
    );
    dimension(
      c,
      a + Offset(-20, 0),
      a + Offset(-20, h * .33),
      'H',
      extA: a,
      extB: a + Offset(0, h * .33),
      textAt: Offset(w * .14, h * .53),
    );
  }

  void _cylinder(Canvas c, Size s) {
    final w = s.width,
        h = s.height,
        cx = w * .48,
        rx = w * .20,
        topY = h * .28,
        bottomY = h * .70,
        ry = h * .10;
    c.drawRect(
      Rect.fromLTRB(cx - rx, topY, cx + rx, bottomY),
      Paint()..color = front,
    );
    c.drawLine(Offset(cx - rx, topY), Offset(cx - rx, bottomY), line);
    c.drawLine(Offset(cx + rx, topY), Offset(cx + rx, bottomY), line);
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottomY),
        width: rx * 2,
        height: ry * 2,
      ),
      line,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      Paint()..color = top,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      line,
    );
    dimension(
      c,
      Offset(cx - rx, h * .10),
      Offset(cx + rx, h * .10),
      'D',
      extA: Offset(cx - rx, topY),
      extB: Offset(cx + rx, topY),
    );
    dimension(
      c,
      Offset(cx + rx + 22, topY),
      Offset(cx + rx + 22, bottomY),
      'H',
      extA: Offset(cx + rx, topY),
      extB: Offset(cx + rx, bottomY),
      textAt: Offset(cx + rx + 32, h * .50),
    );
  }

  void _cone(Canvas c, Size s) {
    final w = s.width,
        h = s.height,
        cx = w * .48,
        rx = w * .23,
        apex = Offset(cx, h * .17),
        baseY = h * .72,
        ry = h * .10;
    final body = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(cx - rx, baseY)
      ..quadraticBezierTo(cx, baseY + ry, cx + rx, baseY)
      ..close();
    c.drawPath(body, Paint()..color = front);
    c.drawPath(body, line);
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, baseY), width: rx * 2, height: ry * 2),
      line,
    );
    dimension(
      c,
      Offset(cx - rx, h * .88),
      Offset(cx + rx, h * .88),
      'D',
      extA: Offset(cx - rx, baseY),
      extB: Offset(cx + rx, baseY),
      textAt: Offset(cx, h * .96),
    );
    dimension(
      c,
      Offset(cx + rx + 22, apex.dy),
      Offset(cx + rx + 22, baseY),
      'H',
      extA: apex,
      extB: Offset(cx + rx, baseY),
      textAt: Offset(cx + rx + 33, h * .45),
    );
  }

  void _sphere(Canvas c, Size s) {
    final center = Offset(s.width * .50, s.height * .50),
        radius = s.height * .34;
    c.drawCircle(center, radius, Paint()..color = front);
    c.drawCircle(center, radius, line);
    c.drawArc(
      Rect.fromCircle(center: center, radius: radius * .92),
      -.25,
      .5,
      false,
      line,
    );
    dimension(
      c,
      Offset(center.dx - radius, s.height * .91),
      Offset(center.dx + radius, s.height * .91),
      'D',
      extA: Offset(center.dx - radius, center.dy),
      extB: Offset(center.dx + radius, center.dy),
      textAt: Offset(center.dx, s.height * .98),
    );
  }

  void _excavation(Canvas c, Size s, {required bool trench}) {
    final w = s.width, h = s.height;
    final left = w * (trench ? .13 : .22),
        right = w * (trench ? .77 : .66),
        y = h * .31,
        depth = h * .34;
    final skew = Offset(w * (trench ? .13 : .17), -h * (trench ? .08 : .15));
    final a = Offset(left, y), b = Offset(right, y);
    face(c, [a, b, b + skew, a + skew], top);
    face(c, [
      a,
      a + Offset(0, depth),
      b + Offset(0, depth),
      b,
    ], const Color(0xffd6e3ee));
    face(c, [
      b,
      b + Offset(0, depth),
      b + skew + Offset(0, depth),
      b + skew,
    ], side);
    c.drawLine(a + Offset(0, depth), b + Offset(0, depth), line);
    dimension(
      c,
      Offset(left, h * .85),
      Offset(right, h * .85),
      'L',
      extA: a + Offset(0, depth),
      extB: b + Offset(0, depth),
    );
    dimension(
      c,
      b + Offset(8, -8),
      b + skew + Offset(8, -8),
      'W',
      extA: b,
      extB: b + skew,
      textAt: Offset(right + skew.dx / 2 + 14, h * .14),
    );
    dimension(
      c,
      a + Offset(-20, 0),
      a + Offset(-20, depth),
      'D',
      extA: a,
      extB: a + Offset(0, depth),
      textAt: Offset(left - 31, y + depth / 2),
    );
  }

  void _circularPit(Canvas c, Size s) {
    final w = s.width,
        h = s.height,
        cx = w * .49,
        rx = w * .21,
        topY = h * .29,
        bottomY = h * .69,
        ry = h * .10;
    c.drawRect(
      Rect.fromLTRB(cx - rx, topY, cx + rx, bottomY),
      Paint()..color = front,
    );
    c.drawLine(Offset(cx - rx, topY), Offset(cx - rx, bottomY), line);
    c.drawLine(Offset(cx + rx, topY), Offset(cx + rx, bottomY), line);
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bottomY),
        width: rx * 2,
        height: ry * 2,
      ),
      line,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.white,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: rx * 2, height: ry * 2),
      line,
    );
    dimension(
      c,
      Offset(cx - rx, h * .10),
      Offset(cx + rx, h * .10),
      'D',
      extA: Offset(cx - rx, topY),
      extB: Offset(cx + rx, topY),
    );
    dimension(
      c,
      Offset(cx + rx + 22, topY),
      Offset(cx + rx + 22, bottomY),
      'Depth',
      extA: Offset(cx + rx, topY),
      extB: Offset(cx + rx, bottomY),
      textAt: Offset(cx + rx + 42, h * .51),
    );
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter old) => old.kind != kind;
}
