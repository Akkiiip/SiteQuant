import 'package:flutter/material.dart';

import '../models/paint_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_cost_calculator.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class PaintResultScreen extends StatelessWidget {
  final PaintResult result;
  final MeasurementSystem system;

  const PaintResultScreen({
    super.key,
    required this.result,
    required this.system,
  });

  String _area(double value) =>
      '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, system), 2)} ${system.areaUnit}';

  String _number(double value, [int precision = 3]) =>
      EstimateFormat.number(value, precision);

  @override
  Widget build(BuildContext context) {
    final labour = result.labour;
    final productivity = result.productivity;
    final displayedArea = MeasurementPreferences.fromSquareMetres(
      result.netArea,
      system,
    );
    final displayUnitCost = EstimateCostCalculator.perUnit(
      result.totalCost,
      displayedArea,
    );
    return AppScaffold(
      title: 'Paint Estimate',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text(
            'Paint & Finishes V2',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.workType.label),
                  const SizedBox(height: 5),
                  const Text('Net Paint Area'),
                  Text(
                    _area(result.netArea),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Gross ${_area(result.grossArea)} − deductions '
                    '${_area(result.deductionArea)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(
            context,
            'Paint / Finish Details',
            Icons.format_paint_outlined,
            [
              _row(context, 'Work Type', result.workType.label),
              _row(context, 'Gross Area', _area(result.grossArea)),
              _row(context, 'Opening Deductions', _area(result.deductionArea)),
              for (final opening in result.takeoff.openings)
                _row(
                  context,
                  '${opening.name} × ${opening.quantity}',
                  _area(OpeningCalculator.openingArea(opening)),
                ),
              _row(context, 'Net Paint Area', _area(result.netArea)),
            ],
          ),
          _section(context, 'Material Requirement', Icons.inventory_2_outlined, [
            for (final material in result.materials) ...[
              Text(
                material.input.kind.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              _row(context, 'Coats', '${material.input.coats}'),
              _row(
                context,
                material.input.kind.coverageIsConsumption
                    ? 'Consumption'
                    : 'Coverage',
                '${_number(material.input.coverage)} '
                '${material.input.kind.coverageIsConsumption ? 'kg / m² / coat' : 'm² / ${material.input.kind.unit} / coat'}',
              ),
              _row(
                context,
                'Base quantity',
                '${_number(material.baseQuantity, 2)} ${material.input.kind.unit}',
              ),
              _row(
                context,
                'Wastage',
                '${_number(material.input.wastagePercent)}% '
                    '(${_number(material.wastageQuantity, 2)} ${material.input.kind.unit})',
              ),
              _row(
                context,
                'Required quantity',
                '${_number(material.finalQuantity, 2)} ${material.input.kind.unit}',
              ),
              const Divider(height: 22),
            ],
          ]),
          _section(context, 'Material Cost', Icons.payments_outlined, [
            for (final material in result.materials) ...[
              _row(
                context,
                '${material.input.kind.label} quantity',
                '${_number(material.finalQuantity, 2)} ${material.input.kind.unit}',
              ),
              _row(
                context,
                '${material.input.kind.label} rate',
                '${EstimateFormat.money(material.input.rate)} / ${material.input.kind.unit}',
              ),
              _row(
                context,
                '${material.input.kind.label} cost',
                EstimateFormat.money(material.cost),
              ),
              const Divider(height: 22),
            ],
            _row(
              context,
              'Total Material Cost',
              EstimateFormat.money(result.materialCost),
            ),
          ]),
          _section(context, 'Labour & Time', Icons.groups_outlined, [
            _row(context, 'Productivity', productivity.standard.name),
            Text(productivity.standard.basis),
            const SizedBox(height: 10),
            for (final role in [LabourRole.painter, LabourRole.helper])
              _row(
                context,
                '${role.label} coefficient',
                '${_number(productivity.standard.daysPerBaseQuantity[role]!)} day / '
                    '${_area(productivity.standard.baseQuantity)}',
              ),
            _row(
              context,
              'Selected Crew',
              '${productivity.crew[LabourRole.painter]} Painter(s) + '
                  '${productivity.crew[LabourRole.helper]} Helper(s)',
            ),
            _row(
              context,
              'Painter Mandays',
              _number(productivity.mandays[LabourRole.painter]!),
            ),
            _row(
              context,
              'Helper Mandays',
              _number(productivity.mandays[LabourRole.helper]!),
            ),
            _row(
              context,
              'Estimated Working Days',
              _number(productivity.workingDays),
            ),
            const Text(
              'Duration = the greater of painter mandays ÷ painters and '
              'helper mandays ÷ helpers. It excludes access constraints, '
              'drying time, delays and holidays.',
            ),
            _row(
              context,
              'Painter Daily Wage',
              '${EstimateFormat.money(labour.dailyWages[LabourRole.painter]!)} / day',
            ),
            _row(
              context,
              'Helper Daily Wage',
              '${EstimateFormat.money(labour.dailyWages[LabourRole.helper]!)} / day',
            ),
            _row(
              context,
              'Painter Labour Cost',
              EstimateFormat.money(labour.costs[LabourRole.painter]!),
            ),
            _row(
              context,
              'Helper Labour Cost',
              EstimateFormat.money(labour.costs[LabourRole.helper]!),
            ),
            _row(
              context,
              'Total Labour Cost',
              EstimateFormat.money(labour.totalCost),
            ),
          ]),
          _section(context, 'Total Cost', Icons.summarize_outlined, [
            _row(
              context,
              'Material Cost',
              EstimateFormat.money(result.materialCost),
            ),
            _row(
              context,
              'Labour Cost',
              EstimateFormat.money(labour.totalCost),
            ),
            _row(
              context,
              'Total Project Cost',
              EstimateFormat.money(result.totalCost),
            ),
            _row(
              context,
              'Cost per ${system.areaUnit}',
              displayUnitCost == null
                  ? 'Not applicable — net area is zero'
                  : EstimateFormat.money(displayUnitCost),
            ),
            if (system == MeasurementSystem.imperial)
              _row(
                context,
                'Cost per m² (pricing reference)',
                result.costPerSquareMetre == null
                    ? 'Not applicable — net area is zero'
                    : EstimateFormat.money(result.costPerSquareMetre!),
              ),
          ]),
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.edit_outlined,
            label: 'Edit Calculation',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title, icon: icon, compact: true),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    ),
  );

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}
