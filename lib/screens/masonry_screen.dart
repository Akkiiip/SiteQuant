import 'package:flutter/material.dart';

import '../models/masonry_result.dart';
import '../services/masonry_calculator.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'masonry_result_screen.dart';

class MasonryScreen extends StatefulWidget {
  const MasonryScreen({super.key});

  @override
  State<MasonryScreen> createState() => _MasonryScreenState();
}

class _MasonryScreenState extends State<MasonryScreen> {
  final _wallLengthController = TextEditingController();
  final _wallHeightController = TextEditingController();
  final _wallsController = TextEditingController(text: '1');
  final _thicknessController = TextEditingController();
  final _unitLengthController = TextEditingController();
  final _unitWidthController = TextEditingController();
  final _unitHeightController = TextEditingController();
  final _wastageController = TextEditingController(text: '5');
  final _customRatioController = TextEditingController(text: '1 : 6');

  MasonryType _type = MasonryType.clayBrick;
  bool _customThickness = false;
  bool _customUnitSize = false;
  String _ratio = '1 : 6';

  @override
  void dispose() {
    for (final controller in [
      _wallLengthController,
      _wallHeightController,
      _wallsController,
      _thicknessController,
      _unitLengthController,
      _unitWidthController,
      _unitHeightController,
      _wastageController,
      _customRatioController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  MasonryUnitSize get _standardUnitSize => switch (_type) {
    MasonryType.clayBrick => const MasonryUnitSize(
      lengthMm: 190,
      widthMm: 90,
      heightMm: 90,
    ),
    MasonryType.aacBlock => const MasonryUnitSize(
      lengthMm: 600,
      widthMm: 200,
      heightMm: 200,
    ),
    MasonryType.concreteBlock => const MasonryUnitSize(
      lengthMm: 400,
      widthMm: 200,
      heightMm: 200,
    ),
    MasonryType.lateriteStone => const MasonryUnitSize(
      lengthMm: 355.6,
      widthMm: 228.6,
      heightMm: 177.8,
    ),
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  double? _positive(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      _showError('Enter a value greater than zero for $label.');
      return null;
    }
    return value;
  }

  MasonryUnitSize? _selectedUnitSize() {
    if (!_customUnitSize || _type == MasonryType.lateriteStone) {
      return _standardUnitSize;
    }
    final length = _positive(_unitLengthController, 'Unit Length');
    final width = _positive(_unitWidthController, 'Unit Width');
    final height = _positive(_unitHeightController, 'Unit Height');
    if (length == null || width == null || height == null) return null;
    return MasonryUnitSize(lengthMm: length, widthMm: width, heightMm: height);
  }

  void _selectType(MasonryType type) {
    setState(() {
      _type = type;
      _customUnitSize = false;
      _unitLengthController.clear();
      _unitWidthController.clear();
      _unitHeightController.clear();
    });
  }

  void _calculate() {
    final length = _positive(_wallLengthController, 'Wall Length');
    final height = _positive(_wallHeightController, 'Wall Height');
    final walls = _positive(_wallsController, 'Number of Walls');
    final wastage = _positive(_wastageController, 'Wastage');
    final unitSize = _selectedUnitSize();
    if (length == null ||
        height == null ||
        walls == null ||
        wastage == null ||
        unitSize == null)
      return;
    if (walls != walls.roundToDouble()) {
      _showError('Number of Walls must be a whole number.');
      return;
    }
    final thickness = _customThickness
        ? _positive(_thicknessController, 'Wall Thickness')
        : 230.0;
    if (thickness == null) return;
    final customRatio = _customRatioController.text.trim();
    final parts = (_ratio == 'Custom' ? customRatio : _ratio).split(':');
    final cementPart = double.tryParse(parts.first.trim());
    final sandPart = parts.length == 2
        ? double.tryParse(parts.last.trim())
        : null;
    if (cementPart == null ||
        sandPart == null ||
        cementPart <= 0 ||
        sandPart <= 0) {
      _showError('Enter a valid mortar ratio, for example 1 : 6.');
      return;
    }
    final system =
        MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    final result = MasonryCalculator.calculate(
      length: MeasurementPreferences.toMetres(length, system),
      height: MeasurementPreferences.toMetres(height, system),
      walls: walls.round(),
      thicknessMm: thickness,
      unitSize: unitSize,
      cementPart: cementPart,
      sandPart: sandPart,
      wastagePercent: wastage,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MasonryResultScreen(
          result: result,
          type: _type,
          unitSize: unitSize.displayLabel,
          thicknessMm: thickness,
          mortarRatio: _ratio == 'Custom' ? customRatio : _ratio,
          wastagePercent: wastage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      title: 'Masonry Calculator',
      bodyBuilder: (context, padding) => SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masonry Takeoff',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Estimate masonry units, mortar, cement and sand.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Masonry Type',
                      icon: Icons.grid_view_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MasonryType.values
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type.label),
                              selected: _type == type,
                              selectedColor: colors.primary,
                              side: BorderSide(color: colors.primary),
                              labelStyle: TextStyle(
                                color: _type == type
                                    ? colors.onPrimary
                                    : colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => _selectType(type),
                            ),
                          )
                          .toList(),
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
                      title: 'Wall Dimensions',
                      icon: Icons.straighten_rounded,
                      compact: true,
                    ),
                    const SizedBox(height: 14),
                    DimensionInputField(
                      controller: _wallLengthController,
                      label: 'Wall Length',
                    ),
                    const SizedBox(height: 14),
                    DimensionInputField(
                      controller: _wallHeightController,
                      label: 'Wall Height',
                    ),
                    const SizedBox(height: 14),
                    DimensionInputField(
                      controller: _wallsController,
                      label: 'Number of Walls',
                      unit: null,
                      wholeNumber: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _unitSizeCard(context),
            const SizedBox(height: 16),
            _thicknessCard(),
            const SizedBox(height: 16),
            _mortarCard(),
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

  Widget _unitSizeCard(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Masonry Unit Size',
            icon: Icons.view_in_ar_rounded,
            compact: true,
          ),
          const SizedBox(height: 10),
          if (_type == MasonryType.lateriteStone) ...[
            Text('Stone Size', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 3),
            Text(
              '14" × 9" × 7" (Standard)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ] else ...[
            RadioGroup<bool>(
              groupValue: _customUnitSize,
              onChanged: (value) => setState(() => _customUnitSize = value!),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    title: Text(
                      'Standard ${_type == MasonryType.clayBrick ? 'Brick' : 'Block'} Size (${_standardUnitSize.displayLabel})',
                    ),
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    title: Text(
                      'Custom ${_type == MasonryType.clayBrick ? 'Brick' : 'Block'} Size',
                    ),
                  ),
                ],
              ),
            ),
            if (_customUnitSize) ...[
              const SizedBox(height: 8),
              DimensionInputField(
                controller: _unitLengthController,
                label:
                    '${_type == MasonryType.clayBrick ? 'Brick' : 'Block'} Length',
                unit: 'mm',
              ),
              const SizedBox(height: 14),
              DimensionInputField(
                controller: _unitWidthController,
                label:
                    '${_type == MasonryType.clayBrick ? 'Brick' : 'Block'} Width',
                unit: 'mm',
              ),
              const SizedBox(height: 14),
              DimensionInputField(
                controller: _unitHeightController,
                label:
                    '${_type == MasonryType.clayBrick ? 'Brick' : 'Block'} Height',
                unit: 'mm',
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Default mortar joint: 10 mm',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _thicknessCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Wall Thickness',
            icon: Icons.width_normal_rounded,
            compact: true,
          ),
          RadioGroup<bool>(
            groupValue: _customThickness,
            onChanged: (value) => setState(() => _customThickness = value!),
            child: const Column(
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text('Full Wall (230 mm)'),
                ),
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  title: Text('Custom Thickness'),
                ),
              ],
            ),
          ),
          if (_customThickness) ...[
            const SizedBox(height: 6),
            DimensionInputField(
              controller: _thicknessController,
              label: 'Wall Thickness',
              unit: 'mm',
            ),
          ],
        ],
      ),
    ),
  );

  Widget _mortarCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Mortar',
            icon: Icons.layers_rounded,
            compact: true,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _ratio,
            decoration: const InputDecoration(
              labelText: 'Mortar Ratio',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            items: const ['1 : 4', '1 : 5', '1 : 6', 'Custom']
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => _ratio = value!),
          ),
          if (_ratio == 'Custom') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customRatioController,
              decoration: const InputDecoration(
                labelText: 'Custom Ratio',
                hintText: 'e.g. 1 : 6',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ],
          const SizedBox(height: 14),
          DimensionInputField(
            controller: _wastageController,
            label: 'Wastage',
            unit: '%',
          ),
        ],
      ),
    ),
  );
}
