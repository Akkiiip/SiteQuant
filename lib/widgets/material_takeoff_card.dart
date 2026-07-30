import 'package:flutter/material.dart';

import '../models/concrete_result.dart';

class MaterialTakeoffCard extends StatelessWidget {
  final ConcreteResult result;

  const MaterialTakeoffCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Material Takeoff', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _MaterialRow(
              title: 'Cement',
              icon: Icons.foundation_rounded,
              values: [
                _MaterialValue('Bags', result.cementBags.toStringAsFixed(1)),
                _MaterialValue('kg', result.cementKg.round().toString()),
              ],
            ),
            const Divider(height: 24),
            _MaterialRow(
              title: 'Sand',
              icon: Icons.landscape_rounded,
              values: [
                _MaterialValue('m³', result.sandM3.toStringAsFixed(2)),
                _MaterialValue('Brass', result.sandBrass.toStringAsFixed(2)),
              ],
            ),
            const Divider(height: 24),
            _MaterialRow(
              title: 'Aggregate',
              icon: Icons.grain_rounded,
              values: [
                _MaterialValue('m³', result.aggregateM3.toStringAsFixed(2)),
                _MaterialValue('Brass', result.aggregateBrass.toStringAsFixed(2)),
              ],
            ),
            const Divider(height: 24),
            _MaterialRow(
              title: 'Water',
              icon: Icons.water_drop_rounded,
              values: [_MaterialValue('L', result.waterLitres.round().toString())],
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_MaterialValue> values;

  const _MaterialRow({
    required this.title,
    required this.icon,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = values.length == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: values
                    .map((value) => SizedBox(width: itemWidth, child: value))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MaterialValue extends StatelessWidget {
  final String label;
  final String value;

  const _MaterialValue(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
