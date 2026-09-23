import 'package:flutter/material.dart';

import 'engineering_drawing.dart';

/// Optional finish section/elevation, kept compact for future detail views.
/// Current Plaster/Paint forms intentionally do not display a large diagram.
class SurfaceDiagram extends StatelessWidget {
  const SurfaceDiagram({super.key, required this.title, this.ceiling = false});
  final String title;
  final bool ceiling;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '$title diagram showing length, height or width, and finish thickness',
    child: SizedBox(
      height: 142,
      width: double.infinity,
      child: CustomPaint(painter: _SurfacePainter(ceiling)),
    ),
  );
}

class _SurfacePainter extends CustomPainter {
  const _SurfacePainter(this.ceiling);
  final bool ceiling;

  @override
  void paint(Canvas canvas, Size size) {
    final core = Rect.fromLTRB(
      size.width * .20,
      size.height * .20,
      size.width * .74,
      size.height * .70,
    );
    EngineeringDrawing.rect(canvas, core, color: EngineeringDrawing.fill);
    EngineeringDrawing.hatch(canvas, core, spacing: 12);
    final finish = ceiling
        ? Rect.fromLTRB(core.left, core.bottom - 6, core.right, core.bottom)
        : Rect.fromLTRB(core.right - 6, core.top, core.right, core.bottom);
    EngineeringDrawing.rect(canvas, finish, color: EngineeringDrawing.fillDark);
    EngineeringDrawing.dimension(
      canvas,
      Offset(core.left, size.height * .85),
      Offset(core.right, size.height * .85),
      'L',
      objectFrom: core.bottomLeft,
      objectTo: core.bottomRight,
      labelAt: Offset(core.center.dx, size.height * .78),
    );
    EngineeringDrawing.dimension(
      canvas,
      Offset(core.left - 18, core.top),
      Offset(core.left - 18, core.bottom),
      ceiling ? 'W' : 'H',
      objectFrom: core.topLeft,
      objectTo: core.bottomLeft,
      labelAt: Offset(core.left - 30, core.center.dy),
    );
    EngineeringDrawing.dimension(
      canvas,
      ceiling
          ? Offset(core.right + 13, finish.top)
          : Offset(finish.left, core.top - 14),
      ceiling
          ? Offset(core.right + 13, finish.bottom)
          : Offset(finish.right, core.top - 14),
      'T',
      objectFrom: ceiling ? finish.topRight : finish.topLeft,
      objectTo: ceiling ? finish.bottomRight : finish.topRight,
      labelAt: ceiling
          ? Offset(core.right + 26, finish.center.dy)
          : Offset(finish.center.dx, core.top - 24),
    );
  }

  @override
  bool shouldRepaint(covariant _SurfacePainter old) => old.ceiling != ceiling;
}
