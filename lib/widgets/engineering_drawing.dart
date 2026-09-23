import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Small, presentation-only CAD primitives shared by calculator schematics.
/// Callers own the geometry; this class owns line, hatch and dimension language.
abstract final class EngineeringDrawing {
  static const ink = Color(0xFF19324D);
  static const secondary = Color(0xFF69839C);
  static const fill = Color(0xFFE7EDF3);
  static const fillLight = Color(0xFFF2F6FA);
  static const fillDark = Color(0xFFCBD8E4);
  static const accent = Color(0xFF3476B9);
  static const strokeWidth = 1.15;
  static const dimensionWidth = .95;

  static Paint stroke({Color color = ink, double width = strokeWidth}) =>
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter
        ..style = PaintingStyle.stroke;

  static void line(
    Canvas c,
    Offset a,
    Offset b, {
    Color color = ink,
    double width = strokeWidth,
  }) => c.drawLine(a, b, stroke(color: color, width: width));

  static void face(Canvas c, List<Offset> points, {Color color = fill}) {
    final path = Path()..addPolygon(points, true);
    c.drawPath(path, Paint()..color = color);
    c.drawPath(path, stroke());
  }

  static void rect(Canvas c, Rect bounds, {Color color = fill}) {
    c.drawRect(bounds, Paint()..color = color);
    c.drawRect(bounds, stroke());
  }

  static void label(
    Canvas c,
    String value,
    Offset center, {
    double size = 10,
    Color color = ink,
  }) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    text.paint(c, center - Offset(text.width / 2, text.height / 2));
  }

  static void arrowhead(Canvas c, Offset tip, Offset toward) {
    final vector = toward - tip;
    if (vector.distance < .001) return;
    final unit = vector / vector.distance;
    final normal = Offset(-unit.dy, unit.dx);
    final p = stroke(width: dimensionWidth);
    c.drawLine(tip, tip + unit * 5 + normal * 2.1, p);
    c.drawLine(tip, tip + unit * 5 - normal * 2.1, p);
  }

  /// [from] and [to] lie outside the object. [objectFrom]/[objectTo] are
  /// separate extension-line origins on the measured geometry.
  static void dimension(
    Canvas c,
    Offset from,
    Offset to,
    String value, {
    required Offset objectFrom,
    required Offset objectTo,
    Offset? labelAt,
  }) {
    final vector = to - from;
    if (vector.distance < .001) return;
    final normal = Offset(-vector.dy, vector.dx) / vector.distance;
    void extension(Offset object, Offset end) {
      final delta = end - object;
      final direction = delta / (delta.distance < .001 ? 1 : delta.distance);
      line(
        c,
        object + direction * 2,
        end + direction * 3,
        color: secondary,
        width: dimensionWidth,
      );
    }

    extension(objectFrom, from);
    extension(objectTo, to);
    line(c, from, to, width: dimensionWidth);
    arrowhead(c, from, to);
    arrowhead(c, to, from);
    final midpoint = (from + to) / 2;
    label(c, value, labelAt ?? midpoint - normal * 8, size: 10);
  }

  static void dashed(Canvas c, Offset a, Offset b, {Color color = secondary}) {
    final delta = b - a;
    final distance = delta.distance;
    if (distance < .001) return;
    final unit = delta / distance;
    for (var d = 0.0; d < distance; d += 8) {
      line(
        c,
        a + unit * d,
        a + unit * math.min(d + 4, distance),
        color: color,
        width: .8,
      );
    }
  }

  static void hatch(
    Canvas c,
    Rect bounds, {
    double spacing = 8,
    Color color = secondary,
  }) {
    c.save();
    c.clipRect(bounds);
    for (
      var x = bounds.left - bounds.height;
      x < bounds.right + bounds.height;
      x += spacing
    ) {
      line(
        c,
        Offset(x, bounds.bottom),
        Offset(x + bounds.height, bounds.top),
        color: color,
        width: .6,
      );
    }
    c.restore();
  }

  static void opening(Canvas c, Rect bounds) {
    c.drawRect(bounds, Paint()..color = Colors.white);
    c.drawRect(bounds, stroke());
    line(c, bounds.topLeft, bounds.bottomRight, color: secondary, width: .7);
    line(c, bounds.topRight, bounds.bottomLeft, color: secondary, width: .7);
  }

  /// Grout is the negative space between filled tiles, not a heavy grid overlay.
  static void tileGrid(
    Canvas c,
    Rect bounds, {
    required int columns,
    required int rows,
    double joint = 1.5,
  }) {
    if (columns < 1 || rows < 1) return;
    c.drawRect(bounds, Paint()..color = fillDark);
    final cellWidth = bounds.width / columns;
    final cellHeight = bounds.height / rows;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final tile = Rect.fromLTWH(
          bounds.left + column * cellWidth + joint / 2,
          bounds.top + row * cellHeight + joint / 2,
          cellWidth - joint,
          cellHeight - joint,
        );
        c.drawRect(tile, Paint()..color = fillLight);
        c.drawRect(tile, stroke(color: secondary, width: .55));
      }
    }
    c.drawRect(bounds, stroke());
  }
}
