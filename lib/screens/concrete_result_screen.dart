import 'package:flutter/material.dart';

import '../models/concrete_result.dart';

class ConcreteResultScreen extends StatelessWidget {
  final ConcreteResult result;

  const ConcreteResultScreen({super.key, required this.result});

  Widget resultCard({
    required BuildContext context,
    required String title,
    required List<String> values,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...values.map(
                    (value) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculation Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text('Material takeoff', style: textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(
            'Estimated quantities based on your selected concrete mix.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concrete volume',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${result.volume.toStringAsFixed(3)} m³',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
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
          const SizedBox(height: 16),
          resultCard(
            context: context,
            title: 'Cement',
            values: [
              '${result.cementBags.toStringAsFixed(1)} bags',
              '${result.cementKg.toStringAsFixed(1)} kg',
            ],
            icon: Icons.foundation_rounded,
          ),
          const SizedBox(height: 12),
          resultCard(
            context: context,
            title: 'Sand',
            values: [
              '${result.sandM3.toStringAsFixed(3)} m³',
              '${result.sandBrass.toStringAsFixed(2)} brass',
            ],
            icon: Icons.landscape_rounded,
          ),
          const SizedBox(height: 12),
          resultCard(
            context: context,
            title: 'Aggregate',
            values: [
              '${result.aggregateM3.toStringAsFixed(3)} m³',
              '${result.aggregateBrass.toStringAsFixed(2)} brass',
            ],
            icon: Icons.grain_rounded,
          ),
          const SizedBox(height: 12),
          resultCard(
            context: context,
            title: 'Water',
            values: ['${result.waterLitres.round()} litres'],
            icon: Icons.water_drop_rounded,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // We'll implement cost estimation next.
            },
            icon: const Icon(Icons.request_quote_rounded),
            label: const Text('Estimate material cost'),
          ),
        ],
      ),
    );
  }
}
