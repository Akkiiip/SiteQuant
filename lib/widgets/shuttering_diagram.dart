import 'package:flutter/material.dart';

import '../models/shuttering_result.dart';

/// Offline engineering schematic for the Shuttering selector and input screens.
class ShutteringDiagram extends StatelessWidget {
  const ShutteringDiagram({super.key, required this.type});

  final ShutteringType type;

  String get dimensionLabels => switch (type) {
    ShutteringType.column => 'L W H',
    ShutteringType.beam => 'L B D',
    ShutteringType.footing => 'L W D',
    ShutteringType.wall => 'L H T',
    ShutteringType.slab => 'L W T',
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Shuttering ${type.name} dimensions $dimensionLabels',
    child: AspectRatio(
      aspectRatio: 2.1,
      child: CustomPaint(painter: _ShutteringPainter(type)),
    ),
  );
}

class _ShutteringPainter extends CustomPainter {
  const _ShutteringPainter(this.type);

  final ShutteringType type;

  static const _ink = Color(0xff0d47a1);
  static const _front = Color(0xff64b5f6);
  static const _side = Color(0xff1e88e5);
  static const _top = Color(0xffbbdefb);
  static const _shutter = Color(0xff1565c0);

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ShutteringType.column:
        _column(canvas, size);
      case ShutteringType.beam:
        _beam(canvas, size);
      case ShutteringType.footing:
        _footing(canvas, size);
      case ShutteringType.wall:
        _wall(canvas, size);
      case ShutteringType.slab:
        _slab(canvas, size);
    }
  }

  Paint _fill(Color color) => Paint()..color = color;
  Paint get _line => Paint()
    ..color = _ink
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  void _face(Canvas c, List<Offset> points, Color color) {
    final path = Path()..addPolygon(points, true);
    c.drawPath(path, _fill(color));
    c.drawPath(path, _line);
  }

  void _column(Canvas c, Size s) {
    final w = s.width * .24;
    final h = s.height * .52;
    final x = s.width * .38;
    final y = s.height * .25;
    final d = Offset(s.width * .13, -s.height * .12);
    final front = Rect.fromLTWH(x, y, w, h);
    _face(c, [front.topLeft, front.topRight, front.bottomRight, front.bottomLeft], _front);
    _face(c, [front.topRight, front.topRight + d, front.bottomRight + d, front.bottomRight], _side);
    _face(c, [front.topLeft, front.topRight, front.topRight + d, front.topLeft + d], _top);
    _shutterStrips(c, front, vertical: true);
    _dimension(c, Offset(front.left, s.height * .9), Offset(front.right, s.height * .9), 'L');
    _dimension(c, front.topRight + Offset(5, -4), front.topRight + d + Offset(5, -4), 'W');
    _dimension(c, Offset(front.left - s.width * .11, front.top), Offset(front.left - s.width * .11, front.bottom), 'H');
  }

  void _beam(Canvas c, Size s) {
    final x = s.width * .15;
    final y = s.height * .38;
    final w = s.width * .57;
    final h = s.height * .27;
    final d = Offset(s.width * .12, -s.height * .12);
    final r = Rect.fromLTWH(x, y, w, h);
    _face(c, [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft], _front);
    _face(c, [r.topRight, r.topRight + d, r.bottomRight + d, r.bottomRight], _side);
    _face(c, [r.topLeft, r.topRight, r.topRight + d, r.topLeft + d], _top);
    _face(c, [r.bottomLeft, r.bottomRight, r.bottomRight + Offset(0, s.height * .055), r.bottomLeft + Offset(0, s.height * .055)], _shutter);
    _dimension(c, Offset(r.left, s.height * .9), Offset(r.right, s.height * .9), 'L');
    _dimension(c, r.topRight + Offset(5, -4), r.topRight + d + Offset(5, -4), 'B');
    _dimension(c, Offset(r.left - s.width * .08, r.top), Offset(r.left - s.width * .08, r.bottom), 'D');
  }

  void _footing(Canvas c, Size s) {
    final x = s.width * .24;
    final y = s.height * .43;
    final w = s.width * .42;
    final h = s.height * .25;
    final d = Offset(s.width * .15, -s.height * .15);
    final r = Rect.fromLTWH(x, y, w, h);
    _face(c, [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft], _shutter);
    _face(c, [r.topRight, r.topRight + d, r.bottomRight + d, r.bottomRight], _side);
    _face(c, [r.topLeft, r.topRight, r.topRight + d, r.topLeft + d], _top);
    _dimension(c, Offset(r.left, s.height * .9), Offset(r.right, s.height * .9), 'L');
    _dimension(c, r.topRight + Offset(5, -4), r.topRight + d + Offset(5, -4), 'W');
    _dimension(c, Offset(r.left - s.width * .08, r.top), Offset(r.left - s.width * .08, r.bottom), 'D');
  }

  void _wall(Canvas c, Size s) {
    final x = s.width * .18;
    final y = s.height * .24;
    final w = s.width * .55;
    final h = s.height * .52;
    final d = Offset(s.width * .11, -s.height * .09);
    final r = Rect.fromLTWH(x, y, w, h);
    _face(c, [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft], _shutter);
    _face(c, [r.topRight, r.topRight + d, r.bottomRight + d, r.bottomRight], _side);
    _face(c, [r.topLeft, r.topRight, r.topRight + d, r.topLeft + d], _top);
    _dimension(c, Offset(r.left, s.height * .9), Offset(r.right, s.height * .9), 'L');
    _dimension(c, Offset(r.left - s.width * .09, r.top), Offset(r.left - s.width * .09, r.bottom), 'H');
    _dimension(c, r.topRight + Offset(4, -5), r.topRight + d + Offset(4, -5), 'T');
  }

  void _slab(Canvas c, Size s) {
    final x = s.width * .20;
    final y = s.height * .35;
    final w = s.width * .47;
    final d = Offset(s.width * .16, -s.height * .13);
    final thickness = s.height * .09;
    final top = [Offset(x, y), Offset(x + w, y), Offset(x + w, y) + d, Offset(x, y) + d];
    _face(c, top, _top);
    _face(c, [Offset(x, y), Offset(x + w, y), Offset(x + w, y + thickness), Offset(x, y + thickness)], _front);
    _face(c, [Offset(x + w, y), Offset(x + w, y) + d, Offset(x + w, y + thickness) + d, Offset(x + w, y + thickness)], _side);
    _face(c, [Offset(x, y + thickness), Offset(x + w, y + thickness), Offset(x + w, y + thickness) + d, Offset(x, y + thickness) + d], _shutter);
    _dimension(c, Offset(x, s.height * .9), Offset(x + w, s.height * .9), 'L');
    _dimension(c, Offset(x + w + 4, y - 4), Offset(x + w, y) + d + Offset(4, -4), 'W');
    _dimension(c, Offset(x - s.width * .08, y), Offset(x - s.width * .08, y + thickness), 'T');
  }

  void _shutterStrips(Canvas c, Rect r, {required bool vertical}) {
    final paint = Paint()..color = _shutter.withValues(alpha: .6);
    if (vertical) {
      c.drawRect(Rect.fromLTWH(r.left, r.top, r.width * .08, r.height), paint);
      c.drawRect(Rect.fromLTWH(r.right - r.width * .08, r.top, r.width * .08, r.height), paint);
    }
  }

  void _dimension(Canvas c, Offset from, Offset to, String label) {
    final paint = Paint()
      ..color = _ink
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    c.drawLine(from, to, paint);
    _arrow(c, from, to, paint);
    _arrow(c, to, from, paint);
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final normal = Offset(-(to.dy - from.dy), to.dx - from.dx);
    final length = normal.distance == 0 ? 1.0 : normal.distance;
    _text(c, label, mid + normal / length * 10 - const Offset(5, 7));
  }

  void _arrow(Canvas c, Offset tip, Offset toward, Paint paint) {
    final vector = toward - tip;
    final length = vector.distance == 0 ? 1.0 : vector.distance;
    final unit = vector / length;
    final perpendicular = Offset(-unit.dy, unit.dx);
    c.drawLine(tip, tip + unit * 7 + perpendicular * 3, paint);
    c.drawLine(tip, tip + unit * 7 - perpendicular * 3, paint);
  }

  void _text(Canvas c, String value, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700, fontSize: 13)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(c, offset);
  }

  @override
  bool shouldRepaint(covariant _ShutteringPainter oldDelegate) => oldDelegate.type != type;
}
