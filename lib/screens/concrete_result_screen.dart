import 'package:flutter/material.dart';

import '../models/concrete_result.dart';
import '../services/concrete_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';

import '../widgets/result_summary_card.dart';

class ConcreteResultScreen extends StatelessWidget {
  final ConcreteResult result;
  final String structure;
  final String grade;
  final String mixRatio;
  final double wcRatio;
  final double dryVolume;

  const ConcreteResultScreen({
    super.key,
    required this.result,
    required this.structure,
    required this.grade,
    required this.mixRatio,
    required this.wcRatio,
    required this.dryVolume,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Results',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          ResultHeader(
            label: 'Concrete Volume',
            value: '${result.volume.toStringAsFixed(2)} m³',
          ),
          const SizedBox(height: 10),
          MaterialRequirementCard(
            materials: [
              MaterialRequirement(
                'Cement',
                '${result.cementBags.toStringAsFixed(1)} bags · ${result.cementKg.round()} kg',
                Icons.inventory_2_outlined,
              ),
              MaterialRequirement(
                'Sand',
                '${result.sandM3.toStringAsFixed(2)} m³ · ${result.sandBrass.toStringAsFixed(2)} Brass',
                Icons.change_history_rounded,
              ),
              MaterialRequirement(
                'Aggregate',
                '${result.aggregateM3.toStringAsFixed(2)} m³ · ${result.aggregateBrass.toStringAsFixed(2)} Brass',
                Icons.grain_rounded,
              ),
              MaterialRequirement(
                'Water',
                '${result.waterLitres.round()} L',
                Icons.water_drop_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mix Proportion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(mixRatio, style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    'Cement : Sand : Aggregate',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          CalculationDetails(
            children: [
              ResultSummaryCard(
                structure: structure,
                grade: grade,
                mixRatio: mixRatio,
                wcRatio: wcRatio,
                volume: result.volume,
                dryVolume: dryVolume,
              ),
              const SizedBox(height: 10),
              _CalculationDetail(
                label: 'Dry Volume Factor',
                value: ConcreteCalculator.dryVolumeFactor.toString(),
              ),
              _CalculationDetail(
                label: 'Cement Density',
                value:
                    '${ConcreteCalculator.cementDensity.toStringAsFixed(0)} kg/m³',
              ),
              _CalculationDetail(
                label: 'Bag Weight',
                value: '${ConcreteCalculator.bagWeight.toStringAsFixed(0)} kg',
              ),
              _CalculationDetail(
                label: 'Water-Cement Ratio',
                value: wcRatio.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const ResultActions(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('New Calculation'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculationDetail extends StatelessWidget {
  final String label;
  final String value;

  const _CalculationDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
