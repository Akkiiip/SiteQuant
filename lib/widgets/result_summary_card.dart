import 'package:flutter/material.dart';

class ResultSummaryCard extends StatelessWidget {
  final String structure;
  final String grade;
  final String mixRatio;
  final double wcRatio;
  final double volume;
  final double dryVolume;

  const ResultSummaryCard({
    super.key,
    required this.structure,
    required this.grade,
    required this.mixRatio,
    required this.wcRatio,
    required this.volume,
    required this.dryVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 430 ? 2 : 1;
                final itemWidth =
                    (constraints.maxWidth - (columns - 1) * 8) / columns;
                final items = [
                  _SummaryValue('Structure', structure),
                  _SummaryValue('Concrete Grade', grade),
                  _SummaryValue('Mix Ratio', mixRatio),
                  _SummaryValue(
                    'Water-Cement Ratio',
                    'W/C ${wcRatio.toStringAsFixed(2)}',
                  ),
                  _SummaryValue(
                    'Concrete Volume',
                    '${volume.toStringAsFixed(2)} m³',
                  ),
                  _SummaryValue(
                    'Dry Volume',
                    '${dryVolume.toStringAsFixed(2)} m³',
                  ),
                ];

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((item) => SizedBox(width: itemWidth, child: item))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
