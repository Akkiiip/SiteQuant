import 'package:flutter/material.dart';
import '../models/steel_weight_result.dart';
import '../services/steel_weight_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class SteelWeightResultScreen extends StatelessWidget {
  final SteelWeightResult result;
  const SteelWeightResultScreen({super.key, required this.result});
  String _number(double value, [int precision = 3]) => value.toStringAsFixed(precision).replaceFirst(RegExp(r'\.?0+$'), '');
  @override Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return AppScaffold(title: 'Calculation Result', bodyBuilder: (context, padding) => ListView(padding: padding, children: [
    Text('Steel Weight', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 5), Text('Estimated reinforcement bar weight.', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 16),
    Card(color: colors.primary, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.hardware_rounded, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Weight', style: TextStyle(color: Colors.white.withValues(alpha: .78))), Text('${_number(result.totalWeight, 2)} kg', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))]))]))), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Calculation Summary', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), _row(context, 'Bar Diameter', '${result.diameter} mm'), _row(context, 'Unit Weight', '${_number(result.unitWeight)} kg/m'), _row(context, 'Bar Length', '${_number(result.barLength, 2)} m'), _row(context, 'Number of Bars', '${result.barCount}'), _row(context, 'Weight per Bar', '${_number(result.weightPerBar, 2)} kg'), _row(context, 'Total Weight', '${_number(result.totalWeight, 2)} kg')]))), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Quick Reference', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), ...SteelWeightCalculator.unitWeights.entries.map((entry) => _row(context, '${entry.key} mm', '${entry.value.toStringAsFixed(3)} kg/m'))]))), const SizedBox(height: 16), PrimaryButton(onPressed: () => Navigator.pop(context), icon: Icons.restart_alt_rounded, label: 'New Calculation'),
  ])); }
  Widget _row(BuildContext context, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(label)), Text(value, style: Theme.of(context).textTheme.labelLarge)]));
}
