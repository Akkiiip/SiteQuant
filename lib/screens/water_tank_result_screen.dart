import 'package:flutter/material.dart';

import '../models/productivity_standard.dart';
import '../models/water_tank_input.dart';
import '../models/water_tank_result.dart';
import '../services/estimate_format.dart';

class WaterTankResultScreen extends StatelessWidget {
  const WaterTankResultScreen({super.key, required this.result});
  final WaterTankResult result;
  String _number(double value) => EstimateFormat.number(value, 2);
  String _money(double value) => '₹${EstimateFormat.number(value, 0)}';
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
  Widget _card(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...children,
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final input = result.input;
    final p = result.productivity;
    final labour = result.labour;
    final masonDuration =
        p.mandays[LabourRole.mason]! / p.crew[LabourRole.mason]!;
    final helperDuration =
        p.mandays[LabourRole.helper]! / p.crew[LabourRole.helper]!;
    return Scaffold(
      appBar: AppBar(title: const Text('Water Tank Estimate')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _card('Water Tank', [
                _row(
                  'Tank Type',
                  input.type == WaterTankType.circular
                      ? 'Circular'
                      : 'Rectangular',
                ),
                _row(
                  'Internal dimensions',
                  input.type == WaterTankType.circular
                      ? 'D ${_number(input.internalWidthOrDiameter)} m × H ${_number(input.waterDepth)} m'
                      : 'L ${_number(input.internalLength)} m × W ${_number(input.internalWidthOrDiameter)} m × H ${_number(input.waterDepth)} m',
                ),
                _row('Quantity', '${input.quantity}'),
              ]),
              _card('Estimate Summary', [
                _row('RCC Quantity', '${_number(result.totalRccVolume)} m³'),
                _row('Material Cost', _money(result.materialCost)),
                _row('Labour Cost', _money(labour.totalCost)),
                _row('Total Cost', _money(result.totalCost)),
                _row(
                  'Cost / m³',
                  result.costPerCubicMetre == null
                      ? 'Not applicable'
                      : _money(result.costPerCubicMetre!),
                ),
              ]),
              _card('Labour & Time', [
                _row(
                  'Crew',
                  '${p.crew[LabourRole.mason]} Mason + ${p.crew[LabourRole.helper]} Helper',
                ),
                _row('Working Days', '${_number(p.workingDays)} days'),
                _row('Labour Cost', _money(labour.totalCost)),
              ]),
              Card(
                child: ExpansionTile(
                  title: const Text('RCC Breakdown'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    _row('Base Slab', '${_number(result.baseSlabVolume)} m³'),
                    _row('Walls', '${_number(result.wallVolume)} m³'),
                    _row('Top Slab', '${_number(result.topSlabVolume)} m³'),
                    _row('Total RCC', '${_number(result.totalRccVolume)} m³'),
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  title: const Text('Calculation Details'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    _row(
                      'Outer dimensions',
                      input.type == WaterTankType.circular
                          ? 'D ${_number(result.outerWidthOrDiameter)} m'
                          : 'L ${_number(result.outerLength)} m × W ${_number(result.outerWidthOrDiameter)} m',
                    ),
                    const Text(
                      'Base and top slabs use the derived outer footprint. Walls use outer volume minus internal water footprint at the water depth.',
                    ),
                    _row(
                      'Reference RCC rate',
                      '${_money(input.rccRatePerCubicMetre)}/m³',
                    ),
                    _row(
                      'Mason mandays',
                      _number(p.mandays[LabourRole.mason]!),
                    ),
                    _row(
                      'Helper mandays',
                      _number(p.mandays[LabourRole.helper]!),
                    ),
                    _row(
                      'Controlling role',
                      masonDuration >= helperDuration ? 'Mason' : 'Helper',
                    ),
                    Text(p.standard.basis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
