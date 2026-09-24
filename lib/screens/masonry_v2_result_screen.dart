import 'package:flutter/material.dart';
import '../models/masonry_input.dart';
import '../models/masonry_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_format.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';

class MasonryV2ResultScreen extends StatelessWidget {
  final MasonryEstimateResult result;
  const MasonryV2ResultScreen({super.key, required this.result});
  String n(double v, [int d = 2]) => EstimateFormat.number(v, d);
  String money(double v) => '₹${EstimateFormat.number(v, 0)}';
  @override
  Widget build(BuildContext context) {
    final t = result.takeoff;
    final l = result.labour;
    final p = result.productivity;
    return AppScaffold(
      title: 'Results',
      bodyBuilder: (context, pad) => ListView(
        padding: pad,
        children: [
          ResultHeader(
            label: 'Net Masonry Area',
            value: '${n(result.area.netArea)} m²',
          ),
          const SizedBox(height: 10),
          MaterialRequirementCard(
            materials: [
              MaterialRequirement(
                result.input.type.unitLabel,
                '${t.unitCount}',
                Icons.grid_view_rounded,
              ),
              MaterialRequirement(
                'Mortar',
                '${n(t.mortarVolume)} m³',
                Icons.layers_outlined,
              ),
              MaterialRequirement(
                'Cement',
                '${n(t.cementBags)} bags',
                Icons.inventory_2_outlined,
              ),
              MaterialRequirement(
                'Sand',
                '${n(t.sandM3)} m³',
                Icons.change_history_rounded,
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
                    'Cost Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  row('Material Cost', money(result.materialCost)),
                  row('Labour Cost', money(l.totalCost)),
                  row('Total Cost', money(result.totalCost)),
                  row('Cost / m²', money(result.costPerSquareMetre)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LABOUR & TIME',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  row(
                    'Crew',
                    '${result.input.masons} Mason + ${result.input.helpers} Helper',
                  ),
                  row('Working Days', '${n(p.workingDays, 1)} days'),
                  row('Labour Cost', money(l.totalCost)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          CalculationDetails(
            children: [
              row('Gross area', '${n(result.area.grossArea)} m²'),
              row('Opening deductions', '${n(result.area.deductionArea)} m²'),
              row('Wall volume', '${n(t.masonryVolume)} m³'),
              row('Unit size', result.input.unitSize.displayLabel),
              row('Wastage', '${n(result.input.wastagePercent)}%'),
              row('Mason mandays', n(p.mandays[LabourRole.mason] ?? 0, 1)),
              row('Helper mandays', n(p.mandays[LabourRole.helper] ?? 0, 1)),
              row(
                'Reference note',
                'Reference values are editable; verify locally.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Calculation'),
          ),
        ],
      ),
    );
  }

  Widget row(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(a)),
        Text(b),
      ],
    ),
  );
}
