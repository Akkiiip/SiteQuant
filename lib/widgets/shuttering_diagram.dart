import 'package:flutter/material.dart';
import '../models/shuttering_result.dart';

class ShutteringDiagram extends StatelessWidget {
  const ShutteringDiagram({super.key, required this.type});
  final ShutteringType type;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2.1,
    child: CustomPaint(painter: _ShutteringPainter(type)),
  );
}

class _ShutteringPainter extends CustomPainter {
  const _ShutteringPainter(this.type);
  final ShutteringType type;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xff0d47a1);
    final fill = Paint()..color = const Color(0xff64b5f6);
    final hi = Paint()..color = const Color(0xff1565c0);
    final r = Rect.fromLTWH(
      s.width * .22,
      s.height * .2,
      s.width * .45,
      s.height * .6,
    );
    if (type == ShutteringType.wall) {
      c.drawRect(r, fill);
      c.drawRect(r, p);
      c.drawLine(
        Offset(r.right + 12, r.top),
        Offset(r.right + 12, r.bottom),
        p,
      );
      _labels(c, s, 'L', 'H', 'T');
      return;
    }
    if (type == ShutteringType.slab) {
      final top = Path()
        ..moveTo(r.left, r.top + 20)
        ..lineTo(r.right, r.top)
        ..lineTo(r.right + 20, r.top + 14)
        ..lineTo(r.left + 20, r.top + 34)
        ..close();
      c.drawPath(top, fill);
      c.drawRect(
        Rect.fromLTWH(r.left + 20, r.top + 34, r.width, r.height * .22),
        hi,
      );
      _labels(c, s, 'L', 'W', '');
      return;
    }
    if (type == ShutteringType.beam) {
      c.drawRect(
        Rect.fromLTWH(r.left, r.top + 35, r.width, r.height * .32),
        fill,
      );
      c.drawRect(Rect.fromLTWH(r.left, r.top + 35, r.width, r.height * .32), p);
      c.drawRect(
        Rect.fromLTWH(r.left, r.top + 35, r.width, r.height * .32),
        hi..style = PaintingStyle.fill,
      );
      hi.style = PaintingStyle.fill;
      _labels(c, s, 'L', 'B', 'D');
      return;
    }
    c.drawRect(r, fill);
    c.drawRect(r, p);
    c.drawRect(Rect.fromLTWH(r.left, r.top, r.width * .14, r.height), hi);
    c.drawRect(
      Rect.fromLTWH(r.right - r.width * .14, r.top, r.width * .14, r.height),
      hi,
    );
    _labels(c, s, 'L', 'W', type == ShutteringType.column ? 'H' : 'D');
  }

  void _labels(Canvas c, Size s, String a, String b, String d) {
    final style = const TextStyle(
      color: Color(0xff0d47a1),
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );
    void t(String x, Offset o) {
      final tp = TextPainter(
        text: TextSpan(text: x, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, o);
    }

    t(a, Offset(s.width * .42, s.height * .84));
    t(b, Offset(s.width * .1, s.height * .48));
    if (d.isNotEmpty) t(d, Offset(s.width * .73, s.height * .48));
  }

  @override
  bool shouldRepaint(covariant _ShutteringPainter old) => old.type != type;
}
