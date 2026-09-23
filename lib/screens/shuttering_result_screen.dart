import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/calculator_ui.dart';
import '../models/shuttering_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_format.dart';
import '../services/shuttering_reference_defaults.dart';

class ShutteringResultScreen extends StatelessWidget {
  final ShutteringResult result;
  const ShutteringResultScreen({super.key, required this.result});
  String _n(double v) => EstimateFormat.number(v, 2);
  String _money(double v) {
    final whole = EstimateFormat.number(v, 0);
    return '₹${whole.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
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
    final r = result, p = r.productivity, l = r.labour;
    final roles = [LabourRole.carpenter, LabourRole.helper];
    final controlling = roles.reduce(
      (a, b) =>
          p.mandays[a]! / p.crew[a]! >= p.mandays[b]! / p.crew[b]! ? a : b,
    );
    final crew =
        '${p.crew[LabourRole.carpenter]} Carpenter + ${p.crew[LabourRole.helper]} Helper';

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text('Shuttering Estimate'),
        backgroundColor: AppTheme.pageBackground,
        foregroundColor: AppTheme.ink,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ResultHeader(
                label: 'Shuttering Contact Area',
                value: '${_n(r.contactArea)} m²',
              ),
              const SizedBox(height: 10),
              _card('Estimate Summary', [
                _row('Contact Area', '${_n(r.contactArea)} m²'),
                _row('Material / Panel Area', '${_n(r.panelArea)} m²'),
                _row('Material Cost', _money(r.materialCost)),
                _row('Labour Cost', _money(l.totalCost)),
                _row('Total Cost', _money(r.totalCost)),
                _row(
                  'Cost / m²',
                  r.costPerSquareMetre == null
                      ? 'Not applicable'
                      : _money(r.costPerSquareMetre!),
                ),
              ]),
              _card('Labour & Time', [
                _row('Crew', crew),
                _row('Working Days', '${_n(p.workingDays)} days'),
                _row('Labour Cost', _money(l.totalCost)),
              ]),
              Card(
                child: ExpansionTile(
                  title: const Text('Calculation Details'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    _row('Element', r.type.label),
                    _row('Length', '${_n(r.length)} m'),
                    _row(
                      r.type == ShutteringType.wall ? 'Thickness' : 'Width',
                      '${_n(r.width)} m',
                    ),
                    if (r.type != ShutteringType.slab)
                      _row(
                        r.type == ShutteringType.beam ||
                                r.type == ShutteringType.footing
                            ? 'Depth'
                            : 'Height',
                        '${_n(r.height)} m',
                      ),
                    _row('Quantity', '${r.quantity}'),
                    if (r.type == ShutteringType.wall)
                      _row('Wall sides', '${r.wallSides}'),
                    _row('Contact-area formula', r.type.formula),
                    _row('Contact Area', '${_n(r.contactArea)} m²'),
                    Text(switch (r.type) {
                      ShutteringType.column || ShutteringType.footing =>
                        'Vertical side faces only; top and bottom excluded.',
                      ShutteringType.beam =>
                        'Two sides and soffit; top excluded.',
                      ShutteringType.wall =>
                        'Main wall faces only; ends and edges excluded.',
                      ShutteringType.slab =>
                        'Soffit only; perimeter edges excluded.',
                    }),
                    _row('Panel wastage', '${_n(r.wastagePercent)}%'),
                    _row(
                      'Material-only reference rate',
                      '${_money(r.materialRate)}/m²',
                    ),
                    Text(p.standard.basis),
                    for (final role in roles) ...[
                      _row(
                        '${role == LabourRole.helper ? 'Helper' : role.label} productivity',
                        '${_n(p.standard.daysPerBaseQuantity[role]!)} days / ${_n(p.standard.baseQuantity)} m²',
                      ),
                      _row(
                        '${role == LabourRole.helper ? 'Helper' : role.label} mandays',
                        _n(p.mandays[role]!),
                      ),
                      _row(
                        '${role == LabourRole.helper ? 'Helper' : role.label} wage',
                        '${_money(l.dailyWages[role]!)}/day',
                      ),
                      _row(
                        '${role == LabourRole.helper ? 'Helper' : role.label} cost',
                        _money(l.costs[role]!),
                      ),
                    ],
                    _row(
                      'Controlling role',
                      controlling == LabourRole.helper ? 'Helper' : 'Carpenter',
                    ),
                    const Text(
                      'Working days use the greater role mandays divided by its crew count. Panel wastage does not increase labour.',
                    ),
                    Text(ShutteringReferenceDefaults.standard.note),
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
