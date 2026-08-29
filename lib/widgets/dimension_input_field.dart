import 'package:flutter/material.dart';

import '../services/measurement_system.dart';

class DimensionInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? unit;
  final bool wholeNumber;
  final bool useMeasurementSystem;

  const DimensionInputField({
    super.key,
    required this.controller,
    required this.label,
    this.unit = 'm',
    this.wholeNumber = false,
    this.useMeasurementSystem = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MeasurementSystem?>(
      valueListenable: MeasurementPreferences.system,
      builder: (context, system, _) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
        decoration: InputDecoration(
          labelText: label,
          suffixText: !useMeasurementSystem
              ? unit
              : unit == 'm'
              ? (system ?? MeasurementSystem.metric).lengthUnit
              : unit == 'm³'
              ? (system ?? MeasurementSystem.metric).volumeUnit
              : unit,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}
