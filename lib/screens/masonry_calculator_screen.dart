import 'package:flutter/material.dart';
import '../models/masonry_input.dart';
import '../models/masonry_result.dart';
import '../models/opening_deduction.dart';
import '../services/masonry_reference_defaults.dart';
import '../services/masonry_v2_calculator.dart';
import '../services/measurement_system.dart';
import '../services/analytics_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/masonry_diagram.dart';
import '../widgets/opening_deductions_editor.dart';
import 'masonry_v2_result_screen.dart';

class MasonryCalculatorScreen extends StatefulWidget {
  final MasonryType type;
  const MasonryCalculatorScreen({super.key, required this.type});
  @override
  State<MasonryCalculatorScreen> createState() =>
      _MasonryCalculatorScreenState();
}

class _MasonryCalculatorScreenState extends State<MasonryCalculatorScreen> {
  late MasonryReferencePreset p;
  final length = TextEditingController(),
      height = TextEditingController(),
      area = TextEditingController(),
      thickness = TextEditingController(),
      quantity = TextEditingController(text: '1'),
      rate = TextEditingController(),
      cementRate = TextEditingController(),
      sandRate = TextEditingController(),
      wastage = TextEditingController(),
      masonWage = TextEditingController(),
      helperWage = TextEditingController(),
      masonProductivity = TextEditingController(),
      helperProductivity = TextEditingController(),
      unitLength = TextEditingController(),
      unitWidth = TextEditingController(),
      unitHeight = TextEditingController();
  bool directArea = false, customizeUnitDimensions = false;
  int masons = 1, helpers = 1;
  List<OpeningDeduction> openings = [];
  @override
  void initState() {
    super.initState();
    p = MasonryReferenceDefaults.forType(widget.type);
    thickness.text = '${p.thicknessMm}';
    rate.text = '${p.unitRate}';
    cementRate.text = '${p.cementRatePerBag}';
    sandRate.text = '${p.sandRatePerM3}';
    wastage.text = '${p.wastagePercent}';
    masonWage.text = '${p.masonWage}';
    helperWage.text = '${p.helperWage}';
    masonProductivity.text = '${p.masonDaysPerM3}';
    helperProductivity.text = '${p.helperDaysPerM3}';
    _restoreStandardDimensions();
  }

  @override
  void dispose() {
    for (final c in [
      length,
      height,
      area,
      thickness,
      quantity,
      rate,
      cementRate,
      sandRate,
      wastage,
      masonWage,
      helperWage,
      masonProductivity,
      helperProductivity,
      unitLength,
      unitWidth,
      unitHeight,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? value(TextEditingController c, String label, {bool zero = false}) {
    final v = double.tryParse(c.text);
    if (v == null || v < (zero ? 0 : .00001)) {
      message('Enter a valid $label.');
      return null;
    }
    return v;
  }

  void message(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  String _dimensionValue(double value) =>
      value == value.truncateToDouble() ? value.toInt().toString() : '$value';

  void _restoreStandardDimensions() {
    unitLength.text = _dimensionValue(p.unitSize.lengthMm);
    unitWidth.text = _dimensionValue(p.unitSize.widthMm);
    unitHeight.text = _dimensionValue(p.unitSize.heightMm);
  }

  void _useStandardDimensions() {
    setState(() {
      _restoreStandardDimensions();
      customizeUnitDimensions = false;
    });
  }

  MasonryUnitSize? _selectedUnitSize() {
    if (!customizeUnitDimensions) return p.unitSize;
    final selectedLength = value(unitLength, 'unit length');
    final selectedWidth = value(unitWidth, 'unit width');
    final selectedHeight = value(unitHeight, 'unit height');
    if (selectedLength == null ||
        selectedWidth == null ||
        selectedHeight == null) {
      return null;
    }
    return MasonryUnitSize(
      lengthMm: selectedLength,
      widthMm: selectedWidth,
      heightMm: selectedHeight,
    );
  }

  void calculate() {
    final q = int.tryParse(quantity.text);
    final t = value(thickness, 'wall thickness');
    final gross = directArea ? value(area, 'wall area') : _dimensionArea(q);
    if (q == null || q < 1 || t == null || gross == null) {
      AnalyticsService.logCalculationError('masonry', 'invalid_input');
      message('Quantity must be at least 1.');
      return;
    }
    final selectedUnitSize = _selectedUnitSize();
    if (selectedUnitSize == null) {
      AnalyticsService.logCalculationError('masonry', 'invalid_input');
      return;
    }
    try {
      final r = MasonryV2Calculator.calculate(
        MasonryInput(
          type: widget.type,
          grossArea: gross,
          thicknessMm: t,
          unitSize: selectedUnitSize,
          openings: openings,
          cementPart: 1,
          sandPart: 6,
          wastagePercent: value(wastage, 'wastage', zero: true)!,
          unitRate: value(rate, 'material rate', zero: true)!,
          cementRatePerBag: value(cementRate, 'cement rate', zero: true)!,
          sandRatePerM3: value(sandRate, 'sand rate', zero: true)!,
          masonDaysPerM3: value(masonProductivity, 'mason productivity')!,
          helperDaysPerM3: value(helperProductivity, 'helper productivity')!,
          masonDailyWage: value(masonWage, 'mason wage', zero: true)!,
          helperDailyWage: value(helperWage, 'helper wage', zero: true)!,
          masons: masons,
          helpers: helpers,
        ),
      );
      AnalyticsService.logCalculationCompleted(
        'masonry',
        workType: widget.type.name,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MasonryV2ResultScreen(result: r)),
      );
    } catch (e) {
      AnalyticsService.logCalculationError('masonry', 'invalid_input');
      message(e.toString().replaceFirst('Invalid argument(s): ', ''));
    }
  }

  double? _dimensionArea(int? q) {
    final l = value(length, 'wall length'), h = value(height, 'wall height');
    if (l == null || h == null || q == null) return null;
    final s = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    return MeasurementPreferences.toMetres(l, s) *
        MeasurementPreferences.toMetres(h, s) *
        q;
  }

  Widget field(TextEditingController c, String label, String unit) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      key: Key(label),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, suffixText: unit),
    ),
  );
  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Masonry Calculator',
    bodyBuilder: (context, pad) => ListView(
      padding: pad,
      children: [
        CalculatorHeader(
          title: widget.type.label,
          subtitle: 'Masonry quantity and material estimate',
        ),
        EngineeringDiagramCard(
          label: 'Wall geometry · L × H × T',
          diagram: MasonryDiagram(type: widget.type),
        ),
        const SizedBox(height: 12),
        const MetricImperialToggle(),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masonry Unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Standard dimensions: ${p.unitSize.displayLabel}'),
                const SizedBox(height: 8),
                if (!customizeUnitDimensions)
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => customizeUnitDimensions = true),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Customize dimensions'),
                  )
                else ...[
                  field(unitLength, 'Unit length', 'mm'),
                  field(unitWidth, 'Unit width', 'mm'),
                  field(unitHeight, 'Unit height', 'mm'),
                  TextButton.icon(
                    onPressed: _useStandardDimensions,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Use Standard Dimensions'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Direct area mode'),
                  value: directArea,
                  onChanged: (v) => setState(() => directArea = v),
                ),
                if (directArea)
                  field(area, 'Wall area', 'm²')
                else ...[
                  field(length, 'Wall length', 'm'),
                  field(height, 'Wall height', 'm'),
                ],
                field(thickness, 'Wall thickness', 'mm'),
                field(quantity, 'Quantity', 'nos'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OpeningDeductionsEditor(onChanged: (v) => openings = v),
          ),
        ),
        const SizedBox(height: 12),
        CalculatorAdvancedOptions(
          children: [
            const Text('Material & Labour Settings'),
            const SizedBox(height: 8),
            const Text('Reference values — editable'),
            const SizedBox(height: 4),
            const Text(
              'Estimating defaults only. Verify rates, wages, wastage and productivity for your project and location.',
            ),
            const SizedBox(height: 12),
            field(rate, 'Material rate', '₹ / unit'),
            field(cementRate, 'Cement rate', '₹ / bag'),
            field(sandRate, 'Sand rate', '₹ / m³'),
            field(wastage, 'Wastage', '%'),
            field(masonWage, 'Mason wage', '₹ / day'),
            field(helperWage, 'Helper wage', '₹ / day'),
            field(masonProductivity, 'Mason productivity', 'days / m³'),
            field(helperProductivity, 'Helper productivity', 'days / m³'),
            DropdownButtonFormField<int>(
              initialValue: masons,
              items: [1, 2, 3]
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('$v Mason')),
                  )
                  .toList(),
              onChanged: (v) => setState(() => masons = v!),
            ),
            DropdownButtonFormField<int>(
              initialValue: helpers,
              items: [1, 2, 3]
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('$v Helper')),
                  )
                  .toList(),
              onChanged: (v) => setState(() => helpers = v!),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CalculatorCalculateButton(
          onPressed: calculate,
          label: 'Calculate Masonry',
        ),
      ],
    ),
  );
}
