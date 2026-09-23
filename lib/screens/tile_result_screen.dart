import 'package:flutter/material.dart';

import '../models/productivity_standard.dart';
import '../models/tile_result.dart';
import '../services/estimate_format.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';

class TileResultScreen extends StatelessWidget {
  const TileResultScreen({super.key, required this.result});
  final TileResult result;

  String _n(double value, [int precision = 2]) =>
      EstimateFormat.number(value, precision);
  String _money(double value) => '₹${_n(value)}';
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  Widget _section(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = result.productivity;
    final labour = result.labour;
    return AppScaffold(
      title: 'Tiles & Flooring Results',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          ResultHeader(label: 'NET AREA', value: '${_n(result.netArea)} m²'),
          const SizedBox(height: 10),
          MaterialRequirementCard(
            materials: [
              MaterialRequirement(
                'Tile Quantity',
                '${result.tileQuantity} pieces',
                Icons.grid_on_rounded,
              ),
              MaterialRequirement(
                'Required Area',
                '${_n(result.tileCoverageSquareMetres)} m²',
                Icons.square_foot_rounded,
              ),
              MaterialRequirement(
                'Wastage',
                '${_n(result.tileWastagePercent)}%',
                Icons.percent_rounded,
              ),
            ],
          ),
          _section('LABOUR & TIME', [
            _row(
              'Crew',
              '${p.crew[LabourRole.tileMason]} Tile Mason(s) + ${p.crew[LabourRole.helper]} Helper(s)',
            ),
            _row('Working Days', '${_n(p.workingDays)} days'),
            _row('Labour Cost', _money(labour.totalCost)),
          ]),
          _section('TOTAL COST', [
            _row('Material Cost', _money(result.materialCost)),
            _row('Labour Cost', _money(labour.totalCost)),
            _row('Total', _money(result.totalCost)),
          ]),
          Card(
            child: ExpansionTile(
              title: const Text('Material Breakdown'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                for (final material in result.materials)
                  _row(
                    material.name,
                    '${_n(material.quantity)} ${material.unit} · ${_money(material.cost)}',
                  ),
              ],
            ),
          ),
          Card(
            child: ExpansionTile(
              title: const Text('Labour & Time Details'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _row(
                  'Tile Mason mandays',
                  _n(p.mandays[LabourRole.tileMason]!),
                ),
                _row('Helper mandays', _n(p.mandays[LabourRole.helper]!)),
                _row(
                  'Tile Mason wage',
                  '${_money(labour.dailyWages[LabourRole.tileMason]!)} / day',
                ),
                _row(
                  'Helper wage',
                  '${_money(labour.dailyWages[LabourRole.helper]!)} / day',
                ),
              ],
            ),
          ),
          CalculationDetails(
            children: [
              _row('Work Type', result.workType.label),
              _row('Gross Area', '${_n(result.grossArea)} m²'),
              _row('Opening Deductions', '${_n(result.deductionArea)} m²'),
              _row('Net Area', '${_n(result.netArea)} m²'),
              _row(
                'Tile Size',
                '${_n(result.tileLengthMm, 0)} × ${_n(result.tileWidthMm, 0)} mm',
              ),
              _row('Base Pieces', _n(result.baseTileQuantity)),
              _row('Tile Area', '${_n(result.tileAreaSquareMetres, 4)} m²'),
              _row('Reference Productivity', p.standard.name),
              Text(p.standard.basis),
              Text(result.referenceNote),
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
}
