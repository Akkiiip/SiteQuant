import 'package:flutter/material.dart';
import '../models/plaster_result.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class PlasterResultScreen extends StatelessWidget {
  final PlasterResult result; final PlasterType type; final double thicknessMm, wastagePercent; final String mortarRatio;
  const PlasterResultScreen({super.key, required this.result, required this.type, required this.thicknessMm, required this.mortarRatio, required this.wastagePercent});
  String _number(double value, [int precision = 3]) => value.toStringAsFixed(precision).replaceFirst(RegExp(r'\.?0+$'), '');
  @override Widget build(BuildContext context) { final colors = Theme.of(context).colorScheme; return AppScaffold(title: 'Calculation Result', bodyBuilder: (context, padding) => ListView(padding: padding, children: [
    Text('Plaster Takeoff', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 5), Text('Estimated plaster material quantities.', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 16),
    Card(color: colors.primary, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.format_paint_rounded, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Area', style: TextStyle(color: Colors.white.withValues(alpha: .78))), Text('${_number(result.area, 2)} m²', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))]))]))), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Material Takeoff', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), _row(context, 'Wet Volume', '${_number(result.wetVolume)} m³'), _row(context, 'Dry Volume', '${_number(result.dryVolume)} m³'), _row(context, 'Cement Bags', _number(result.cementBags, 2)), _row(context, 'Sand', '${_number(result.sandM3)} m³'), _row(context, 'Sand', '${_number(result.sandBrass)} Brass')]))), const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Calculation Summary', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), _row(context, 'Plaster Type', type.label), _row(context, 'Area', '${_number(result.area, 2)} m²'), _row(context, 'Thickness', '${_number(thicknessMm, 0)} mm'), _row(context, 'Mortar Ratio', mortarRatio), _row(context, 'Wastage', '${_number(wastagePercent, 1)}%')]))), const SizedBox(height: 16), PrimaryButton(onPressed: () => Navigator.pop(context), icon: Icons.restart_alt_rounded, label: 'New Calculation'),
  ])); }
  Widget _row(BuildContext context, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(label)), Flexible(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: Theme.of(context).textTheme.labelLarge))]));
}
