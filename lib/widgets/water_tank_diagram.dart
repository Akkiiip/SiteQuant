import 'package:flutter/material.dart';

import '../models/water_tank_input.dart';

class WaterTankDiagram extends StatelessWidget {
  const WaterTankDiagram({super.key, required this.type});

  final WaterTankType type;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2,
    child: CustomPaint(painter: _WaterTankPainter(type)),
  );
}

class _WaterTankPainter extends CustomPainter {
  const _WaterTankPainter(this.type);
  final WaterTankType type;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFF1F5FAE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rcc = Paint()..color = const Color(0xFF72A7E8);
    final water = Paint()..color = const Color(0x5572A7E8);
    final rect = Rect.fromLTWH(
      size.width * .27,
      size.height * .18,
      size.width * .43,
      size.height * .62,
    );

    if (type == WaterTankType.circular) {
      final outer = Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .5),
        width: size.width * .42,
        height: size.height * .62,
      );
      final inner = outer.deflate(size.width * .045);
      canvas.drawOval(outer, rcc);
      canvas.drawOval(inner, water);
      canvas.drawOval(outer, line);
      canvas.drawOval(inner, line);
      _label(canvas, 'D', Offset(size.width * .48, size.height * .84));
      _label(canvas, 'H', Offset(size.width * .75, size.height * .48));
      _label(canvas, 'T', Offset(size.width * .18, size.height * .3));
      return;
    }

    final inner = rect.deflate(size.width * .04);
    canvas.drawRect(rect, rcc);
    canvas.drawRect(inner, water);
    canvas.drawRect(rect, line);
    canvas.drawRect(inner, line);
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + 18, rect.top - 12),
      line,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right + 18, rect.top - 12),
      line,
    );
    canvas.drawLine(
      Offset(rect.right + 18, rect.top - 12),
      Offset(rect.right + 18, rect.bottom - 12),
      line,
    );
    _label(canvas, 'L', Offset(size.width * .48, size.height * .85));
    _label(canvas, 'W', Offset(size.width * .13, size.height * .52));
    _label(canvas, 'H', Offset(size.width * .78, size.height * .48));
  }

  void _label(Canvas canvas, String value, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Color(0xFF174A87),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WaterTankPainter oldDelegate) =>
      oldDelegate.type != type;
}
