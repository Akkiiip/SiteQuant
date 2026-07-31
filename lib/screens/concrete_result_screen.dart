import 'package:flutter/material.dart';

import '../models/concrete_result.dart';
import '../services/concrete_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/material_takeoff_card.dart';
import '../widgets/primary_button.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Calculation Result',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text('Material Takeoff', style: textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(
            'Estimated quantities based on your selected concrete mix.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concrete Volume',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${result.volume.toStringAsFixed(2)} m³',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          MaterialTakeoffCard(result: result),
          const SizedBox(height: 12),
          ResultSummaryCard(
            structure: structure,
            grade: grade,
            mixRatio: mixRatio,
            wcRatio: wcRatio,
            volume: result.volume,
            dryVolume: dryVolume,
          ),
          const SizedBox(height: 12),
          _AboutCalculation(wcRatio: wcRatio),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.restart_alt_rounded,
            label: 'New Calculation',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutCalculation extends StatelessWidget {
  final double wcRatio;

  const _AboutCalculation({required this.wcRatio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('About Calculation'),
        leading: const Icon(Icons.info_outline_rounded),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _CalculationDetail(
            label: 'Dry Volume Factor',
            value: ConcreteCalculator.dryVolumeFactor.toString(),
          ),
          _CalculationDetail(
            label: 'Cement Density',
            value: '${ConcreteCalculator.cementDensity.toStringAsFixed(0)} kg/m³',
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
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
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
