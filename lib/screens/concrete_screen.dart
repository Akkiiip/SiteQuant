import 'package:flutter/material.dart';

import '../services/concrete_calculator.dart';
import '../services/volume_calculator.dart';
import 'concrete_result_screen.dart';

class ConcreteScreen extends StatefulWidget {
  const ConcreteScreen({super.key});

  @override
  State<ConcreteScreen> createState() => _ConcreteScreenState();
}

class _ConcreteScreenState extends State<ConcreteScreen> {
  String selectedStructure = 'Footing';
  String selectedGrade = 'M20';

  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController numberController = TextEditingController(text: '1');
  final TextEditingController wcController = TextEditingController(text: '0.45');

  final List<String> structures = [
    'Slab',
    'Beam',
    'Column',
    'Footing',
    'Circular Column',
    'Circular Footing',
    'Custom Volume',
  ];

  final List<String> grades = [
    'M5',
    'M7.5',
    'M10',
    'M15',
    'M20',
    'M25',
    'M30 (Design Mix)',
    'M35 (Design Mix)',
    'M40 (Design Mix)',
  ];

  @override
  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    numberController.dispose();
    wcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Concrete Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concrete takeoff', style: textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              'Calculate concrete volume and material quantities.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.category_rounded,
                      title: 'Structure type',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: structures.map((structure) {
                        return ChoiceChip(
                          label: Text(structure),
                          selected: selectedStructure == structure,
                          selectedColor:
                              colorScheme.primary.withValues(alpha: 0.14),
                          onSelected: (_) {
                            setState(() {
                              selectedStructure = structure;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.straighten_rounded,
                      title: 'Dimensions',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lengthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Length',
                        suffixText: 'm',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: widthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        suffixText: 'm',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: depthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Depth',
                        suffixText: 'm',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Number'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      icon: Icons.science_rounded,
                      title: 'Mix specification',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Concrete Grade',
                      ),
                      items: grades.map((grade) {
                        return DropdownMenuItem(value: grade, child: Text(grade));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGrade = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: wcController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Water-Cement Ratio',
                        helperText: 'Typical value: 0.45',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!ConcreteCalculator.supportsGrade(selectedGrade)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Design mixes require an approved mix design and are not available in this calculator yet.',
                        ),
                      ),
                    );
                    return;
                  }

                  final length = double.tryParse(lengthController.text) ?? 0;
                  final width = double.tryParse(widthController.text) ?? 0;
                  final depth = double.tryParse(depthController.text) ?? 0;
                  final number = int.tryParse(numberController.text) ?? 1;
                  final wcRatio = double.tryParse(wcController.text) ?? 0.45;

                  double volume = 0;

                  switch (selectedStructure) {
                    case 'Slab':
                      volume = VolumeCalculator.slab(
                        length: length,
                        width: width,
                        thickness: depth,
                      );
                      break;
                    case 'Beam':
                      volume = VolumeCalculator.beam(
                        length: length,
                        width: width,
                        depth: depth,
                      );
                      break;
                    case 'Column':
                      volume = VolumeCalculator.column(
                        length: length,
                        breadth: width,
                        height: depth,
                        number: number,
                      );
                      break;
                    case 'Footing':
                      volume = VolumeCalculator.footing(
                        length: length,
                        width: width,
                        depth: depth,
                        number: number,
                      );
                      break;
                    case 'Circular Column':
                      volume = VolumeCalculator.circularColumn(
                        diameter: length,
                        height: depth,
                        number: number,
                      );
                      break;
                    case 'Circular Footing':
                      volume = VolumeCalculator.circularFooting(
                        diameter: length,
                        depth: depth,
                        number: number,
                      );
                      break;
                    case 'Custom Volume':
                      volume = VolumeCalculator.custom(volume: length);
                      break;
                  }

                  final result = ConcreteCalculator.calculate(
                    volume: volume,
                    grade: selectedGrade,
                    wcRatio: wcRatio,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConcreteResultScreen(result: result),
                    ),
                  );
                },
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculate quantity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 9),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
