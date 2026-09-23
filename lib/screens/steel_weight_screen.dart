import 'package:flutter/material.dart';

import '../services/steel_weight_calculator.dart';
import '../services/analytics_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/section_header.dart';
import 'steel_weight_result_screen.dart';

class SteelWeightScreen extends StatefulWidget {
  const SteelWeightScreen({super.key});
  @override
  State<SteelWeightScreen> createState() => _SteelWeightScreenState();
}

class _SteelWeightScreenState extends State<SteelWeightScreen> {
  final _lengthController = TextEditingController(),
      _countController = TextEditingController();
  int _diameter = 12;
  @override
  void dispose() {
    _lengthController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _error(String message) {
    AnalyticsService.logCalculationError('steel_weight', 'invalid_input');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _calculate() {
    final length = double.tryParse(_lengthController.text.trim()),
        count = double.tryParse(_countController.text.trim());
    if (length == null || length <= 0) {
      _error('Enter a bar length greater than zero.');
      return;
    }
    if (count == null || count <= 0) {
      _error('Enter a number of bars greater than zero.');
      return;
    }
    if (count != count.roundToDouble()) {
      _error('Number of Bars must be a whole number.');
      return;
    }
    final result = SteelWeightCalculator.calculate(
      diameter: _diameter,
      barLength: length,
      barCount: count.round(),
    );
    AnalyticsService.logCalculationCompleted('steel_weight');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SteelWeightResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Steel Weight Calculator',
    bodyBuilder: (context, padding) => SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CalculatorHeader(
            title: 'Steel Weight Calculator',
            subtitle: 'Reinforcement bar quantity',
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Bar Details',
                    icon: Icons.hardware_rounded,
                    compact: true,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _diameter,
                    decoration: const InputDecoration(
                      labelText: 'Bar Diameter',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    items: SteelWeightCalculator.unitWeights.keys
                        .map(
                          (diameter) => DropdownMenuItem(
                            value: diameter,
                            child: Text('$diameter mm'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _diameter = value!),
                  ),
                  const SizedBox(height: 14),
                  DimensionInputField(
                    controller: _lengthController,
                    label: 'Bar Length',
                    useMeasurementSystem: false,
                  ),
                  const SizedBox(height: 14),
                  DimensionInputField(
                    controller: _countController,
                    label: 'Number of Bars',
                    unit: null,
                    wholeNumber: true,
                    useMeasurementSystem: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CalculatorCalculateButton(
            onPressed: _calculate,
            label: 'Calculate Weight',
          ),
        ],
      ),
    ),
  );
}
