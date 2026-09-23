import 'package:flutter/material.dart';

import 'engineering_drawing.dart';

enum CalculatorArtwork {
  concrete,
  masonry,
  plaster,
  paint,
  tiles,
  shuttering,
  steel,
  excavation,
  waterTank,
}

class SiteQuantCalculatorIcon extends StatelessWidget {
  const SiteQuantCalculatorIcon({
    super.key,
    required this.kind,
    this.size = 36,
  });
  final CalculatorArtwork kind;
  final double size;

  static CalculatorArtwork? kindFor(String title) {
    if (title.startsWith('Concrete')) return CalculatorArtwork.concrete;
    if (title.startsWith('Masonry')) return CalculatorArtwork.masonry;
    if (title.startsWith('Plaster')) return CalculatorArtwork.plaster;
    if (title.startsWith('Paint')) return CalculatorArtwork.paint;
    if (title.startsWith('Tiles')) return CalculatorArtwork.tiles;
    if (title.startsWith('Shuttering')) return CalculatorArtwork.shuttering;
    if (title.startsWith('Steel')) return CalculatorArtwork.steel;
    if (title.startsWith('Excavation')) return CalculatorArtwork.excavation;
    if (title.startsWith('RCC Water Tank')) return CalculatorArtwork.waterTank;
    return null;
  }

  static Color colorFor(CalculatorArtwork kind) => switch (kind) {
    CalculatorArtwork.concrete ||
    CalculatorArtwork.waterTank => const Color(0xFF0969F8),
    CalculatorArtwork.masonry ||
    CalculatorArtwork.excavation => const Color(0xFFE87823),
    CalculatorArtwork.plaster => const Color(0xFF139A62),
    CalculatorArtwork.tiles => const Color(0xFF5874C9),
    CalculatorArtwork.paint => const Color(0xFFE84D64),
    CalculatorArtwork.shuttering ||
    CalculatorArtwork.steel => const Color(0xFF173A69),
  };

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${kind.name} calculator icon',
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(kind).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _IconPainter(kind, colorFor(kind))),
    ),
  );
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.kind, this.color);
  final CalculatorArtwork kind;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 36;
    canvas.save();
    canvas.scale(s);
    final line = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color.withValues(alpha: .28);
    void path(List<Offset> points, {bool close = true}) {
      final p = Path()..moveTo(points.first.dx, points.first.dy);
      for (final q in points.skip(1)) {
        p.lineTo(q.dx, q.dy);
      }
      if (close) {
        p.close();
      }
      canvas.drawPath(p, fill);
      canvas.drawPath(p, line);
    }

    void rect(double x, double y, double w, double h) {
      final r = Rect.fromLTWH(x, y, w, h);
      canvas.drawRect(r, fill);
      canvas.drawRect(r, line);
    }

    switch (kind) {
      case CalculatorArtwork.concrete:
        path([
          const Offset(8, 13),
          const Offset(19, 7),
          const Offset(29, 13),
          const Offset(18, 19),
        ]);
        path([
          const Offset(8, 13),
          const Offset(18, 19),
          const Offset(18, 30),
          const Offset(8, 24),
        ]);
        path([
          const Offset(18, 19),
          const Offset(29, 13),
          const Offset(29, 24),
          const Offset(18, 30),
        ]);
      case CalculatorArtwork.masonry:
        rect(5, 20, 11, 6);
        rect(17, 20, 13, 6);
        rect(11, 13, 12, 6);
        rect(4, 27, 25, 2);
      case CalculatorArtwork.plaster:
        path([
          const Offset(7, 25),
          const Offset(23, 11),
          const Offset(28, 16),
          const Offset(13, 29),
        ]);
        canvas.drawLine(const Offset(22, 12), const Offset(26, 8), line);
        canvas.drawLine(const Offset(26, 8), const Offset(31, 13), line);
      case CalculatorArtwork.paint:
        rect(7, 9, 19, 8);
        canvas.drawLine(const Offset(26, 13), const Offset(30, 13), line);
        canvas.drawLine(const Offset(30, 13), const Offset(30, 21), line);
        canvas.drawLine(const Offset(30, 21), const Offset(19, 21), line);
        canvas.drawLine(const Offset(19, 21), const Offset(19, 29), line);
      case CalculatorArtwork.tiles:
        EngineeringDrawing.tileGrid(
          canvas,
          const Rect.fromLTWH(6, 7, 24, 22),
          columns: 3,
          rows: 3,
          joint: 1.2,
        );
      case CalculatorArtwork.shuttering:
        rect(8, 8, 18, 19);
        canvas.drawLine(const Offset(13, 8), const Offset(13, 27), line);
        canvas.drawLine(const Offset(21, 8), const Offset(21, 27), line);
        canvas.drawLine(const Offset(6, 29), const Offset(29, 29), line);
      case CalculatorArtwork.steel:
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(Offset(7, 14 + i * 5), Offset(29, 8 + i * 5), line);
        }
        canvas.drawCircle(const Offset(28, 26), 4, line);
      case CalculatorArtwork.excavation:
        canvas.drawCircle(const Offset(10, 27), 3, line);
        canvas.drawCircle(const Offset(26, 27), 3, line);
        path([
          const Offset(5, 23),
          const Offset(19, 23),
          const Offset(19, 16),
          const Offset(14, 16),
          const Offset(11, 20),
          const Offset(5, 20),
        ]);
        canvas.drawLine(const Offset(18, 16), const Offset(25, 9), line);
        canvas.drawLine(const Offset(25, 9), const Offset(30, 19), line);
        path([
          const Offset(28, 19),
          const Offset(33, 19),
          const Offset(30, 24),
        ]);
      case CalculatorArtwork.waterTank:
        canvas.drawOval(const Rect.fromLTWH(8, 7, 20, 7), fill);
        canvas.drawOval(const Rect.fromLTWH(8, 7, 20, 7), line);
        canvas.drawRect(const Rect.fromLTWH(8, 10, 20, 17), fill);
        canvas.drawLine(const Offset(8, 10), const Offset(8, 27), line);
        canvas.drawLine(const Offset(28, 10), const Offset(28, 27), line);
        canvas.drawArc(const Rect.fromLTWH(8, 23, 20, 7), 0, 3.14, false, line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.kind != kind || old.color != color;
}
