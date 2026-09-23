import 'package:flutter/material.dart';
import '../models/volume_result.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/primary_button.dart';

class VolumeResultScreen extends StatelessWidget {
  final VolumeResult result;
  final String shape, dimensions;
  const VolumeResultScreen({
    super.key,
    required this.result,
    required this.shape,
    required this.dimensions,
  });
  String _n(double value, [int p = 3]) =>
      value.toStringAsFixed(p).replaceFirst(RegExp(r'\.?0+$'), '');
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Calculation Result',
      bodyBuilder: (context, padding) => ListView(
        padding: padding,
        children: [
          ResultHeader(
            label: 'Calculated Volume',
            value: '${_n(result.m3)} m³',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculation Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _r(context, 'Selected Shape', shape),
                  _r(context, 'Input Dimensions', dimensions),
                  _r(context, 'Volume', '${_n(result.m3)} m³'),
                  _r(context, 'Volume', '${_n(result.ft3)} ft³'),
                  _r(context, 'Volume', '${_n(result.brass)} Brass'),
                  _r(context, 'Volume', '${_n(result.litres)} Litres'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.restart_alt_rounded,
            label: 'New Calculation',
          ),
        ],
      ),
    );
  }

  Widget _r(BuildContext c, String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(l)),
        Flexible(
          child: Text(
            v,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(c).textTheme.labelLarge,
          ),
        ),
      ],
    ),
  );
}
