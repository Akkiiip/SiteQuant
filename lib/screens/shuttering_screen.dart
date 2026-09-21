import 'package:flutter/material.dart';
import '../models/shuttering_result.dart';
import '../widgets/shuttering_diagram.dart';
import 'shuttering_calculator_screen.dart';

class ShutteringScreen extends StatefulWidget {
  const ShutteringScreen({super.key});
  @override
  State<ShutteringScreen> createState() => _ShutteringScreenState();
}

class _ShutteringScreenState extends State<ShutteringScreen> {
  ShutteringType selected = ShutteringType.column;
  String subtitle(ShutteringType type) => switch (type) {
    ShutteringType.column => 'Vertical shuttering',
    ShutteringType.beam => 'Sides + soffit',
    ShutteringType.footing => 'Side shuttering',
    ShutteringType.wall => 'One or two sides',
    ShutteringType.slab => 'Soffit shuttering',
  };
  @override
  Widget build(BuildContext context) {
    final blue = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        title: const Text('Shuttering'),
        backgroundColor: blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select a shuttering element',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose an element to review its shuttered contact faces.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          for (final type in ShutteringType.values) _card(context, type, blue),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Calculations use reference assumptions. You can edit rates and labour settings in each calculator.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, ShutteringType type, Color blue) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          key: ValueKey('shuttering-${type.name}'),
          onTap: () {
            setState(() => selected = type);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShutteringCalculatorScreen(type: type),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          type.label.replaceFirst('Shuttering ', ''),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (selected == type)
                        Icon(Icons.check_circle, color: blue),
                    ],
                  ),
                  Text(subtitle(type)),
                  const SizedBox(height: 8),
                  ShutteringDiagram(type: type),
                ],
              ),
            ),
          ),
        ),
      );
}
