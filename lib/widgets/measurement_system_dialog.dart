import 'package:flutter/material.dart';

import '../services/measurement_system.dart';

Future<void> showMeasurementSystemDialog(BuildContext context, {required MeasurementSystem initial}) async {
  var selected = initial;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Choose your preferred measurement system'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select the measurement system you normally use.\n\nYou can change this anytime from Settings.'),
            const SizedBox(height: 12),
            RadioGroup<MeasurementSystem>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value!),
              child: Column(
                children: const [
                  RadioListTile<MeasurementSystem>(contentPadding: EdgeInsets.zero, value: MeasurementSystem.metric, title: Text('Metric'), subtitle: Text('m • m² • m³')),
                  RadioListTile<MeasurementSystem>(contentPadding: EdgeInsets.zero, value: MeasurementSystem.imperial, title: Text('Imperial'), subtitle: Text('ft • ft² • ft³')),
                ],
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () async { await MeasurementPreferences.setSystem(selected); if (context.mounted) Navigator.pop(context); }, child: const Text('Continue'))],
      ),
    ),
  );
}
