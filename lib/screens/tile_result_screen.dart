import 'package:flutter/material.dart';
import '../models/productivity_standard.dart';
import '../models/tile_result.dart';
import '../services/estimate_format.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class TileResultScreen extends StatelessWidget {
  final TileResult result;
  const TileResultScreen({super.key, required this.result});
  String _n(double v, [int p = 2]) => EstimateFormat.number(v, p);
  String _area(double v) => '${_n(v)} m2';
  @override
  Widget build(BuildContext context) {
    final l = result.labour, p = result.productivity;
    return AppScaffold(
      title: 'Tiles & Flooring Estimate',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          Text(
            'Tiles & Flooring Estimate',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _section(context, 'Estimate Summary', Icons.summarize_outlined, [
            _row(context, 'Net Area', _area(result.netArea)),
            _row(context, 'Tile Quantity', '${result.tileQuantity} nos'),
            _row(
              context,
              'Material Cost',
              EstimateFormat.money(result.materialCost),
            ),
            _row(context, 'Labour Cost', EstimateFormat.money(l.totalCost)),
            _row(context, 'Total Cost', EstimateFormat.money(result.totalCost)),
            _row(
              context,
              'Cost per m2',
              result.costPerSquareMetre == null
                  ? 'Not applicable'
                  : EstimateFormat.money(result.costPerSquareMetre!),
            ),
          ]),
          _section(context, 'Materials', Icons.inventory_2_outlined, [
            for (final m in result.materials)
              _row(
                context,
                m.name,
                '${_n(m.quantity)} ${m.unit} - ${EstimateFormat.money(m.cost)}',
              ),
          ]),
          _section(context, 'Labour & Time', Icons.groups_outlined, [
            _row(
              context,
              'Crew',
              '${p.crew[LabourRole.tileMason]} Tile Mason(s) + ${p.crew[LabourRole.helper]} Helper(s)',
            ),
            _row(context, 'Working Days', '${_n(p.workingDays)} days'),
            _row(context, 'Labour Cost', EstimateFormat.money(l.totalCost)),
          ]),
          _section(context, 'Calculation Details', Icons.expand_more_rounded, [
            ExpansionTile(
              title: const Text('Calculation Details'),
              children: [
                _row(context, 'Work Type', result.workType.label),
                _row(context, 'Gross Area', _area(result.grossArea)),
                _row(context, 'Deductions', _area(result.deductionArea)),
                _row(
                  context,
                  'Tile size',
                  '${_n(result.tileLengthMm, 0)} x ${_n(result.tileWidthMm, 0)} mm',
                ),
                _row(context, 'Tile area', _area(result.tileAreaSquareMetres)),
                _row(
                  context,
                  'Base tile quantity',
                  _n(result.baseTileQuantity),
                ),
                _row(
                  context,
                  'Tile wastage',
                  '${_n(result.tileWastagePercent)}%',
                ),
                _row(
                  context,
                  'Coverage including wastage',
                  _area(result.tileCoverageSquareMetres),
                ),
                for (final m in result.materials)
                  _row(
                    context,
                    '${m.name} reference rate',
                    '${EstimateFormat.money(m.rate)} / ${m.unit}',
                  ),
                _row(context, 'Productivity basis', p.standard.name),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(p.standard.basis),
                ),
                _row(
                  context,
                  'Tile Mason mandays',
                  _n(p.mandays[LabourRole.tileMason]!),
                ),
                _row(
                  context,
                  'Helper mandays',
                  _n(p.mandays[LabourRole.helper]!),
                ),
                _row(
                  context,
                  'Tile Mason daily wage',
                  '${EstimateFormat.money(l.dailyWages[LabourRole.tileMason]!)} / day',
                ),
                _row(
                  context,
                  'Helper daily wage',
                  '${EstimateFormat.money(l.dailyWages[LabourRole.helper]!)} / day',
                ),
                _row(
                  context,
                  'Tile Mason labour cost',
                  EstimateFormat.money(l.costs[LabourRole.tileMason]!),
                ),
                _row(
                  context,
                  'Helper labour cost',
                  EstimateFormat.money(l.costs[LabourRole.helper]!),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(result.referenceNote),
                ),
              ],
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
    BuildContext c,
    String t,
    IconData i,
    List<Widget> children,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: t, icon: i, compact: true),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    ),
  );
  Widget _row(BuildContext c, String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(a)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            b,
            textAlign: TextAlign.end,
            style: Theme.of(c).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}
