import 'package:flutter/material.dart';

import '../services/concrete_calculator.dart';
import '../services/analytics_service.dart';
import '../services/volume_calculator.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';

import '../widgets/calculator_ui.dart';
import '../widgets/engineering_drawing.dart';

import 'concrete_result_screen.dart';

typedef _VolumeMethod =
    double Function(Map<_InputKey, double> values, int quantity);

enum _InputKey {
  length,
  width,
  thickness,
  depth,
  height,
  diameter,
  quantity,
  volume,
}

enum _DiagramKind {
  slab,
  beam,
  column,
  footing,
  circularColumn,
  circularFooting,
  custom,
}

class _InputDefinition {
  final _InputKey key;
  final String label;
  final String? unit;
  final bool wholeNumber;

  const _InputDefinition(
    this.key,
    this.label, {
    this.unit = 'm',
    this.wholeNumber = false,
  });
}

class _StructureConfig {
  final String name;
  final _DiagramKind diagram;
  final List<_InputDefinition> fields;
  final _VolumeMethod calculateVolume;

  const _StructureConfig({
    required this.name,
    required this.diagram,
    required this.fields,
    required this.calculateVolume,
  });
}

class ConcreteScreen extends StatefulWidget {
  const ConcreteScreen({super.key});

  @override
  State<ConcreteScreen> createState() => _ConcreteScreenState();
}

class _ConcreteScreenState extends State<ConcreteScreen> {
  static const _length = _InputDefinition(_InputKey.length, 'Length');
  static const _width = _InputDefinition(_InputKey.width, 'Width');
  static const _thickness = _InputDefinition(_InputKey.thickness, 'Thickness');
  static const _depth = _InputDefinition(_InputKey.depth, 'Depth');
  static const _height = _InputDefinition(_InputKey.height, 'Height');
  static const _diameter = _InputDefinition(_InputKey.diameter, 'Diameter');
  static const _quantity = _InputDefinition(
    _InputKey.quantity,
    'Quantity',
    unit: null,
    wholeNumber: true,
  );
  static const _volume = _InputDefinition(
    _InputKey.volume,
    'Volume',
    unit: 'm³',
  );

  static final List<_StructureConfig> _structures = [
    _StructureConfig(
      name: 'Slab',
      diagram: _DiagramKind.slab,
      fields: const [_length, _width, _thickness],
      calculateVolume: (values, _) => VolumeCalculator.slab(
        length: values[_InputKey.length]!,
        width: values[_InputKey.width]!,
        thickness: values[_InputKey.thickness]!,
      ),
    ),
    _StructureConfig(
      name: 'Beam',
      diagram: _DiagramKind.beam,
      fields: const [_length, _width, _depth],
      calculateVolume: (values, _) => VolumeCalculator.beam(
        length: values[_InputKey.length]!,
        width: values[_InputKey.width]!,
        depth: values[_InputKey.depth]!,
      ),
    ),
    _StructureConfig(
      name: 'Rectangular Column',
      diagram: _DiagramKind.column,
      fields: const [_length, _width, _height, _quantity],
      calculateVolume: (values, quantity) => VolumeCalculator.column(
        length: values[_InputKey.length]!,
        breadth: values[_InputKey.width]!,
        height: values[_InputKey.height]!,
        number: quantity,
      ),
    ),
    _StructureConfig(
      name: 'Circular Column',
      diagram: _DiagramKind.circularColumn,
      fields: const [_diameter, _height, _quantity],
      calculateVolume: (values, quantity) => VolumeCalculator.circularColumn(
        diameter: values[_InputKey.diameter]!,
        height: values[_InputKey.height]!,
        number: quantity,
      ),
    ),
    _StructureConfig(
      name: 'Rectangular Footing',
      diagram: _DiagramKind.footing,
      fields: const [_length, _width, _depth, _quantity],
      calculateVolume: (values, quantity) => VolumeCalculator.footing(
        length: values[_InputKey.length]!,
        width: values[_InputKey.width]!,
        depth: values[_InputKey.depth]!,
        number: quantity,
      ),
    ),
    _StructureConfig(
      name: 'Circular Footing',
      diagram: _DiagramKind.circularFooting,
      fields: const [_diameter, _depth, _quantity],
      calculateVolume: (values, quantity) => VolumeCalculator.circularFooting(
        diameter: values[_InputKey.diameter]!,
        depth: values[_InputKey.depth]!,
        number: quantity,
      ),
    ),
    _StructureConfig(
      name: 'Custom Volume',
      diagram: _DiagramKind.custom,
      fields: const [_volume],
      calculateVolume: (values, _) =>
          VolumeCalculator.custom(volume: values[_InputKey.volume]!),
    ),
  ];

  static const List<String> _grades = [
    'M5',
    'M7.5',
    'M10',
    'M15',
    'M20',
    'M25',
    'M30 (Design Mix)',
    'M35 (Design Mix)',
    'M40 (Design Mix)',
  ];

  final Map<_InputKey, TextEditingController> _controllers = {
    for (final key in _InputKey.values) key: TextEditingController(),
  };
  final TextEditingController _wcController = TextEditingController(
    text: '0.45',
  );

  late _StructureConfig _selectedStructure;
  String _selectedGrade = 'M20';

  @override
  void initState() {
    super.initState();
    _selectedStructure = _structures.last;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _wcController.dispose();
    super.dispose();
  }

  void _changeStructure(_StructureConfig structure) {
    FocusScope.of(context).unfocus();
    for (final controller in _controllers.values) {
      controller.clear();
    }
    setState(() => _selectedStructure = structure);
  }

  void _showValidationMessage(String message) {
    AnalyticsService.logCalculationError('concrete', 'invalid_input');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _mixRatioLabel() {
    return ConcreteCalculator.mixRatios[_selectedGrade]!
        .map(
          (part) => part == part.roundToDouble()
              ? part.toInt().toString()
              : part.toString(),
        )
        .join(' : ');
  }

  void _calculate() {
    if (!ConcreteCalculator.supportsGrade(_selectedGrade)) {
      _showValidationMessage(
        'Design mixes require an approved mix design and are not available in this calculator yet.',
      );
      return;
    }

    final system =
        MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    final values = <_InputKey, double>{};
    for (final field in _selectedStructure.fields) {
      final rawValue = _controllers[field.key]!.text.trim();
      final value = double.tryParse(rawValue);
      if (rawValue.isEmpty || value == null || value <= 0) {
        _showValidationMessage(
          'Enter a value greater than zero for ${field.label}.',
        );
        return;
      }
      if (field.wholeNumber && value != value.roundToDouble()) {
        _showValidationMessage('${field.label} must be a whole number.');
        return;
      }
      values[field.key] = field.key == _InputKey.quantity
          ? value
          : field.key == _InputKey.volume
          ? MeasurementPreferences.toCubicMetres(value, system)
          : MeasurementPreferences.toMetres(value, system);
    }

    final wcRatio = double.tryParse(_wcController.text.trim());
    if (wcRatio == null || wcRatio <= 0) {
      _showValidationMessage('Enter a Water-Cement Ratio greater than zero.');
      return;
    }

    final volume = _selectedStructure.calculateVolume(
      values,
      values[_InputKey.quantity]?.round() ?? 1,
    );
    if (volume <= 0) {
      _showValidationMessage(
        'Enter dimensions that produce a volume greater than zero.',
      );
      return;
    }

    final result = ConcreteCalculator.calculate(
      volume: volume,
      grade: _selectedGrade,
      wcRatio: wcRatio,
    );

    AnalyticsService.logCalculationCompleted(
      'concrete',
      workType: _selectedStructure.name.toLowerCase().replaceAll(' ', '_'),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConcreteResultScreen(
          result: result,
          structure: _selectedStructure.name,
          grade: _selectedGrade,
          mixRatio: _mixRatioLabel(),
          wcRatio: wcRatio,
          dryVolume: volume * ConcreteCalculator.dryVolumeFactor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Concrete Calculator',
      bodyBuilder: (context, padding) => SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CalculatorHeader(title: 'Concrete Calculator'),
            CalculatorTypeTabs(
              labels: _structures.map((structure) => structure.name).toList(),
              selected: _selectedStructure.name,
              onSelected: (name) => _changeStructure(
                _structures.firstWhere((structure) => structure.name == name),
              ),
            ),
            const SizedBox(height: 16),
            EngineeringDiagramCard(
              label: _selectedStructure.name,
              diagram: _StructureDiagram(kind: _selectedStructure.diagram),
            ),
            const SizedBox(height: 16),
            const MetricImperialToggle(),
            const SizedBox(height: 16),
            for (final field in _selectedStructure.fields)
              CalculatorInputRow(
                controller: _controllers[field.key]!,
                label: field.label,
                unit: field.unit,
                wholeNumber: field.wholeNumber,
              ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              decoration: const InputDecoration(
                labelText: 'Concrete Grade',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              items: _grades
                  .map(
                    (grade) =>
                        DropdownMenuItem(value: grade, child: Text(grade)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedGrade = value!),
            ),
            const SizedBox(height: 12),
            CalculatorAdvancedOptions(
              children: [
                CalculatorInputRow(
                  controller: _wcController,
                  label: 'Water-Cement Ratio',
                  unit: null,
                ),
                Text(
                  'Typical value: 0.45',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CalculatorCalculateButton(
              onPressed: _calculate,
              label: 'Calculate Concrete',
            ),
          ],
        ),
      ),
    );
  }
}

class _StructureDiagram extends StatelessWidget {
  final _DiagramKind kind;

  const _StructureDiagram({required this.kind});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${kind.name} structure diagram',
      child: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          height: 170,
          child: CustomPaint(
            painter: _StructureDiagramPainter(
              kind,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StructureDiagramPainter extends CustomPainter {
  final _DiagramKind kind;
  final Color color;
  const _StructureDiagramPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = EngineeringDrawing.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final topFill = Paint()..color = EngineeringDrawing.fillLight;
    final sideFill = Paint()..color = EngineeringDrawing.fillDark;
    final frontFill = Paint()..color = EngineeringDrawing.fill;
    final dimension = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    Path polygon(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      return path..close();
    }

    void face(List<Offset> points, Paint fill) {
      final path = polygon(points);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    void label(String text, Offset position) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xFF0A1D45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, position);
    }

    void arrow(
      Offset from,
      Offset to,
      String text,
      Offset textPosition, {
      required Offset objectFrom,
      required Offset objectTo,
    }) => EngineeringDrawing.dimension(
      canvas,
      from,
      to,
      text,
      objectFrom: objectFrom,
      objectTo: objectTo,
      labelAt: textPosition,
    );

    if (kind == _DiagramKind.custom) {
      final rect = Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * .45,
        height: h * .48,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        topFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        stroke,
      );
      canvas.drawLine(rect.topLeft, rect.bottomRight, dimension);
      canvas.drawLine(rect.topRight, rect.bottomLeft, dimension);
      label('V', Offset(w / 2 - 4, h / 2 - 8));
      return;
    }

    if (kind == _DiagramKind.circularColumn ||
        kind == _DiagramKind.circularFooting) {
      final tall = kind == _DiagramKind.circularColumn;
      final cx = w * .52;
      final cy = h * .46;
      final rx = tall ? w * .15 : w * .25;
      final ry = tall ? 16.0 : 25.0;
      final height = tall ? h * .58 : h * .22;
      final top = Rect.fromCenter(
        center: Offset(cx, cy - height / 2),
        width: rx * 2,
        height: ry * 2,
      );
      final bottom = top.translate(0, height);
      canvas.drawRect(
        Rect.fromLTRB(cx - rx, top.center.dy, cx + rx, bottom.center.dy),
        frontFill,
      );
      canvas.drawLine(
        Offset(cx - rx, top.center.dy),
        Offset(cx - rx, bottom.center.dy),
        stroke,
      );
      canvas.drawLine(
        Offset(cx + rx, top.center.dy),
        Offset(cx + rx, bottom.center.dy),
        stroke,
      );
      canvas.drawOval(bottom, stroke);
      canvas.drawOval(top, topFill);
      canvas.drawOval(top, stroke);
      arrow(
        Offset(cx - rx, h * .12),
        Offset(cx + rx, h * .12),
        'D',
        Offset(cx - 4, h * .02),
        objectFrom: Offset(cx - rx, top.center.dy),
        objectTo: Offset(cx + rx, top.center.dy),
      );
      arrow(
        Offset(cx + rx + 24, top.center.dy),
        Offset(cx + rx + 24, bottom.center.dy),
        tall ? 'H' : 'D',
        Offset(cx + rx + 30, cy - 8),
        objectFrom: Offset(cx + rx, top.center.dy),
        objectTo: Offset(cx + rx, bottom.center.dy),
      );
      return;
    }

    final tall = kind == _DiagramKind.column;
    final beam = kind == _DiagramKind.beam;
    final left =
        w *
        (beam
            ? .16
            : kind == _DiagramKind.column
            ? .41
            : kind == _DiagramKind.footing
            ? .20
            : .23);
    final right =
        w *
        (beam
            ? .72
            : kind == _DiagramKind.column
            ? .57
            : kind == _DiagramKind.footing
            ? .72
            : .68);
    final topY =
        h *
        (tall
            ? .12
            : kind == _DiagramKind.footing
            ? .43
            : .31);
    final depth = tall
        ? h * .52
        : beam
        ? h * .28
        : h * .14;
    final skewX = w * (tall ? .07 : .12);
    final skewY = h * .15;
    final a = Offset(left, topY + skewY);
    final b = Offset(right, topY + skewY);
    final c = Offset(right + skewX, topY);
    final d = Offset(left + skewX, topY);
    face([a, b, c, d], topFill);
    face([a, b, b.translate(0, depth), a.translate(0, depth)], frontFill);
    face([b, c, c.translate(0, depth), b.translate(0, depth)], sideFill);
    if (kind == _DiagramKind.footing) {
      face([
        Offset(w * .43, topY - h * .04),
        Offset(w * .55, topY - h * .04),
        Offset(w * .55, topY + h * .08),
        Offset(w * .43, topY + h * .08),
      ], sideFill);
    }
    arrow(
      Offset(left, h * .86),
      Offset(right, h * .86),
      'L',
      Offset((left + right) / 2, h * .88),
      objectFrom: a.translate(0, depth),
      objectTo: b.translate(0, depth),
    );
    arrow(
      Offset(right + 8, topY + skewY - 8),
      Offset(right + skewX + 8, topY - 8),
      'B',
      Offset(right + skewX / 2 + 10, topY - 16),
      objectFrom: b,
      objectTo: c,
    );
    arrow(
      Offset(left - 15, a.dy),
      Offset(left - 15, a.dy + depth),
      tall
          ? 'H'
          : beam || kind == _DiagramKind.footing
          ? 'D'
          : 'T',
      Offset(left - 31, a.dy + depth / 2 - 7),
      objectFrom: a,
      objectTo: a.translate(0, depth),
    );
  }

  @override
  bool shouldRepaint(covariant _StructureDiagramPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
