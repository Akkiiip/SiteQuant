import 'package:flutter/material.dart';
import '../models/opening_deduction.dart';
import '../services/analytics_service.dart';
import '../models/plaster_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../services/plaster_calculator.dart';
import '../services/plaster_productivity.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/opening_deductions_editor.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'plaster_result_screen.dart';

class PlasterScreen extends StatefulWidget {
  const PlasterScreen({super.key});
  @override
  State<PlasterScreen> createState() => _PlasterScreenState();
}

class _PlasterScreenState extends State<PlasterScreen> {
  final _length = TextEditingController(),
      _second = TextEditingController(),
      _walls = TextEditingController(text: '1'),
      _customThickness = TextEditingController(),
      _wastage = TextEditingController(text: '5'),
      _cementRate = TextEditingController(),
      _sandRate = TextEditingController(),
      _masonWage = TextEditingController(),
      _helperWage = TextEditingController(),
      _masonCoefficient = TextEditingController(),
      _helperCoefficient = TextEditingController();
  PlasterType _type = PlasterType.wall;
  String _thickness = '12', _ratio = '1 : 4';
  bool _siteProductivity = false;
  int _masons = 1, _helpers = 1;
  List<OpeningDeduction> _openings = [];
  late final MeasurementSystem _system;

  List<TextEditingController> get _controllers => [
    _length,
    _second,
    _walls,
    _customThickness,
    _wastage,
    _cementRate,
    _sandRate,
    _masonWage,
    _helperWage,
    _masonCoefficient,
    _helperCoefficient,
  ];

  @override
  void initState() {
    super.initState();
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    for (final controller in [_length, _second, _walls, _customThickness]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _value(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || !value.isFinite) {
      throw ArgumentError('Enter a valid number for $label.');
    }
    return value;
  }

  int _wallCount() {
    if (_type == PlasterType.ceiling) return 1;
    final count = int.tryParse(_walls.text.trim());
    if (count == null || count <= 0) {
      throw ArgumentError('Number of Walls must be a positive whole number.');
    }
    return count;
  }

  double _grossArea() => OpeningCalculator.grossArea(
    lengthMetres: MeasurementPreferences.toMetres(
      _value(_length, 'Length'),
      _system,
    ),
    heightMetres: MeasurementPreferences.toMetres(
      _value(_second, 'Height / width'),
      _system,
    ),
    surfaces: _wallCount(),
  );

  double _thicknessMm() => _thickness == 'Custom'
      ? _value(_customThickness, 'Thickness')
      : double.parse(_thickness);

  ProductivityStandard _standard() => _siteProductivity
      ? PlasterProductivity.siteSpecific(
          masonDaysPer10M2: _value(_masonCoefficient, 'Mason coefficient'),
          helperDaysPer10M2: _value(_helperCoefficient, 'Helper coefficient'),
        )
      : PlasterProductivity.forThickness(_thicknessMm());

  void _calculate() {
    try {
      final parts = _ratio.split(':');
      final result = PlasterCalculator.calculate(
        area: _grossArea(),
        openings: _openings,
        thicknessMm: _thicknessMm(),
        cementPart: double.parse(parts.first.trim()),
        sandPart: double.parse(parts.last.trim()),
        wastagePercent: _value(_wastage, 'Wastage'),
        cementRate: _value(_cementRate, 'Cement rate'),
        sandRate: _value(_sandRate, 'Sand rate'),
        crew: {LabourRole.mason: _masons, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.mason: _value(_masonWage, 'Mason daily wage'),
          LabourRole.helper: _value(_helperWage, 'Helper daily wage'),
        },
        productivityStandard: _standard(),
      );
      FocusScope.of(context).unfocus();
      AnalyticsService.logCalculationCompleted('plaster', workType: _type.name);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PlasterResultScreen(result: result, type: _type, system: _system),
        ),
      );
    } on ArgumentError catch (error) {
      AnalyticsService.logCalculationError('plaster', 'invalid_input');
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

  Widget _areaPreview() {
    try {
      final takeoff = OpeningCalculator.calculate(
        grossArea: _grossArea(),
        openings: _openings,
      );
      String area(double value) =>
          '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, _system), 2)} ${_system.areaUnit}';
      return Text(
        'Gross Area: ${area(takeoff.grossArea)}\n'
        'Deductions: ${area(takeoff.deductionArea)}\n'
        'Net Area: ${area(takeoff.netArea)}',
      );
    } on ArgumentError catch (error) {      return Text(error.message.toString());
    }
  }

  Widget _productivityPreview() {
    if (_siteProductivity) {
      return const Text(
        'Enter labour days per 10 m² of work, not total mandays. '
        'SiteQuant calculates the total requirement from net area.',
      );
    }
    try {
      final standard = _standard();
      final basis = MeasurementPreferences.fromSquareMetres(
        standard.baseQuantity,
        _system,
      );
      return Text(
        '${standard.name}\n'
        'Mason: ${EstimateFormat.number(standard.daysPerBaseQuantity[LabourRole.mason]!, 5)} day; '
        'Helper: ${EstimateFormat.number(standard.daysPerBaseQuantity[LabourRole.helper]!, 5)} day '
        'per ${EstimateFormat.number(basis, 2)} ${_system.areaUnit}.\n'
        '${standard.basis}',
      );
    } on ArgumentError catch (error) {      return Text(error.message.toString());
    }
  }

  Widget _crew(String label, int value, ValueChanged<int> changed) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final count in [1, 2, 3])
            DropdownMenuItem(value: count, child: Text('$count')),
        ],
        onChanged: (value) {
          if (value != null) setState(() => changed(value));
        },
      );

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Plaster Calculator',
    bodyBuilder: (context, padding) => SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plaster Takeoff V2',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          const Text(
            'Estimate net quantities, material cost, labour and working days.',
          ),
          const SizedBox(height: 20),
          _card('Plaster Type', Icons.format_paint_rounded, [
            SegmentedButton<PlasterType>(
              segments: const [
                ButtonSegment(
                  value: PlasterType.wall,
                  label: Text('Wall Plaster'),
                ),
                ButtonSegment(
                  value: PlasterType.ceiling,
                  label: Text('Ceiling Plaster'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (values) =>
                  setState(() => _type = values.first),
            ),
          ]),
          _card('Dimensions', Icons.straighten_rounded, [
            DimensionInputField(
              controller: _length,
              label: _type == PlasterType.wall ? 'Wall Length' : 'Length',
            ),
            DimensionInputField(
              controller: _second,
              label: _type == PlasterType.wall ? 'Wall Height' : 'Width',
            ),
            if (_type == PlasterType.wall)
              DimensionInputField(
                controller: _walls,
                label: 'Number of Walls',
                unit: null,
                wholeNumber: true,
              ),
          ]),
          _card('Opening Deductions', Icons.door_front_door_outlined, [
            OpeningDeductionsEditor(
              onChanged: (openings) => setState(() => _openings = openings),
              onOpeningAdded: () => AnalyticsService.logOpeningAdded('plaster'),
            ),
            _areaPreview(),
          ]),
          _card('Plaster Specification', Icons.tune_rounded, [
            DropdownButtonFormField<String>(
              initialValue: _thickness,
              decoration: const InputDecoration(labelText: 'Plaster Thickness'),
              items: [
                for (final value in ['12', '15', '20', 'Custom'])
                  DropdownMenuItem(
                    value: value,
                    child: Text(value == 'Custom' ? value : '$value mm'),
                  ),
              ],
              onChanged: (value) => setState(() => _thickness = value!),
            ),
            if (_thickness == 'Custom')
              DimensionInputField(
                controller: _customThickness,
                label: 'Thickness',
                unit: 'mm',
              ),
            DropdownButtonFormField<String>(
              initialValue: _ratio,
              decoration: const InputDecoration(labelText: 'Mortar Ratio'),
              items: [
                for (final value in ['1 : 3', '1 : 4', '1 : 5'])
                  DropdownMenuItem(value: value, child: Text(value)),
              ],
              onChanged: (value) => setState(() => _ratio = value!),
            ),
            DimensionInputField(
              controller: _wastage,
              label: 'Wastage',
              unit: '%',
            ),
          ]),
          _card('Material Rates', Icons.payments_outlined, [
            const Text(
              'Enter local rates. Sand is priced per m³ in either measurement system.',
            ),
            DimensionInputField(
              controller: _cementRate,
              label: 'Cement rate',
              unit: '₹ / 50 kg bag',
              useMeasurementSystem: false,
            ),
            DimensionInputField(
              controller: _sandRate,
              label: 'Sand rate',
              unit: '₹ / m³',
              useMeasurementSystem: false,
            ),
          ]),
          _card('Productivity & Crew', Icons.groups_outlined, [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use site-specific productivity'),
              value: _siteProductivity,
              onChanged: (value) => setState(() => _siteProductivity = value),
            ),
            _productivityPreview(),
            if (_siteProductivity) ...[
              DimensionInputField(
                controller: _masonCoefficient,
                label: 'Mason coefficient',
                unit: 'day / 10 m²',
                useMeasurementSystem: false,
              ),
              DimensionInputField(
                controller: _helperCoefficient,
                label: 'Helper coefficient',
                unit: 'day / 10 m²',
                useMeasurementSystem: false,
              ),
            ],
            _crew('Masons in crew', _masons, (value) => _masons = value),
            _crew('Helpers in crew', _helpers, (value) => _helpers = value),
            const Text(
              'Limited to 1–3 people per role. Duration assumes enough work '
              'fronts for the selected crew, with no congestion or delays. '
              'It is an estimate, not a guaranteed completion date.',
            ),
            if (_type == PlasterType.ceiling)
              const Text(
                'Ceiling work uses the same initial benchmarks. '
                'Use site-specific productivity for access and overhead working conditions.',
              ),
          ]),
          _card('Daily Wages', Icons.badge_outlined, [
            DimensionInputField(
              controller: _masonWage,
              label: 'Mason daily wage',
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
            label: 'Calculate Plaster',
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
