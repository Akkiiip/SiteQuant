import 'package:flutter/material.dart';
import '../models/excavation_result.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
class ExcavationResultScreen extends StatelessWidget {
  final ExcavationResult result;
  final String type;

  const ExcavationResultScreen({super.key, required this.result, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final system = MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    final volume = MeasurementPreferences.fromCubicMetres(result.volume, system);
    return AppScaffold(
      title: 'Calculation Result',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text('Excavation Result', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            color: colors.primary,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Excavation Volume', style: TextStyle(color: Colors.white.withValues(alpha: .78))),
                  const SizedBox(height: 4),
                  Text('${volume.toStringAsFixed(3)} ${system.volumeUnit}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
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
                  Text('Calculation Summary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(children: [const Expanded(child: Text('Excavation Type')), Flexible(child: Text(type, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: Theme.of(context).textTheme.labelLarge))]),
                  const SizedBox(height: 8),
                  Row(children: [const Expanded(child: Text('Excavation Volume')), Flexible(child: Text('${volume.toStringAsFixed(3)} ${system.volumeUnit}', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: Theme.of(context).textTheme.labelLarge))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(onPressed: () => Navigator.pop(context), icon: Icons.restart_alt_rounded, label: 'New Calculation'),
        ],
      ),
    );
  }
}
