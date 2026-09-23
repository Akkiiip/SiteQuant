import 'package:flutter/material.dart';

import '../models/opening_deduction.dart';
import '../models/productivity_standard.dart';
import '../models/tile_result.dart';
import '../services/analytics_service.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../services/tile_calculator.dart';
import '../services/tile_reference_defaults.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/opening_deductions_editor.dart';
import '../widgets/tile_diagram.dart';
import 'tile_result_screen.dart';

class TileCalculatorScreen extends StatefulWidget {
  const TileCalculatorScreen({super.key, required this.type});
  final TileWorkType type;
  @override
  State<TileCalculatorScreen> createState() => _TileCalculatorScreenState();
}

class _TileCalculatorScreenState extends State<TileCalculatorScreen> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _area = TextEditingController();
  final _tileLength = TextEditingController();
  final _tileWidth = TextEditingController();
  final _wastage = TextEditingController();
  final _tileRate = TextEditingController();
  final _adhesiveConsumption = TextEditingController();
  final _adhesiveWastage = TextEditingController();
  final _adhesiveRate = TextEditingController();
  final _groutConsumption = TextEditingController();
  final _groutWastage = TextEditingController();
  final _groutRate = TextEditingController();
  final _beddingThickness = TextEditingController();
  final _cementRate = TextEditingController();
  final _sandRate = TextEditingController();
  final _masonProductivity = TextEditingController();
  final _helperProductivity = TextEditingController();
  final _masonWage = TextEditingController();
  final _helperWage = TextEditingController();
  late TileWorkType _type;
  late MeasurementSystem _system;
  bool _directArea = false;
  bool _adhesive = true;
  bool _grout = true;
  bool _bedding = false;
  String _tileSize = '600x600';
  int _masons = 1, _helpers = 1;
  List<OpeningDeduction> _openings = [];

  List<TextEditingController> get _controllers => [
    _length,
    _width,
    _quantity,
    _area,
    _tileLength,
    _tileWidth,
    _wastage,
    _tileRate,
    _adhesiveConsumption,
    _adhesiveWastage,
    _adhesiveRate,
    _groutConsumption,
    _groutWastage,
    _groutRate,
    _beddingThickness,
    _cementRate,
    _sandRate,
    _masonProductivity,
    _helperProductivity,
    _masonWage,
    _helperWage,
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    _applyReference();
    AnalyticsService.logCalculatorOpened('tiles');
  }

  void _applyReference() {
    final p = TileReferenceDefaults.forWorkType(_type);
    _tileLength.text = '${p.tileLengthMm.toInt()}';
    _tileWidth.text = '${p.tileWidthMm.toInt()}';
    _tileSize = '${p.tileLengthMm.toInt()}x${p.tileWidthMm.toInt()}';
    _wastage.text = '${p.tileWastagePercent}';
    _tileRate.text = '${p.tileRatePerSquareMetre}';
    _adhesiveConsumption.text = '${p.adhesiveConsumptionKgPerSquareMetre}';
    _adhesiveWastage.text = '${p.adhesiveWastagePercent}';
    _adhesiveRate.text = '${p.adhesiveRatePerKg}';
    _groutConsumption.text = '${p.groutConsumptionKgPerSquareMetre}';
    _groutWastage.text = '${p.groutWastagePercent}';
    _groutRate.text = '${p.groutRatePerKg}';
    _beddingThickness.text = '${p.beddingThicknessMm}';
    _cementRate.text = '${p.cementRatePerBag}';
    _sandRate.text = '${p.sandRatePerCubicMetre}';
    _masonProductivity.text = '${p.tileMasonDaysPer10M2}';
    _helperProductivity.text = '${p.helperDaysPer10M2}';
    _masonWage.text = '${p.tileMasonDailyWage}';
    _helperWage.text = '${p.helperDailyWage}';
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _number(TextEditingController c, String label) {
    final n = double.tryParse(c.text.trim());
    if (n == null || !n.isFinite) {
      throw ArgumentError('Enter a valid $label.');
    }
    return n;
  }

  double _grossArea() {
    if (_directArea) {
      return MeasurementPreferences.toSquareMetres(
        _number(_area, 'gross area'),
        _system,
      );
    }
    final count = int.tryParse(_quantity.text.trim());
    if (count == null || count <= 0) {
      throw ArgumentError('Quantity must be a positive whole number.');
    }
    return OpeningCalculator.grossArea(
      lengthMetres: MeasurementPreferences.toMetres(
        _number(_length, 'length'),
        _system,
      ),
      heightMetres: MeasurementPreferences.toMetres(
        _number(_width, 'height / width'),
        _system,
      ),
      surfaces: count,
    );
  }

  void _calculate() {
    try {
      final p = TileReferenceDefaults.forWorkType(_type);
      final result = TileCalculator.calculate(
        workType: _type,
        grossArea: _grossArea(),
        openings: _openings,
        tileLengthMm: _number(_tileLength, 'tile length'),
        tileWidthMm: _number(_tileWidth, 'tile width'),
        tileWastagePercent: _number(_wastage, 'tile wastage'),
        tileRatePerSquareMetre: _number(_tileRate, 'tile rate'),
        includeAdhesive: _adhesive,
        adhesiveConsumptionKgPerSquareMetre: _number(
          _adhesiveConsumption,
          'adhesive consumption',
        ),
        adhesiveWastagePercent: _number(_adhesiveWastage, 'adhesive wastage'),
        adhesiveRatePerKg: _number(_adhesiveRate, 'adhesive rate'),
        includeGrout: _grout,
        groutConsumptionKgPerSquareMetre: _number(
          _groutConsumption,
          'grout consumption',
        ),
        groutWastagePercent: _number(_groutWastage, 'grout wastage'),
        groutRatePerKg: _number(_groutRate, 'grout rate'),
        includeBedding: _bedding && _type == TileWorkType.floorTiles,
        beddingThicknessMm: _number(_beddingThickness, 'bedding thickness'),
        cementRatePerBag: _number(_cementRate, 'cement rate'),
        sandRatePerCubicMetre: _number(_sandRate, 'sand rate'),
        tileMasonDaysPer10M2: _number(
          _masonProductivity,
          'tile mason productivity',
        ),
        helperDaysPer10M2: _number(_helperProductivity, 'helper productivity'),
        crew: {LabourRole.tileMason: _masons, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.tileMason: _number(_masonWage, 'tile mason wage'),
          LabourRole.helper: _number(_helperWage, 'helper wage'),
        },
        referenceNote: p.note,
      );
      FocusScope.of(context).unfocus();
      AnalyticsService.logCalculationCompleted('tiles', workType: _type.name);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TileResultScreen(result: result)),
      );
    } on ArgumentError catch (error) {
      AnalyticsService.logCalculationError('tiles', 'invalid_input');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  Widget _card(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? unit = 'm',
    bool whole = false,
    bool system = true,
  }) => DimensionInputField(
    controller: controller,
    label: label,
    unit: unit,
    wholeNumber: whole,
    useMeasurementSystem: system,
  );

  Widget _crew(String label, int value, ValueChanged<int> changed) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final n in [1, 2, 3])
            DropdownMenuItem(value: n, child: Text('$n')),
        ],
        onChanged: (n) {
          if (n != null) setState(() => changed(n));
        },
      );

  Widget _areaPreview() {
    try {
      final t = OpeningCalculator.calculate(
        grossArea: _grossArea(),
        openings: _openings,
      );
      String a(double value) =>
          '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, _system), 2)} ${_system.areaUnit}';
      return Text(
        'Gross ${a(t.grossArea)}  ·  Deductions ${a(t.deductionArea)}  ·  Net ${a(t.netArea)}',
      );
    } on ArgumentError {
      return const Text('Enter dimensions to preview area.');
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Tiles & Flooring',
    bodyBuilder: (context, padding) => ListView(
      padding: padding,
      children: [
        const CalculatorHeader(
          title: 'Tiles & Flooring',
          subtitle: 'Tile quantities, materials, labour and cost',
        ),
        EngineeringDiagramCard(
          label: _type.label,
          diagram: TileDiagram(type: _type),
        ),
        const SizedBox(height: 10),
        CalculatorTypeTabs(
          labels: TileWorkType.values.map((type) => type.label).toList(),
          selected: _type.label,
          onSelected: (label) => setState(() {
            _type = TileWorkType.values.firstWhere(
              (type) => type.label == label,
            );
            if (_type == TileWorkType.floorTiles) _openings = [];
            _applyReference();
          }),
        ),
        const SizedBox(height: 10),
        MetricImperialToggle(
          onChanged: (system) {
            AnalyticsService.logUnitSystemChanged(
              fromSystem: _system.name,
              toSystem: system.name,
            );
            setState(() => _system = system);
          },
        ),
        const SizedBox(height: 12),
        _card('Area', [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Dimensions')),
              ButtonSegment(value: true, label: Text('Direct Area')),
            ],
            selected: {_directArea},
            onSelectionChanged: (s) => setState(() => _directArea = s.first),
          ),
          if (_directArea)
            _field(
              _area,
              'Gross tile area',
              unit: _system.areaUnit,
              system: false,
            )
          else ...[
            _field(
              _length,
              _type == TileWorkType.skirting
                  ? 'Perimeter length'
                  : _type == TileWorkType.wallTiles
                  ? 'Wall length'
                  : 'Length',
            ),
            _field(
              _width,
              _type == TileWorkType.skirting
                  ? 'Skirting height'
                  : _type == TileWorkType.wallTiles
                  ? 'Wall height'
                  : 'Width',
            ),
            _field(
              _quantity,
              'Quantity',
              unit: null,
              whole: true,
              system: false,
            ),
          ],
          _areaPreview(),
        ]),
        if (_type != TileWorkType.floorTiles)
          _card('Opening Deductions', [
            OpeningDeductionsEditor(
              onChanged: (openings) => setState(() => _openings = openings),
              onOpeningAdded: () => AnalyticsService.logOpeningAdded('tiles'),
            ),
          ]),
        _card('Tile Specification', [
          DropdownButtonFormField<String>(
            key: ValueKey(_tileSize),
            initialValue: _tileSize,
            decoration: const InputDecoration(labelText: 'Tile Size'),
            items: [
              for (final size in [
                '300x300',
                '300x450',
                '300x600',
                '600x600',
                '600x1200',
                'Custom',
              ])
                DropdownMenuItem(
                  value: size,
                  child: Text(
                    size == 'Custom'
                        ? size
                        : '${size.replaceAll('x', ' × ')} mm',
                  ),
                ),
            ],
            onChanged: (size) {
              if (size == null) return;
              setState(() {
                _tileSize = size;
                if (size != 'Custom') {
                  final parts = size.split('x');
                  _tileLength.text = parts[0];
                  _tileWidth.text = parts[1];
                }
              });
            },
          ),
          if (_tileSize == 'Custom') ...[
            _field(
              _tileLength,
              'Custom tile length',
              unit: 'mm',
              system: false,
            ),
            _field(_tileWidth, 'Custom tile width', unit: 'mm', system: false),
          ],
          _field(
            _wastage,
            'Editable Reference · tile wastage',
            unit: '%',
            system: false,
          ),
          _field(
            _tileRate,
            'Editable Reference · tile rate',
            unit: '₹ / m²',
            system: false,
          ),
        ]),
        CalculatorAdvancedOptions(
          children: [
            const Text(
              'Editable reference assumptions — confirm against the selected product and site. Not current market rates.',
            ),
            SwitchListTile.adaptive(
              title: const Text('Adhesive'),
              value: _adhesive,
              onChanged: (v) => setState(() => _adhesive = v),
            ),
            if (_adhesive) ...[
              _field(
                _adhesiveConsumption,
                'Adhesive consumption',
                unit: 'kg / m²',
                system: false,
              ),
              _field(
                _adhesiveWastage,
                'Adhesive wastage',
                unit: '%',
                system: false,
              ),
              _field(
                _adhesiveRate,
                'Adhesive rate',
                unit: '₹ / kg',
                system: false,
              ),
            ],
            SwitchListTile.adaptive(
              title: const Text('Grout'),
              value: _grout,
              onChanged: (v) => setState(() => _grout = v),
            ),
            if (_grout) ...[
              _field(
                _groutConsumption,
                'Grout consumption',
                unit: 'kg / m²',
                system: false,
              ),
              _field(_groutWastage, 'Grout wastage', unit: '%', system: false),
              _field(_groutRate, 'Grout rate', unit: '₹ / kg', system: false),
            ],
            if (_type == TileWorkType.floorTiles) ...[
              SwitchListTile.adaptive(
                title: const Text('Cement-sand bedding'),
                value: _bedding,
                onChanged: (v) => setState(() => _bedding = v),
              ),
              if (_bedding) ...[
                _field(
                  _beddingThickness,
                  'Bedding thickness',
                  unit: 'mm',
                  system: false,
                ),
                _field(
                  _cementRate,
                  'Cement rate',
                  unit: '₹ / bag',
                  system: false,
                ),
                _field(_sandRate, 'Sand rate', unit: '₹ / m³', system: false),
              ],
            ],
            _field(
              _masonProductivity,
              'Tile Mason days / 10 m²',
              unit: 'days',
              system: false,
            ),
            _field(
              _helperProductivity,
              'Helper days / 10 m²',
              unit: 'days',
              system: false,
            ),
            _crew('Tile Masons in crew', _masons, (v) => _masons = v),
            _crew('Helpers in crew', _helpers, (v) => _helpers = v),
            _field(
              _masonWage,
              'Tile Mason daily wage',
              unit: '₹ / day',
              system: false,
            ),
            _field(
              _helperWage,
              'Helper daily wage',
              unit: '₹ / day',
              system: false,
            ),
          ],
        ),
        const SizedBox(height: 12),
        CalculatorCalculateButton(
          label: 'Calculate Tiles & Flooring',
          onPressed: _calculate,
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}
