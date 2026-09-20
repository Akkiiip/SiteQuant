import 'package:flutter/material.dart';

import '../models/opening_deduction.dart';
import '../models/productivity_standard.dart';
import '../models/tile_result.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../services/tile_calculator.dart';
import '../services/tile_reference_defaults.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/opening_deductions_editor.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'tile_result_screen.dart';

class TileScreen extends StatefulWidget {
  const TileScreen({super.key});
  @override
  State<TileScreen> createState() => _TileScreenState();
}

class _TileScreenState extends State<TileScreen> {
  final _length = TextEditingController(),
      _width = TextEditingController(),
      _area = TextEditingController(),
      _tileLength = TextEditingController(),
      _tileWidth = TextEditingController(),
      _tileRate = TextEditingController(),
      _wastage = TextEditingController(),
      _adhesiveConsumption = TextEditingController(),
      _adhesiveRate = TextEditingController(),
      _groutConsumption = TextEditingController(),
      _groutRate = TextEditingController(),
      _beddingThickness = TextEditingController(),
      _cementRate = TextEditingController(),
      _sandRate = TextEditingController(),
      _tileMasonProductivity = TextEditingController(),
      _helperProductivity = TextEditingController(),
      _tileMasonWage = TextEditingController(),
      _helperWage = TextEditingController();
  TileWorkType _workType = TileWorkType.floorTiles;
  bool _directArea = false,
      _customTile = false,
      _advanced = false,
      _adhesive = true,
      _grout = true,
      _bedding = false;
  int _tileMasons = 1, _helpers = 1;
  List<OpeningDeduction> _openings = [];
  late final MeasurementSystem _system;

  List<TextEditingController> get _controllers => [
    _length,
    _width,
    _area,
    _tileLength,
    _tileWidth,
    _tileRate,
    _wastage,
    _adhesiveConsumption,
    _adhesiveRate,
    _groutConsumption,
    _groutRate,
    _beddingThickness,
    _cementRate,
    _sandRate,
    _tileMasonProductivity,
    _helperProductivity,
    _tileMasonWage,
    _helperWage,
  ];

  @override
  void initState() {
    super.initState();
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    _applyPreset();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyPreset() {
    final p = TileReferenceDefaults.forWorkType(_workType);
    _tileLength.text = p.tileLengthMm.toStringAsFixed(0);
    _tileWidth.text = p.tileWidthMm.toStringAsFixed(0);
    _tileRate.text = p.tileRatePerSquareMetre.toStringAsFixed(0);
    _wastage.text = p.tileWastagePercent.toStringAsFixed(0);
    _adhesiveConsumption.text = p.adhesiveConsumptionKgPerSquareMetre
        .toString();
    _adhesiveRate.text = p.adhesiveRatePerKg.toStringAsFixed(0);
    _groutConsumption.text = p.groutConsumptionKgPerSquareMetre.toString();
    _groutRate.text = p.groutRatePerKg.toStringAsFixed(0);
    _beddingThickness.text = p.beddingThicknessMm.toStringAsFixed(0);
    _cementRate.text = p.cementRatePerBag.toStringAsFixed(0);
    _sandRate.text = p.sandRatePerCubicMetre.toStringAsFixed(0);
    _tileMasonProductivity.text = p.tileMasonDaysPer10M2.toString();
    _helperProductivity.text = p.helperDaysPer10M2.toString();
    _tileMasonWage.text = p.tileMasonDailyWage.toStringAsFixed(0);
    _helperWage.text = p.helperDailyWage.toStringAsFixed(0);
  }

  double _number(TextEditingController c, String label) {
    final v = double.tryParse(c.text.trim());
    if (v == null || !v.isFinite) {
      throw ArgumentError('Enter a valid number for $label.');
    }
    return v;
  }

  double _grossArea() => _directArea
      ? MeasurementPreferences.toSquareMetres(_number(_area, 'Area'), _system)
      : OpeningCalculator.grossArea(
          lengthMetres: MeasurementPreferences.toMetres(
            _number(_length, 'Length'),
            _system,
          ),
          heightMetres: MeasurementPreferences.toMetres(
            _number(_width, 'Width'),
            _system,
          ),
        );

  void _calculate() {
    try {
      final p = TileReferenceDefaults.forWorkType(_workType);
      final result = TileCalculator.calculate(
        workType: _workType,
        grossArea: _grossArea(),
        openings: _openings,
        tileLengthMm: _number(_tileLength, 'Tile length'),
        tileWidthMm: _number(_tileWidth, 'Tile width'),
        tileWastagePercent: _number(_wastage, 'Tile wastage'),
        tileRatePerSquareMetre: _number(_tileRate, 'Tile rate'),
        includeAdhesive: _adhesive,
        adhesiveConsumptionKgPerSquareMetre: _number(
          _adhesiveConsumption,
          'Adhesive consumption',
        ),
        adhesiveWastagePercent: 5,
        adhesiveRatePerKg: _number(_adhesiveRate, 'Adhesive rate'),
        includeGrout: _grout,
        groutConsumptionKgPerSquareMetre: _number(
          _groutConsumption,
          'Grout consumption',
        ),
        groutWastagePercent: 5,
        groutRatePerKg: _number(_groutRate, 'Grout rate'),
        includeBedding: _bedding,
        beddingThicknessMm: _number(_beddingThickness, 'Bedding thickness'),
        cementRatePerBag: _number(_cementRate, 'Cement rate'),
        sandRatePerCubicMetre: _number(_sandRate, 'Sand rate'),
        tileMasonDaysPer10M2: _number(
          _tileMasonProductivity,
          'Tile Mason productivity',
        ),
        helperDaysPer10M2: _number(_helperProductivity, 'Helper productivity'),
        crew: {LabourRole.tileMason: _tileMasons, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.tileMason: _number(_tileMasonWage, 'Tile Mason wage'),
          LabourRole.helper: _number(_helperWage, 'Helper wage'),
        },
        referenceNote: p.note,
      );
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TileResultScreen(result: result)),
      );
    } on ArgumentError catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message.toString())));
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
  Widget _crew(String label, int value, ValueChanged<int> changed) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final n in [1, 2, 3])
            DropdownMenuItem(value: n, child: Text('$n')),
        ],
        onChanged: (v) {
          if (v != null) {
            setState(() => changed(v));
          }
        },
      );
  Widget _areaPreview() {
    try {
      final t = OpeningCalculator.calculate(
        grossArea: _grossArea(),
        openings: _openings,
      );
      String a(double v) =>
          '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(v, _system), 2)} ${_system.areaUnit}';
      return Text(
        'Gross Area: ${a(t.grossArea)}\nDeductions: ${a(t.deductionArea)}\nNet Area: ${a(t.netArea)}',
      );
    } on ArgumentError catch (e) {
      return Text(e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TileReferenceDefaults.forWorkType(_workType);
    return AppScaffold(
      title: 'Tiles & Flooring',
      bodyBuilder: (context, padding) => SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiles & Flooring',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Estimate tile quantities, materials, labour and working days.',
            ),
            const SizedBox(height: 20),
            _card('Work Type', Icons.grid_view_rounded, [
              DropdownButtonFormField<TileWorkType>(
                initialValue: _workType,
                decoration: const InputDecoration(labelText: 'Work Type'),
                items: [
                  for (final t in TileWorkType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _workType = v;
                      if (!_advanced) {
                        _applyPreset();
                      }
                    });
                  }
                },
              ),
              const Text(
                'Standard Reference is selected. Technical assumptions are optional.',
              ),
            ]),
            _card('Measurement', Icons.straighten_rounded, [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Dimensions')),
                  ButtonSegment(value: true, label: Text('Direct Area')),
                ],
                selected: {_directArea},
                onSelectionChanged: (v) =>
                    setState(() => _directArea = v.first),
              ),
              if (_directArea)
                DimensionInputField(
                  controller: _area,
                  label: 'Gross tile area',
                  unit: _system.areaUnit,
                  useMeasurementSystem: false,
                )
              else ...[
                DimensionInputField(
                  controller: _length,
                  label: _workType == TileWorkType.skirting
                      ? 'Skirting length'
                      : 'Length',
                ),
                const SizedBox(height: 12),
                DimensionInputField(
                  controller: _width,
                  label: _workType == TileWorkType.skirting
                      ? 'Skirting height'
                      : 'Width',
                ),
              ],
            ]),
            _card('Opening Deductions', Icons.door_front_door_outlined, [
              OpeningDeductionsEditor(
                onChanged: (v) => setState(() => _openings = v),
              ),
              _areaPreview(),
            ]),
            _card('Tile', Icons.dashboard_outlined, [
              DropdownButtonFormField<String>(
                initialValue: _customTile
                    ? 'Custom'
                    : '${_tileLength.text}x${_tileWidth.text}',
                decoration: const InputDecoration(labelText: 'Tile Size'),
                items: const [
                  DropdownMenuItem(
                    value: '300x300',
                    child: Text('300 x 300 mm'),
                  ),
                  DropdownMenuItem(
                    value: '300x450',
                    child: Text('300 x 450 mm'),
                  ),
                  DropdownMenuItem(
                    value: '300x600',
                    child: Text('300 x 600 mm'),
                  ),
                  DropdownMenuItem(
                    value: '600x600',
                    child: Text('600 x 600 mm'),
                  ),
                  DropdownMenuItem(
                    value: '600x1200',
                    child: Text('600 x 1200 mm'),
                  ),
                  DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _customTile = v == 'Custom';
                      if (!_customTile) {
                        final s = v.split('x');
                        _tileLength.text = s.first;
                        _tileWidth.text = s.last;
                      }
                    });
                  }
                },
              ),
              if (_customTile) ...[
                DimensionInputField(
                  controller: _tileLength,
                  label: 'Tile length',
                  unit: 'mm',
                  useMeasurementSystem: false,
                ),
                const SizedBox(height: 12),
                DimensionInputField(
                  controller: _tileWidth,
                  label: 'Tile width',
                  unit: 'mm',
                  useMeasurementSystem: false,
                ),
              ],
              DimensionInputField(
                controller: _wastage,
                label: 'Reference wastage',
                unit: '%',
                useMeasurementSystem: false,
              ),
              DimensionInputField(
                controller: _tileRate,
                label: 'Reference tile rate',
                unit: 'Rs. / m2',
                useMeasurementSystem: false,
              ),
            ]),
            _card('Materials', Icons.inventory_2_outlined, [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include Tile Adhesive'),
                value: _adhesive,
                onChanged: (v) => setState(() => _adhesive = v),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include Grout'),
                value: _grout,
                onChanged: (v) => setState(() => _grout = v),
              ),
              if (_workType == TileWorkType.floorTiles)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include Cement-Sand Bedding'),
                  value: _bedding,
                  onChanged: (v) => setState(() => _bedding = v),
                ),
            ]),
            _card('Labour & Crew', Icons.groups_outlined, [
              _crew('Tile Masons in crew', _tileMasons, (v) => _tileMasons = v),
              const SizedBox(height: 12),
              _crew('Helpers in crew', _helpers, (v) => _helpers = v),
              const Text(
                'Reference productivity is used. Working days follow the controlling role.',
              ),
            ]),
            _card('Wages', Icons.badge_outlined, [
              DimensionInputField(
                controller: _tileMasonWage,
                label: 'Reference Tile Mason wage',
                unit: 'Rs. / day',
                useMeasurementSystem: false,
              ),
              const SizedBox(height: 12),
              DimensionInputField(
                controller: _helperWage,
                label: 'Reference Helper wage',
                unit: 'Rs. / day',
                useMeasurementSystem: false,
              ),
            ]),
            _card('Advanced Reference Assumptions', Icons.tune_rounded, [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Custom assumptions'),
                subtitle: const Text(
                  'Override reference consumption, productivity and bedding values.',
                ),
                value: _advanced,
                onChanged: (v) => setState(() {
                  _advanced = v;
                  if (!v) _applyPreset();
                }),
              ),
              if (_advanced) ...[
                DimensionInputField(
                  controller: _adhesiveConsumption,
                  label: 'Adhesive consumption',
                  unit: 'kg / m2',
                  useMeasurementSystem: false,
                ),
                DimensionInputField(
                  controller: _adhesiveRate,
                  label: 'Adhesive rate',
                  unit: 'Rs. / kg',
                  useMeasurementSystem: false,
                ),
                DimensionInputField(
                  controller: _groutConsumption,
                  label: 'Grout consumption',
                  unit: 'kg / m2',
                  useMeasurementSystem: false,
                ),
                DimensionInputField(
                  controller: _groutRate,
                  label: 'Grout rate',
                  unit: 'Rs. / kg',
                  useMeasurementSystem: false,
                ),
                if (_bedding) ...[
                  DimensionInputField(
                    controller: _beddingThickness,
                    label: 'Bedding thickness',
                    unit: 'mm',
                    useMeasurementSystem: false,
                  ),
                  DimensionInputField(
                    controller: _cementRate,
                    label: 'Cement rate',
                    unit: 'Rs. / bag',
                    useMeasurementSystem: false,
                  ),
                  DimensionInputField(
                    controller: _sandRate,
                    label: 'Sand rate',
                    unit: 'Rs. / m3',
                    useMeasurementSystem: false,
                  ),
                ],
                DimensionInputField(
                  controller: _tileMasonProductivity,
                  label: 'Tile Mason days / 10 m2',
                  unit: 'days',
                  useMeasurementSystem: false,
                ),
                DimensionInputField(
                  controller: _helperProductivity,
                  label: 'Helper days / 10 m2',
                  unit: 'days',
                  useMeasurementSystem: false,
                ),
              ],
              Text(p.note),
            ]),
            PrimaryButton(
              onPressed: _calculate,
              icon: Icons.calculate_rounded,
              label: 'Calculate Tiles & Flooring',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
