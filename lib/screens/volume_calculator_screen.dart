import 'package:flutter/material.dart';
import '../models/volume_result.dart';
import '../services/volume_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import '../services/measurement_system.dart';
import 'volume_result_screen.dart';

enum _Shape { cuboid, cylinder, cone, sphere }

extension on _Shape {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class VolumeCalculatorScreen extends StatefulWidget {
  const VolumeCalculatorScreen({super.key});
  @override
  State<VolumeCalculatorScreen> createState() => _VolumeCalculatorScreenState();
}

class _VolumeCalculatorScreenState extends State<VolumeCalculatorScreen> {
  final _a = TextEditingController(),
      _b = TextEditingController(),
      _c = TextEditingController();
  _Shape _shape = _Shape.cuboid;
  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    super.dispose();
  }

  double? _value(TextEditingController controller, String label) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Enter a value greater than zero for $label.'),
          ),
        );
      return null;
    }
    return value;
  }

  void _calculate() {
    final system =
        MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    final inputA = _value(_a, _shape == _Shape.cuboid ? 'Length' : 'Diameter');
    final inputB = _shape == _Shape.sphere
        ? 0.0
        : _value(_b, _shape == _Shape.cuboid ? 'Width' : 'Height');
    final inputC = _shape == _Shape.cuboid ? _value(_c, 'Height') : 0.0;
    if (inputA == null || inputB == null || inputC == null) return;
    final a = MeasurementPreferences.toMetres(inputA, system),
        b = MeasurementPreferences.toMetres(inputB, system),
        c = MeasurementPreferences.toMetres(inputC, system);
    final volume = switch (_shape) {
      _Shape.cuboid => VolumeCalculator.cuboid(length: a, width: b, height: c),
      _Shape.cylinder => VolumeCalculator.cylinder(diameter: a, height: b),
      _Shape.cone => VolumeCalculator.cone(diameter: a, height: b),
      _Shape.sphere => VolumeCalculator.sphere(diameter: a),
    };
    final unit = system.lengthUnit;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VolumeResultScreen(
          result: VolumeResult(volume),
          shape: _shape.label,
          dimensions: _shape == _Shape.cuboid
              ? 'L $inputA $unit × W $inputB $unit × H $inputC $unit'
              : _shape == _Shape.sphere
              ? 'Diameter $inputA $unit'
              : 'Diameter $inputA $unit × Height $inputB $unit',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Volume Calculator',
    bodyBuilder: (context, padding) => SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volume Takeoff',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          Text(
            'Calculate common geometric volumes.',
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
                    title: 'Shape',
                    icon: Icons.category_rounded,
                    compact: true,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _Shape.values
                        .map(
                          (shape) => ChoiceChip(
                            label: Text(shape.label),
                            selected: _shape == shape,
                            onSelected: (_) => setState(() {
                              _shape = shape;
                              _a.clear();
                              _b.clear();
                              _c.clear();
                            }),
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
                    title: 'Dimensions',
                    icon: Icons.straighten_rounded,
                    compact: true,
                  ),
                  const SizedBox(height: 14),
                  DimensionInputField(
                    controller: _a,
                    label: _shape == _Shape.cuboid ? 'Length' : 'Diameter',
                  ),
                  if (_shape != _Shape.sphere) ...[
                    const SizedBox(height: 14),
                    DimensionInputField(
                      controller: _b,
                      label: _shape == _Shape.cuboid ? 'Width' : 'Height',
                    ),
                  ],
                  if (_shape == _Shape.cuboid) ...[
                    const SizedBox(height: 14),
                    DimensionInputField(controller: _c, label: 'Height'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: _calculate,
            icon: Icons.calculate_rounded,
            label: 'Calculate Volume',
          ),
        ],
      ),
    ),
  );
}
