import 'package:flutter/material.dart';

class DimensionInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? unit;
  final bool wholeNumber;

  const DimensionInputField({
    super.key,
    required this.controller,
    required this.label,
    this.unit = 'm',
    this.wholeNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
