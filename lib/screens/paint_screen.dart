import 'package:flutter/material.dart';

import '../models/opening_deduction.dart';
import '../models/paint_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../services/paint_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/opening_deductions_editor.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'paint_result_screen.dart';

enum _PaintAreaMode { dimensions, directArea }

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _MaterialControllers {
  final coats = TextEditingController(text: '1');
  final coverage = TextEditingController();
  final wastage = TextEditingController(text: '5');
  final rate = TextEditingController();

  List<TextEditingController> get all => [coats, coverage, wastage, rate];

  void dispose() {
    for (final controller in all) {
      controller.dispose();
    }
  }
}

class _PaintScreenState extends State<PaintScreen> {
  final _length = TextEditingController();
  final _height = TextEditingController();
  final _surfaces = TextEditingController(text: '1');
  final _directArea = TextEditingController();
  final _painterCoefficient = TextEditingController();
  final _helperCoefficient = TextEditingController();
  final _painterWage = TextEditingController();
  final _helperWage = TextEditingController();
  final _materialControllers = {
    for (final kind in PaintMaterialKind.values) kind: _MaterialControllers(),
  };

  PaintWorkType _workType = PaintWorkType.interiorWalls;
  _PaintAreaMode _areaMode = _PaintAreaMode.dimensions;
  List<OpeningDeduction> _openings = const [];
  int _painters = 1;
  int _helpers = 1;
  late final MeasurementSystem _system;

  @override
  void initState() {
    super.initState();
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    for (final controller in [_length, _height, _surfaces, _directArea]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _length,
      _height,
      _surfaces,
      _directArea,
      _painterCoefficient,
      _helperCoefficient,
      _painterWage,
      _helperWage,
    ]) {
      controller.dispose();
    }
    for (final controllers in _materialControllers.values) {
      controllers.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  double _number(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || !value.isFinite) {
      throw ArgumentError('Enter a valid number for $label.');
    }
    return value;
  }

  int _count(TextEditingController controller, String label) {
    final value = int.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      throw ArgumentError('$label must be a positive whole number.');
    }
    return value;
  }

  double _grossArea() {
    if (_areaMode == _PaintAreaMode.directArea) {
      return MeasurementPreferences.toSquareMetres(
        _number(_directArea, 'Gross area'),
        _system,
      );
    }
    return OpeningCalculator.grossArea(
      lengthMetres: MeasurementPreferences.toMetres(
        _number(_length, 'Length'),
        _system,
      ),
      heightMetres: MeasurementPreferences.toMetres(
        _number(_height, 'Height / width'),
        _system,
      ),
      surfaces: _count(_surfaces, 'Number of surfaces'),
    );
  }

  List<PaintMaterialInput> _materials() => [
    for (final kind in _workType.materials)
      PaintMaterialInput(
        kind: kind,
        coats: _count(_materialControllers[kind]!.coats, '${kind.label} coats'),
        coverage: _number(
          _materialControllers[kind]!.coverage,
          '${kind.label} coverage',
        ),
        wastagePercent: _number(
          _materialControllers[kind]!.wastage,
          '${kind.label} wastage',
        ),
        rate: _number(_materialControllers[kind]!.rate, '${kind.label} rate'),
      ),
  ];

  void _calculate() {
    try {
      final result = PaintCalculator.calculate(
        workType: _workType,
        grossArea: _grossArea(),
        openings: _openings,
        materials: _materials(),
        painterDaysPer10M2: _number(
          _painterCoefficient,
          'Painter productivity coefficient',
        ),
        helperDaysPer10M2: _number(
          _helperCoefficient,
          'Helper productivity coefficient',
        ),
        crew: {LabourRole.painter: _painters, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.painter: _number(_painterWage, 'Painter daily wage'),
          LabourRole.helper: _number(_helperWage, 'Helper daily wage'),
        },
      );
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaintResultScreen(result: result, system: _system),
        ),
      );
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  Widget _card(String title, IconData icon, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, icon: icon, compact: true),
            for (final child in children) ...[
              const SizedBox(height: 14),
              child,
            ],
          ],
        ),
      ),
    ),
  );

  String _area(double value) =>
      '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, _system), 2)} ${_system.areaUnit}';

  Widget _takeoffPreview() {
    try {
      final takeoff = OpeningCalculator.calculate(
        grossArea: _grossArea(),
        openings: _openings,
      );
      return Text(
        'Gross Area: ${_area(takeoff.grossArea)}\n'
        'Deductions: ${_area(takeoff.deductionArea)}\n'
        'Net Paint Area: ${_area(takeoff.netArea)}',
      );
    } on ArgumentError catch (error) {
      return Text(error.message.toString());
    }
  }

  Widget _crewSelector(
    String label,
    int current,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    initialValue: current,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final count in [1, 2, 3])
        DropdownMenuItem(value: count, child: Text('$count')),
    ],
    onChanged: (value) {
      if (value != null) setState(() => onChanged(value));
    },
  );

  Widget _materialFields(PaintMaterialKind kind) {
    final controllers = _materialControllers[kind]!;
    return Card(
      margin: const EdgeInsets.only(top: 14),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kind.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            DimensionInputField(
              controller: controllers.coats,
              label: '${kind.label} coats',
              unit: null,
              wholeNumber: true,
            ),
            const SizedBox(height: 12),
            DimensionInputField(
              controller: controllers.coverage,
              label: '${kind.label} ${kind.coverageLabel}',
              unit: null,
              useMeasurementSystem: false,
            ),
            const SizedBox(height: 12),
            DimensionInputField(
              controller: controllers.wastage,
              label: '${kind.label} wastage',
              unit: '%',
              useMeasurementSystem: false,
            ),
            const SizedBox(height: 12),
            DimensionInputField(
              controller: controllers.rate,
              label: '${kind.label} rate',
              unit: '₹ / ${kind.unit}',
              useMeasurementSystem: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Paint & Finishes',
    bodyBuilder: (context, padding) => SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paint & Finishes V2',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          const Text(
            'Estimate net quantities, material cost, labour and working days.',
          ),
          const SizedBox(height: 20),
          _card('Work Type', Icons.format_paint_rounded, [
            DropdownButtonFormField<PaintWorkType>(
              initialValue: _workType,
              decoration: const InputDecoration(labelText: 'Finish category'),
              isExpanded: true,
              selectedItemBuilder: (context) => [
                for (final type in PaintWorkType.values)
                  Text(type.label, overflow: TextOverflow.ellipsis),
              ],
              items: [
                for (final type in PaintWorkType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (type) {
                if (type != null) setState(() => _workType = type);
              },
            ),
            Text(
              'Material coverage, wastage, rates and labour productivity are '
              'product- and site-specific. Enter values from the product data '
              'sheet and site plan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
          _card('Area Input', Icons.straighten_rounded, [
            SegmentedButton<_PaintAreaMode>(
              segments: const [
                ButtonSegment(
                  value: _PaintAreaMode.dimensions,
                  label: Text('Dimensions'),
                ),
                ButtonSegment(
                  value: _PaintAreaMode.directArea,
                  label: Text('Direct Area'),
                ),
              ],
              selected: {_areaMode},
              onSelectionChanged: (value) =>
                  setState(() => _areaMode = value.first),
            ),
            if (_areaMode == _PaintAreaMode.dimensions) ...[
              DimensionInputField(controller: _length, label: 'Surface length'),
              DimensionInputField(
                controller: _height,
                label: 'Surface height / width',
              ),
              DimensionInputField(
                controller: _surfaces,
                label: 'Number of surfaces',
                unit: null,
                wholeNumber: true,
              ),
            ] else
              DimensionInputField(
                controller: _directArea,
                label: 'Gross paint area',
                unit: _system.areaUnit,
                useMeasurementSystem: false,
              ),
          ]),
          _card('Opening Deductions', Icons.door_front_door_outlined, [
            OpeningDeductionsEditor(
              onChanged: (openings) => setState(() => _openings = openings),
            ),
            _takeoffPreview(),
          ]),
          _card('Material Requirement', Icons.inventory_2_outlined, [
            const Text(
              'Coverage and consumption are editable. Liquid material coverage '
              'is m²/L/coat; putty is m²/kg/coat; texture uses kg/m²/coat.',
            ),
            for (final kind in _workType.materials) _materialFields(kind),
          ]),
          _card('Labour & Time', Icons.groups_outlined, [
            const Text(
              'No default paint productivity is used. Enter site-specific '
              'labour days per 10 m²; SiteQuant calculates mandays and duration.',
            ),
            DimensionInputField(
              controller: _painterCoefficient,
              label: 'Painter coefficient',
              unit: 'day / 10 m²',
              useMeasurementSystem: false,
            ),
            DimensionInputField(
              controller: _helperCoefficient,
              label: 'Helper coefficient',
              unit: 'day / 10 m²',
              useMeasurementSystem: false,
            ),
            _crewSelector(
              'Painters in crew',
              _painters,
              (value) => _painters = value,
            ),
            _crewSelector(
              'Helpers in crew',
              _helpers,
              (value) => _helpers = value,
            ),
            const Text(
              'Duration uses the controlling role requirement. Crew is limited '
              'to 1–3 people per role and assumes enough work fronts.',
            ),
          ]),
          _card('Daily Wages', Icons.badge_outlined, [
            DimensionInputField(
              controller: _painterWage,
              label: 'Painter daily wage',
              unit: '₹ / day',
              useMeasurementSystem: false,
            ),
            DimensionInputField(
              controller: _helperWage,
              label: 'Helper daily wage',
              unit: '₹ / day',
              useMeasurementSystem: false,
            ),
          ]),
          PrimaryButton(
            onPressed: _calculate,
            icon: Icons.calculate_rounded,
            label: 'Calculate Paint Estimate',
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
