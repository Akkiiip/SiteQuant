import 'package:flutter/material.dart';

import '../models/masonry_result.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class MasonryResultScreen extends StatelessWidget {
  final MasonryResult result;
  final MasonryType type;
  final String unitSize;
  final double thicknessMm;
  final String mortarRatio;
  final double wastagePercent;
  const MasonryResultScreen({super.key, required this.result, required this.type, required this.unitSize, required this.thicknessMm, required this.mortarRatio, required this.wastagePercent});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(title: 'Calculation Result', bodyBuilder: (context, padding) => ListView(padding: padding, children: [
      Text('Masonry Takeoff', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 5), Text('Estimated quantities for your selected masonry.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 16),
      Card(color: colors.primary, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.view_in_ar_rounded, color: Colors.white)),
        const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Masonry Volume', style: TextStyle(color: Colors.white.withValues(alpha: .78))), const SizedBox(height: 2), Text('${result.masonryVolume.toStringAsFixed(2)} m³', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))]))
      ]))),
      const SizedBox(height: 12), _TakeoffCard(result: result, type: type), const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Calculation Summary', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10),
        _summary(context, 'Masonry Type', type.label), _summary(context, 'Unit Size Used', unitSize), _summary(context, 'Wall Thickness', '${thicknessMm.toStringAsFixed(0)} mm'), _summary(context, 'Mortar Ratio', mortarRatio), _summary(context, 'Wastage', '${wastagePercent.toStringAsFixed(1)}%'),
      ]))),
      const SizedBox(height: 16), PrimaryButton(onPressed: () => Navigator.pop(context), icon: Icons.restart_alt_rounded, label: 'New Calculation'),
    ]));
  }

  Widget _summary(BuildContext context, String label, String value) => Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [Expanded(child: Text(label)), Flexible(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: Theme.of(context).textTheme.labelLarge))]));
}

class _TakeoffCard extends StatelessWidget {
  final MasonryResult result;
  final MasonryType type;
  const _TakeoffCard({required this.result, required this.type});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text('Material Takeoff', style: Theme.of(context).textTheme.titleMedium)]), const SizedBox(height: 12),
    _row(context, 'Wall Area', [('m²', result.wallArea.toStringAsFixed(2))]), const Divider(height: 24),
    _row(context, type.unitLabel, [('Nos.', '${result.unitCount}')]), const Divider(height: 24),
    _row(context, 'Mortar Volume', [('m³', result.mortarVolume.toStringAsFixed(3))]), const Divider(height: 24),
    _row(context, 'Cement', [('Bags', result.cementBags.toStringAsFixed(1)), ('kg', '${result.cementKg.round()}')]), const Divider(height: 24),
    _row(context, 'Sand', [('m³', result.sandM3.toStringAsFixed(2)), ('Brass', result.sandBrass.toStringAsFixed(2))]),
  ])));

  Widget _row(BuildContext context, String title, List<(String, String)> values) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text(title, style: Theme.of(context).textTheme.titleSmall)), Expanded(child: Row(children: values.map((value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value.$1, style: Theme.of(context).textTheme.labelSmall), Text(value.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700))]))).toList()))]);
}
