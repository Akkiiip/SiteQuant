import 'package:flutter/material.dart';

import '../models/plaster_result.dart';
import '../services/plaster_calculator.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'plaster_result_screen.dart';

class PlasterScreen extends StatefulWidget { const PlasterScreen({super.key}); @override State<PlasterScreen> createState() => _PlasterScreenState(); }

class _PlasterScreenState extends State<PlasterScreen> {
  final _length = TextEditingController(), _second = TextEditingController(), _walls = TextEditingController(text: '1'), _customThickness = TextEditingController(), _wastage = TextEditingController(text: '5');
  PlasterType _type = PlasterType.wall; String _thickness = '12', _ratio = '1 : 4';
  @override void dispose() { for (final controller in [_length, _second, _walls, _customThickness, _wastage]) { controller.dispose(); } super.dispose(); }
  void _error(String message) { ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message))); }
  double? _positive(TextEditingController c, String label) { final value = double.tryParse(c.text.trim()); if (value == null || value <= 0) { _error('Enter a value greater than zero for $label.'); return null; } return value; }
  void _calculate() {
    final length = _positive(_length, 'Length'), second = _positive(_second, _type == PlasterType.wall ? 'Wall Height' : 'Width'), walls = _type == PlasterType.wall ? _positive(_walls, 'Number of Walls') : 1.0, thickness = _thickness == 'Custom' ? _positive(_customThickness, 'Thickness') : double.parse(_thickness), wastage = _positive(_wastage, 'Wastage');
    if (length == null || second == null || walls == null || thickness == null || wastage == null) return;
    if (_type == PlasterType.wall && walls != walls.roundToDouble()) { _error('Number of Walls must be a whole number.'); return; }
    final system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    final parts = _ratio.split(':');
    final result = PlasterCalculator.calculate(area: MeasurementPreferences.toMetres(length, system) * MeasurementPreferences.toMetres(second, system) * walls, thicknessMm: thickness, cementPart: double.parse(parts.first.trim()), sandPart: double.parse(parts.last.trim()), wastagePercent: wastage);
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlasterResultScreen(result: result, type: _type, thicknessMm: thickness, mortarRatio: _ratio, wastagePercent: wastage)));
  }
  @override Widget build(BuildContext context) => AppScaffold(title: 'Plaster Calculator', bodyBuilder: (context, padding) => SingleChildScrollView(padding: padding, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Plaster Takeoff', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 5), Text('Estimate plaster material quantities.', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 20),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionHeader(title: 'Plaster Type', icon: Icons.format_paint_rounded, compact: true), const SizedBox(height: 12), SegmentedButton<PlasterType>(segments: const [ButtonSegment(value: PlasterType.wall, label: Text('Wall Plaster')), ButtonSegment(value: PlasterType.ceiling, label: Text('Ceiling Plaster'))], selected: {_type}, onSelectionChanged: (values) => setState(() => _type = values.first))]))), const SizedBox(height: 16),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionHeader(title: 'Dimensions', icon: Icons.straighten_rounded, compact: true), const SizedBox(height: 14), DimensionInputField(controller: _length, label: _type == PlasterType.wall ? 'Wall Length' : 'Length'), const SizedBox(height: 14), DimensionInputField(controller: _second, label: _type == PlasterType.wall ? 'Wall Height' : 'Width'), if (_type == PlasterType.wall) ...[const SizedBox(height: 14), DimensionInputField(controller: _walls, label: 'Number of Walls', unit: null, wholeNumber: true)]]))), const SizedBox(height: 16),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SectionHeader(title: 'Plaster Specification', icon: Icons.tune_rounded, compact: true), const SizedBox(height: 14), DropdownButtonFormField<String>(initialValue: _thickness, decoration: const InputDecoration(labelText: 'Plaster Thickness', floatingLabelBehavior: FloatingLabelBehavior.always), items: const ['12', '15', '20', 'Custom'].map((value) => DropdownMenuItem(value: value, child: Text(value == 'Custom' ? value : '$value mm'))).toList(), onChanged: (value) => setState(() => _thickness = value!)), if (_thickness == 'Custom') ...[const SizedBox(height: 14), DimensionInputField(controller: _customThickness, label: 'Thickness', unit: 'mm')], const SizedBox(height: 14), DropdownButtonFormField<String>(initialValue: _ratio, decoration: const InputDecoration(labelText: 'Mortar Ratio', floatingLabelBehavior: FloatingLabelBehavior.always), items: const ['1 : 3', '1 : 4', '1 : 5'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => _ratio = value!)), const SizedBox(height: 14), DimensionInputField(controller: _wastage, label: 'Wastage', unit: '%')]))), const SizedBox(height: 24), PrimaryButton(onPressed: _calculate, icon: Icons.calculate_rounded, label: 'Calculate Quantity'),
  ])));
}
