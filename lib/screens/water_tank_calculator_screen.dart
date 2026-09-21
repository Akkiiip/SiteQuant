import 'package:flutter/material.dart';

import '../models/productivity_standard.dart';
import '../models/water_tank_input.dart';
import '../services/estimate_validation.dart';
import '../services/measurement_system.dart';
import '../services/water_tank_calculator.dart';
import '../services/water_tank_reference_defaults.dart';
import '../widgets/water_tank_diagram.dart';
import 'water_tank_result_screen.dart';

class WaterTankCalculatorScreen extends StatefulWidget {
  const WaterTankCalculatorScreen({super.key, required this.type});
  final WaterTankType type;
  @override
  State<WaterTankCalculatorScreen> createState() =>
      _WaterTankCalculatorScreenState();
}

class _WaterTankCalculatorScreenState extends State<WaterTankCalculatorScreen> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _values;
  int _masons = 1, _helpers = 1;
  late final MeasurementSystem _system;
  bool get _circular => widget.type == WaterTankType.circular;

  @override
  void initState() {
    super.initState();
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    const d = WaterTankReferenceDefaults.standard;
    _values = {
      'Length': TextEditingController(),
      'Width': TextEditingController(),
      'Diameter': TextEditingController(),
      'Depth': TextEditingController(),
      'Wall thickness': TextEditingController(),
      'Base slab thickness': TextEditingController(),
      'Top slab thickness': TextEditingController(),
      'Quantity': TextEditingController(text: '1'),
      'RCC rate': TextEditingController(text: '${d.rccRatePerCubicMetre}'),
      'Mason productivity': TextEditingController(
        text: '${d.masonDaysPerCubicMetre}',
      ),
      'Helper productivity': TextEditingController(
        text: '${d.helperDaysPerCubicMetre}',
      ),
      'Mason wage': TextEditingController(text: '${d.masonDailyWage}'),
      'Helper wage': TextEditingController(text: '${d.helperDailyWage}'),
    };
  }

  @override
  void dispose() {
    for (final c in _values.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _number(String key) => double.parse(_values[key]!.text.trim());
  double _metres(String key) =>
      MeasurementPreferences.toMetres(_number(key), _system);
  Widget _field(
    String key,
    String label,
    String unit, {
    bool quantity = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: TextFormField(
      key: ValueKey(key),
      controller: _values[key],
      keyboardType: TextInputType.numberWithOptions(decimal: !quantity),
      decoration: InputDecoration(labelText: label, suffixText: unit),
      validator: (text) {
        try {
          if (quantity) {
            EstimateValidation.count(
              int.tryParse(text?.trim() ?? '') ?? 0,
              label,
            );
          } else {
            EstimateValidation.number(
              double.tryParse(text?.trim() ?? '') ?? double.nan,
              label,
            );
          }
          return null;
        } on ArgumentError {
          return quantity
              ? 'Quantity must be at least 1.'
              : 'Enter a valid ${label.toLowerCase()}.';
        }
      },
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
        onChanged: (value) {
          if (value != null) {
            setState(() => changed(value));
          }
        },
      );
  void _calculate() {
    if (!_form.currentState!.validate()) return;
    try {
      final diameter = _circular ? _metres('Diameter') : 0.0;
      final input = WaterTankInput(
        type: widget.type,
        internalLength: _circular ? diameter : _metres('Length'),
        internalWidthOrDiameter: _circular ? diameter : _metres('Width'),
        waterDepth: _metres('Depth'),
        wallThickness: _metres('Wall thickness'),
        baseSlabThickness: _metres('Base slab thickness'),
        topSlabThickness: _metres('Top slab thickness'),
        quantity: int.parse(_values['Quantity']!.text.trim()),
        rccRatePerCubicMetre: _number('RCC rate'),
        masonDaysPerCubicMetre: _number('Mason productivity'),
        helperDaysPerCubicMetre: _number('Helper productivity'),
        crew: {LabourRole.mason: _masons, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.mason: _number('Mason wage'),
          LabourRole.helper: _number('Helper wage'),
        },
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaterTankResultScreen(
            result: WaterTankCalculator.calculate(input),
          ),
        ),
      );
    } on ArgumentError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check the dimensions and material/labour settings.'),
        ),
      );
    }
  }

  Widget _card(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Water Tank')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card([
                Text(
                  _circular ? 'Circular RCC Tank' : 'Rectangular RCC Tank',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                WaterTankDiagram(type: widget.type),
              ]),
              _card([
                Text(
                  'Internal dimensions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_circular)
                  _field('Diameter', 'Internal Diameter', _system.lengthUnit)
                else ...[
                  _field('Length', 'Internal Length', _system.lengthUnit),
                  _field('Width', 'Internal Width', _system.lengthUnit),
                ],
                _field('Depth', 'Water Depth', _system.lengthUnit),
                _field('Wall thickness', 'Wall Thickness', _system.lengthUnit),
                _field(
                  'Base slab thickness',
                  'Base Slab Thickness',
                  _system.lengthUnit,
                ),
                _field(
                  'Top slab thickness',
                  'Top Slab Thickness',
                  _system.lengthUnit,
                ),
                _field('Quantity', 'Quantity', 'nos', quantity: true),
              ]),
              _card([
                Text('Crew', style: Theme.of(context).textTheme.titleLarge),
                _crew('Mason crew', _masons, (v) => _masons = v),
                const SizedBox(height: 12),
                _crew('Helper crew', _helpers, (v) => _helpers = v),
              ]),
              _card([
                ExpansionTile(
                  title: const Text('Material & Labour Settings'),
                  children: [
                    const Text('Reference values — editable'),
                    _field('RCC rate', 'RCC rate', '₹/m³'),
                    _field(
                      'Mason productivity',
                      'Mason productivity',
                      'days/m³',
                    ),
                    _field(
                      'Helper productivity',
                      'Helper productivity',
                      'days/m³',
                    ),
                    _field('Mason wage', 'Mason wage', '₹/day'),
                    _field('Helper wage', 'Helper wage', '₹/day'),
                    Text(WaterTankReferenceDefaults.standard.note),
                  ],
                ),
              ]),
              FilledButton(
                onPressed: _calculate,
                child: const Text('Calculate Water Tank'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
