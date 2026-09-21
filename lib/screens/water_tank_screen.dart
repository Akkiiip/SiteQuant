import 'package:flutter/material.dart';

import '../models/water_tank_input.dart';
import '../widgets/water_tank_diagram.dart';
import 'water_tank_calculator_screen.dart';

class WaterTankScreen extends StatelessWidget {
  const WaterTankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blue = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        title: const Text('Water Tank'),
        backgroundColor: blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select tank type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _card(
            context,
            WaterTankType.rectangular,
            'Rectangular RCC Tank',
            'RCC tank with slab and walls',
          ),
          _card(
            context,
            WaterTankType.circular,
            'Circular RCC Tank',
            'Circular RCC tank with slab and walls',
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    WaterTankType type,
    String title,
    String subtitle,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      key: ValueKey('water-tank-${type.name}'),
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaterTankCalculatorScreen(type: type),
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(subtitle),
              const SizedBox(height: 8),
              WaterTankDiagram(type: type),
            ],
          ),
        ),
      ),
    ),
  );
}
