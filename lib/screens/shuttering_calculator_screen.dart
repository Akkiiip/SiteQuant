import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/calculator_ui.dart';
import '../models/shuttering_result.dart';
import '../models/productivity_standard.dart';
import '../services/shuttering_calculator.dart';
import '../services/shuttering_reference_defaults.dart';
import '../services/measurement_system.dart';
import '../services/estimate_validation.dart';
import '../widgets/shuttering_diagram.dart';
import '../widgets/bottom_banner_slot.dart';
import '../services/analytics_service.dart';
import 'shuttering_result_screen.dart';

class ShutteringCalculatorScreen extends StatefulWidget {
  final ShutteringType type;
  const ShutteringCalculatorScreen({super.key, required this.type});
  @override
  State<ShutteringCalculatorScreen> createState() =>
      _ShutteringCalculatorScreenState();
}

class _ShutteringCalculatorScreenState
    extends State<ShutteringCalculatorScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  int _carpenters = 1, _helpers = 1, _sides = 2;
  late MeasurementSystem _system;
  String? _error;
  bool get _slab => widget.type == ShutteringType.slab;
  String get _widthLabel =>
      widget.type == ShutteringType.wall ? 'Thickness' : 'Width';
  String get _heightLabel =>
      widget.type == ShutteringType.beam ||
          widget.type == ShutteringType.footing
      ? 'Depth'
      : 'Height';

  @override
  void initState() {
    super.initState();
    _system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    const d = ShutteringReferenceDefaults.standard;
    final values = <String, String>{
      'Length': '',
      'Width': '',
      'Height': '',
      'Quantity': '1',
      'Material rate': '${d.ratePerSquareMetre}',
      'Panel wastage': '${d.wastagePercent}',
      'Carpenter wage': '${d.carpenterDailyWage}',
      'Helper wage': '${d.helperDailyWage}',
      'Carpenter productivity': '${d.carpenterDaysPer10M2}',
      'Helper productivity': '${d.helperDaysPer10M2}',
    };
    for (final entry in values.entries) {
      _fields[entry.key] = TextEditingController(text: entry.value);
    }
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _value(String key) => double.parse(_fields[key]!.text.trim());
  double _metres(String key) =>
      MeasurementPreferences.toMetres(_value(key), _system);

  Widget _field(
    String key,
    String label,
    String unit, {
    bool count = false,
    bool zero = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      key: ValueKey(key),
      controller: _fields[key],
      keyboardType: TextInputType.numberWithOptions(decimal: !count),
      decoration: InputDecoration(labelText: label, suffixText: unit),
      validator: (text) {
        try {
          if (count) {
            EstimateValidation.count(
              int.tryParse(text?.trim() ?? '') ?? 0,
              label,
            );
          } else {
            EstimateValidation.number(
              double.tryParse(text?.trim() ?? '') ?? double.nan,
              label,
              allowZero: zero,
            );
          }
          return null;
        } on ArgumentError {
          return count
              ? 'Quantity must be at least 1 (whole number).'
              : 'Enter a valid ${label.toLowerCase()}${zero ? ' (zero or more)' : ' greater than zero'}.';
        }
      },
    ),
  );
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
  Widget _crew(String label, int value, ValueChanged<int> change) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final n in [1, 2, 3])
          DropdownMenuItem(value: n, child: Text('$n')),
      ],
      onChanged: (v) {
        if (v != null) {
          setState(() => change(v));
        }
      },
    ),
  );

  void _calculate() {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) {
      return;
    }
    try {
      final result = ShutteringCalculator.calculate(
        type: widget.type,
        length: _metres('Length'),
        width: _metres('Width'),
        // Phase 1 requires a positive height even for its height-independent slab formula.
        height: _slab ? 1 : _metres('Height'),
        quantity: int.parse(_fields['Quantity']!.text.trim()),
        wallSides: _sides,
        wastagePercent: _value('Panel wastage'),
        materialRate: _value('Material rate'),
        carpenterDaysPer10M2: _value('Carpenter productivity'),
        helperDaysPer10M2: _value('Helper productivity'),
        crew: {LabourRole.carpenter: _carpenters, LabourRole.helper: _helpers},
        dailyWages: {
          LabourRole.carpenter: _value('Carpenter wage'),
          LabourRole.helper: _value('Helper wage'),
        },
      );
      FocusScope.of(context).unfocus();
      AnalyticsService.logCalculationCompleted(
        'shuttering',
        workType: widget.type.name,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShutteringResultScreen(result: result),
        ),
      );
    } on ArgumentError {
      setState(
        () => _error =
            'Check the dimensions, quantity and material/labour settings. Use finite values within a practical range.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text('Shuttering'),
        backgroundColor: AppTheme.pageBackground,
        foregroundColor: AppTheme.ink,
      ),
      bottomNavigationBar: const BottomBannerSlot(),
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
                    widget.type.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ShutteringDiagram(type: widget.type, wallSides: _sides),
                ]),
                MetricImperialToggle(
                  onChanged: (value) => setState(() => _system = value),
                ),
                const SizedBox(height: 12),
                _card([
                  Text(
                    'Dimensions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _field('Length', 'Length', _system.lengthUnit),
                  _field('Width', _widthLabel, _system.lengthUnit),
                  if (!_slab)
                    _field('Height', _heightLabel, _system.lengthUnit),
                  _field('Quantity', 'Quantity', 'nos', count: true),
                  if (widget.type == ShutteringType.wall)
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('One Side')),
                        ButtonSegment(value: 2, label: Text('Two Sides')),
                      ],
                      selected: {_sides},
                      onSelectionChanged: (s) =>
                          setState(() => _sides = s.first),
                    ),
                ]),
                _card([
                  Text('Crew', style: Theme.of(context).textTheme.titleLarge),
                  _crew('Carpenters', _carpenters, (v) => _carpenters = v),
                  _crew('Helpers', _helpers, (v) => _helpers = v),
                ]),
                _card([
                  ExpansionTile(
                    title: const Text('Material & Labour Settings'),
                    maintainState: true,
                    children: [
                      const Text('Reference values — editable'),
                      const Text(
                        'Material-only rate per panel m². Labour is added separately; do not enter a combined contractor rate.',
                      ),
                      _field('Material rate', 'Material rate', '₹/m²'),
                      _field('Panel wastage', 'Panel wastage', '%', zero: true),
                      _field('Carpenter wage', 'Carpenter wage', '₹/day'),
                      _field('Helper wage', 'Helper wage', '₹/day'),
                      _field(
                        'Carpenter productivity',
                        'Carpenter productivity',
                        'days/10 m²',
                      ),
                      _field(
                        'Helper productivity',
                        'Helper productivity',
                        'days/10 m²',
                      ),
                      Text(ShutteringReferenceDefaults.standard.note),
                    ],
                  ),
                ]),
                if (_error != null) _card([Text(_error!)]),
                CalculatorCalculateButton(
                  onPressed: _calculate,
                  label: 'Calculate Shuttering',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
