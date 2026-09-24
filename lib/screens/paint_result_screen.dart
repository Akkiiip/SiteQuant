import 'package:flutter/material.dart';

import '../models/paint_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class PaintResultScreen extends StatelessWidget {
  const PaintResultScreen({
    super.key,
    required this.result,
    required this.system,
  });
  final PaintResult result;
  final MeasurementSystem system;
  String _area(double value) =>
      '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, system), 2)} ${system.areaUnit}';
  String _number(double value, [int precision = 1]) =>
      EstimateFormat.number(value, precision);
  String _money(double value) => '₹${value.round()}';

  @override
  Widget build(BuildContext context) {
    final labour = result.labour;
    final productivity = result.productivity;
    final putty = result.materials
        .where((m) => m.input.kind == PaintMaterialKind.putty)
        .firstOrNull;
    return AppScaffold(
      title: 'Results',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          ResultHeader(label: 'Net Paint Area', value: _area(result.netArea)),
          const SizedBox(height: 10),
          _section(context, 'Material', Icons.inventory_2_outlined, [
            for (final material in result.materials) ...[
              _row(
                context,
                '${material.input.kind.label} quantity',
                '${_number(material.finalQuantity, 2)} ${material.input.kind.unit}',
              ),
              if (material.approximatePacks != null)
                _row(
                  context,
                  '${material.input.kind.label} bags',
                  '${material.approximatePacks}',
                ),
              _row(
                context,
                '${material.input.kind.label} cost',
                _money(material.cost),
              ),
            ],
            _row(context, 'Material Cost', _money(result.materialCost)),
          ]),
          if (putty?.input.puttyPackSizeKg != null)
            _section(context, 'Putty Packaging', Icons.inventory_outlined, [
              _row(
                context,
                'Required quantity',
                '${_number(putty!.finalQuantity, 2)} kg',
              ),
              _row(
                context,
                'Pack size (editable reference)',
                '${_number(putty.input.puttyPackSizeKg!)} kg',
              ),
              _row(context, 'Approx. packs/bags', '${putty.approximatePacks}'),
            ]),
          _section(context, 'Labour & Time', Icons.groups_outlined, [
            _row(
              context,
              'Crew',
              '${productivity.crew[LabourRole.painter]} Painter(s) + ${productivity.crew[LabourRole.helper]} Helper(s)',
            ),
            _row(
              context,
              'Working Days',
              '${_number(productivity.workingDays)} days',
            ),
            _row(context, 'Labour Cost', _money(labour.totalCost)),
          ]),
          _section(context, 'Total', Icons.summarize_outlined, [
            _row(context, 'Estimated Total', _money(result.totalCost)),
            _row(
              context,
              'Cost per physical sq ft',
              result.costPerSquareFoot == null
                  ? 'Not applicable'
                  : _money(result.costPerSquareFoot!),
            ),
          ]),
          CalculationDetails(
            children: [
              _row(context, 'Work Type', result.workType.label),
              _row(context, 'Gross Area', _area(result.grossArea)),
              _row(context, 'Deductions', _area(result.deductionArea)),
              _row(context, 'Net Area', _area(result.netArea)),
              for (final material in result.materials) ...[
                const Divider(),
                _row(
                  context,
                  '${material.input.kind.label} coats',
                  '${material.input.coats}',
                ),
                _row(
                  context,
                  '${material.input.kind.label} coverage',
                  '${_number(material.input.coverage, 2)} ${material.input.kind.coverageIsConsumption
                      ? 'kg/m²/coat'
                      : material.input.kind.unit == 'kg'
                      ? 'm²/kg'
                      : 'm²/L'}',
                ),
                _row(
                  context,
                  'Coverage basis',
                  material.input.effectiveCoverageBasis ==
                          PaintCoverageBasis.perCoat
                      ? 'Per coat'
                      : 'Complete ${material.input.effectiveCoverageCoats}-coat operation',
                ),
                _row(
                  context,
                  '${material.input.kind.label} wastage',
                  '${_number(material.input.wastagePercent)}% (applied once)',
                ),
                _row(
                  context,
                  'Base quantity',
                  '${_number(material.baseQuantity, 2)} ${material.input.kind.unit}',
                ),
                _row(
                  context,
                  'Final quantity',
                  '${_number(material.finalQuantity, 2)} ${material.input.kind.unit}',
                ),
                if (material.input.puttyPackSizeKg != null)
                  _row(
                    context,
                    'Pack size',
                    '${_number(material.input.puttyPackSizeKg!)} kg',
                  ),
                _row(
                  context,
                  '${material.input.kind.label} reference rate',
                  '${_money(material.input.rate)} / ${material.input.kind.unit}',
                ),
                _row(
                  context,
                  'Material reference',
                  material.input.referenceLabel,
                ),
                Text(material.input.referenceNote),
              ],
              const Divider(),
              _row(context, 'Productivity basis', productivity.standard.name),
              Text(productivity.standard.basis),
              _row(
                context,
                'Painter productivity',
                '${_number(productivity.standard.daysPerBaseQuantity[LabourRole.painter]!)} day / 10 m²',
              ),
              _row(
                context,
                'Helper productivity',
                '${_number(productivity.standard.daysPerBaseQuantity[LabourRole.helper]!)} day / 10 m²',
              ),
              _row(
                context,
                'Painter mandays',
                _number(productivity.mandays[LabourRole.painter]!),
              ),
              _row(
                context,
                'Helper mandays',
                _number(productivity.mandays[LabourRole.helper]!),
              ),
              _row(
                context,
                'Painter daily wage',
                '${_money(labour.dailyWages[LabourRole.painter]!)} / day',
              ),
              _row(
                context,
                'Helper daily wage',
                '${_money(labour.dailyWages[LabourRole.helper]!)} / day',
              ),
              _row(
                context,
                'Painter labour cost',
                _money(labour.costs[LabourRole.painter]!),
              ),
              _row(
                context,
                'Helper labour cost',
                _money(labour.costs[LabourRole.helper]!),
              ),
              const Text(
                'Mandays are total labour. Working days are the maximum role duration after dividing mandays by the selected crew. Labour cost is mandays × daily wage and is not multiplied by crew.',
              ),
              if (result.workType == PaintWorkType.exteriorWalls)
                const Text('Scaffolding/access cost excluded.'),
            ],
          ),
          const SizedBox(height: 12),
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
