import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/unit_converter.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _valueController = TextEditingController();
  UnitCategory _category = UnitCategory.length;
  late UnitDefinition _fromUnit = UnitConverter.units[_category]![0];
  late UnitDefinition _toUnit = UnitConverter.units[_category]![1];

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  List<UnitDefinition> get _units => UnitConverter.units[_category]!;

  double? get _result {
    final value = double.tryParse(_valueController.text);
    if (value == null) return null;
    return UnitConverter.convert(value: value, from: _fromUnit, to: _toUnit);
  }

  void _changeCategory(UnitCategory category) {
    final units = UnitConverter.units[category]!;
    setState(() {
      _category = category;
      _fromUnit = units[0];
      _toUnit = units[1];
    });
  }

  void _selectFrom(UnitDefinition unit) {
    setState(() {
      _fromUnit = unit;
      if (_fromUnit == _toUnit) {
        _toUnit = _units.firstWhere((candidate) => candidate != unit);
      }
    });
  }

  void _selectTo(UnitDefinition unit) {
    setState(() {
      _toUnit = unit;
      if (_toUnit == _fromUnit) {
        _fromUnit = _units.firstWhere((candidate) => candidate != unit);
      }
    });
  }

  void _swapUnits() => setState(() {
        final previousFrom = _fromUnit;
        _fromUnit = _toUnit;
        _toUnit = previousFrom;
      });

  String _formatResult(double value) {
    if (value == 0) return '0';
    final compact = value.abs() >= 1e12 || value.abs() < 1e-6;
    if (compact) return value.toStringAsExponential(6).replaceFirst(RegExp(r'0+e'), 'e');
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      title: 'Unit Converter',
      bodyBuilder: (context, padding) => SingleChildScrollView(
        padding: padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Engineering Unit Converter', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text('Convert common site units instantly.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Unit Category', icon: Icons.category_rounded, compact: true),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: UnitCategory.values.map((category) => ChoiceChip(label: Text(category.label), selected: _category == category, selectedColor: colors.primary, side: BorderSide(color: colors.primary), labelStyle: TextStyle(color: _category == category ? colors.onPrimary : colors.onSurface, fontWeight: FontWeight.w600), onSelected: (_) => _changeCategory(category))).toList()),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(title: 'Conversion', icon: Icons.swap_horiz_rounded, compact: true),
            const SizedBox(height: 16),
            DropdownButtonFormField<UnitDefinition>(initialValue: _fromUnit, decoration: const InputDecoration(labelText: 'From Unit', floatingLabelBehavior: FloatingLabelBehavior.always), items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit.label))).toList(), onChanged: (unit) => _selectFrom(unit!)),
            Center(child: IconButton.filledTonal(onPressed: _swapUnits, icon: const Icon(Icons.swap_vert_rounded), tooltip: 'Swap units')),
            DropdownButtonFormField<UnitDefinition>(initialValue: _toUnit, decoration: const InputDecoration(labelText: 'To Unit', floatingLabelBehavior: FloatingLabelBehavior.always), items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit.label))).toList(), onChanged: (unit) => _selectTo(unit!)),
            const SizedBox(height: 16),
            TextField(controller: _valueController, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'))], decoration: InputDecoration(labelText: 'Enter Value', suffixText: _fromUnit.label, floatingLabelBehavior: FloatingLabelBehavior.always)),
          ]))),
          const SizedBox(height: 16),
          Card(color: colors.primaryContainer, child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Converted Value', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colors.onPrimaryContainer)), const SizedBox(height: 8),
            Text(result == null ? '—' : _formatResult(result), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700)), const SizedBox(height: 3),
            Text(_toUnit.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onPrimaryContainer)),
          ]))),
        ]),
      ),
    );
  }
}
