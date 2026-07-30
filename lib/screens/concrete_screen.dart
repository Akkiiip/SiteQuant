import 'package:flutter/material.dart';

import '../services/concrete_calculator.dart';
import '../services/volume_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'concrete_result_screen.dart';

typedef _VolumeMethod = double Function(
  Map<_InputKey, double> values,
  int quantity,
);

enum _InputKey { length, width, thickness, depth, height, diameter, quantity, volume }

enum _DiagramKind { slab, beam, column, footing, circularColumn, circularFooting, custom }

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
  static const _volume = _InputDefinition(_InputKey.volume, 'Volume', unit: 'm³');

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
  final TextEditingController _wcController = TextEditingController(text: '0.45');

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

    final values = <_InputKey, double>{};
    for (final field in _selectedStructure.fields) {
      final rawValue = _controllers[field.key]!.text.trim();
      final value = double.tryParse(rawValue);
      if (rawValue.isEmpty || value == null || value <= 0) {
        _showValidationMessage('Enter a value greater than zero for ${field.label}.');
        return;
      }
      if (field.wholeNumber && value != value.roundToDouble()) {
        _showValidationMessage('${field.label} must be a whole number.');
        return;
      }
      values[field.key] = value;
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
      _showValidationMessage('Enter dimensions that produce a volume greater than zero.');
      return;
    }

    final result = ConcreteCalculator.calculate(
      volume: volume,
      grade: _selectedGrade,
      wcRatio: wcRatio,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Concrete Calculator',
      bodyBuilder: (context, padding) => SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concrete Takeoff', style: textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              'Calculate concrete volume and material quantities.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Structure Type',
                      icon: Icons.category_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _structures.map((structure) {
                        final isSelected = _selectedStructure == structure;
                        return ChoiceChip(
                          label: Text(structure.name),
                          selected: isSelected,
                          backgroundColor: colorScheme.surface,
                          selectedColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => _changeStructure(structure),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Dimensions',
                      icon: Icons.straighten_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    _StructureDiagram(kind: _selectedStructure.diagram),
                    const SizedBox(height: 16),
                    for (var index = 0;
                        index < _selectedStructure.fields.length;
                        index++) ...[
                      DimensionInputField(
                        controller: _controllers[
                            _selectedStructure.fields[index].key]!,
                        label: _selectedStructure.fields[index].label,
                        unit: _selectedStructure.fields[index].unit,
                        wholeNumber: _selectedStructure.fields[index].wholeNumber,
                      ),
                      if (index < _selectedStructure.fields.length - 1)
                        const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Mix Specification',
                      icon: Icons.science_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Concrete Grade',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      items: _grades
                          .map(
                            (grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedGrade = value!),
                    ),
                    const SizedBox(height: 14),
                    DimensionInputField(
                      controller: _wcController,
                      label: 'Water-Cement Ratio',
                      unit: null,
                    ),
                    const SizedBox(height: 4),
                    Text('Typical value: 0.45', style: textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: _calculate,
              icon: Icons.calculate_rounded,
              label: 'Calculate Quantity',
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
          height: 84,
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.42,
      height: size.height * 0.56,
    );

    switch (kind) {
      case _DiagramKind.slab:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: rect.width,
              height: rect.height * 0.34,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      case _DiagramKind.beam:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: rect.width,
              height: rect.height * 0.55,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      case _DiagramKind.column:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: rect.width * 0.36,
              height: rect.height,
            ),
            const Radius.circular(4),
          ),
          paint,
        );
      case _DiagramKind.footing:
        canvas.drawRect(
          Rect.fromCenter(
            center: rect.center + Offset(0, rect.height * 0.22),
            width: rect.width,
            height: rect.height * 0.28,
          ),
          paint,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: rect.center - Offset(0, rect.height * 0.16),
            width: rect.width * 0.32,
            height: rect.height * 0.5,
          ),
          paint,
        );
      case _DiagramKind.circularColumn:
        canvas.drawOval(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.36,
            height: rect.height,
          ),
          paint,
        );
      case _DiagramKind.circularFooting:
        canvas.drawOval(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 0.68,
            height: rect.height * 0.68,
          ),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.16, rect.center.dy),
          Offset(rect.right - rect.width * 0.16, rect.center.dy),
          paint,
        );
      case _DiagramKind.custom:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          paint,
        );
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
        canvas.drawLine(rect.topRight, rect.bottomLeft, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StructureDiagramPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
