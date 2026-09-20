import 'package:flutter/material.dart';
import '../models/plaster_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_cost_calculator.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../services/opening_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class PlasterResultScreen extends StatelessWidget {
  final PlasterResult result;
  final PlasterType type;
  final MeasurementSystem system;
  const PlasterResultScreen({
    super.key,
    required this.result,
    required this.type,
    required this.system,
  });

  String _area(double value) =>
      '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, system), 2)} ${system.areaUnit}';
  String _volume(double value) =>
      '${EstimateFormat.number(MeasurementPreferences.fromCubicMetres(value, system))} ${system.volumeUnit}';
  String _days(double value) => EstimateFormat.number(value, 4);

  @override
  Widget build(BuildContext context) {
    final productivity = result.productivity;
    final standard = productivity.standard;
    final labour = result.labour;
    final displayedArea = MeasurementPreferences.fromSquareMetres(
      result.area,
      system,
    );
    final displayUnitCost = EstimateCostCalculator.perUnit(
      result.totalCost,
      displayedArea,
    );
    return AppScaffold(
      title: 'Calculation Result',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text(
            'Plaster Takeoff V2',
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
                  const Text('Net Plaster Area'),
                  Text(
                    _area(result.area),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Gross ${_area(result.grossArea)} − deductions ${_area(result.deductionArea)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(context, 'Plaster Quantity', Icons.format_paint_outlined, [
            _row(context, 'Plaster Type', type.label),
            _row(context, 'Gross Area', _area(result.grossArea)),
            _row(context, 'Opening Deductions', _area(result.deductionArea)),
            for (final opening in result.takeoff.openings)
              _row(
                context,
                '${opening.name} × ${opening.quantity}',
                _area(OpeningCalculator.openingArea(opening)),
              ),
            _row(context, 'Net Area', _area(result.area)),
            _row(
              context,
              'Thickness',
              '${EstimateFormat.number(result.thicknessMm)} mm',
            ),
            _row(
              context,
              'Mortar Ratio',
              '${EstimateFormat.number(result.cementPart)} : ${EstimateFormat.number(result.sandPart)}',
            ),
            _row(
              context,
              'Wastage',
              '${EstimateFormat.number(result.wastagePercent)}%',
            ),
            _row(context, 'Wet Volume', _volume(result.wetVolume)),
            _row(context, 'Dry Volume', _volume(result.dryVolume)),
            _row(
              context,
              'Cement',
              '${EstimateFormat.number(result.cementBags, 2)} bags (50 kg)',
            ),
            _row(context, 'Sand', _volume(result.sandM3)),
            _row(
              context,
              'Sand in Brass',
              EstimateFormat.number(result.sandBrass),
            ),
            const Text(
              'Dry factor 1.33. Wastage is applied once to dry material volume. '
              'Cement bags are not rounded up for costing.',
            ),
          ]),
          _section(context, 'Material Cost', Icons.payments_outlined, [
            _row(
              context,
              'Cement Rate',
              '${EstimateFormat.money(result.cementRate)} / 50 kg bag',
            ),
            _row(
              context,
              'Cement Cost',
              EstimateFormat.money(result.cementCost),
            ),
            _row(
              context,
              'Sand Rate',
              '${EstimateFormat.money(result.sandRate)} / m³',
            ),
            if (system == MeasurementSystem.imperial)
              _row(
                context,
                'Sand quantity for pricing',
                '${EstimateFormat.number(result.sandM3)} m³',
              ),
            _row(context, 'Sand Cost', EstimateFormat.money(result.sandCost)),
            _row(
              context,
              'Total Material Cost',
              EstimateFormat.money(result.materialCost),
            ),
          ]),
          _section(context, 'Labour & Time', Icons.groups_outlined, [
            _row(context, 'Standard Productivity', standard.name),
            Text(standard.basis),
            const SizedBox(height: 10),
            for (final role in LabourRole.values)
              _row(
                context,
                '${role.label} coefficient',
                '${_days(standard.daysPerBaseQuantity[role]!)} day / ${_area(standard.baseQuantity)}',
              ),
            for (final role in LabourRole.values)
              _row(
                context,
                '${role.label} productivity',
                '${_area(standard.baseQuantity / standard.daysPerBaseQuantity[role]!)} / person-day',
              ),
            _row(
              context,
              'Selected Crew',
              '${productivity.crew[LabourRole.mason]} Mason(s) + '
                  '${productivity.crew[LabourRole.helper]} Helper(s)',
            ),
            _row(
              context,
              'Selected crew productivity',
              '${_area(productivity.crewOutputPerDay)} / day',
            ),
            _row(
              context,
              'Mason Mandays',
              _days(productivity.mandays[LabourRole.mason]!),
            ),
            _row(
              context,
              'Helper Mandays',
              _days(productivity.mandays[LabourRole.helper]!),
            ),
            _row(
              context,
              'Estimated Working Days',
              _days(productivity.workingDays),
            ),
            Text(
              'Duration = the greater of mason mandays ÷ masons and helper mandays ÷ helpers. '
              'Assumes parallel work fronts; excludes curing, access delays and holidays.',
            ),
            if (type == PlasterType.ceiling)
              const Text(
                'Ceiling estimate: confirm productivity for overhead work and access.',
              ),
            _row(
              context,
              'Mason Daily Wage',
              '${EstimateFormat.money(labour.dailyWages[LabourRole.mason]!)} / day',
            ),
            _row(
              context,
              'Helper Daily Wage',
              '${EstimateFormat.money(labour.dailyWages[LabourRole.helper]!)} / day',
            ),
            _row(
              context,
              'Mason Labour Cost',
              EstimateFormat.money(labour.costs[LabourRole.mason]!),
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
            const Text(
              'Labour cost uses each role’s required mandays, not full-crew '
              'attendance rounded to whole days. Actual site duration may differ.',
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
              'Total Plaster Cost',
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
            const Text(
              'Estimate covers the materials and two labour roles shown. '
              'Scaffolding, transport, taxes, overheads and other site costs are excluded.',
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
