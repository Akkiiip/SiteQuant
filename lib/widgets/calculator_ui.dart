import 'package:flutter/material.dart';

import '../services/measurement_system.dart';
import '../theme/app_theme.dart';
import 'dimension_input_field.dart';

class CalculatorHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const CalculatorHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    ),
  );
}

class CalculatorTypeTabs extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;
  const CalculatorTypeTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final label in labels)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected == label,
              onSelected: (_) => onSelected(label),
              selectedColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: selected == label ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected == label
                    ? AppTheme.primaryBlue
                    : AppTheme.border,
              ),
            ),
          ),
      ],
    ),
  );
}

class EngineeringDiagramCard extends StatelessWidget {
  final String label;
  final Widget diagram;
  const EngineeringDiagramCard({
    super.key,
    required this.label,
    required this.diagram,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          diagram,
        ],
      ),
    ),
  );
}

class MetricImperialToggle extends StatelessWidget {
  final ValueChanged<MeasurementSystem>? onChanged;
  const MetricImperialToggle({super.key, this.onChanged});
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<MeasurementSystem?>(
        valueListenable: MeasurementPreferences.system,
        builder: (context, value, _) {
          final selected = value ?? MeasurementSystem.metric;
          return Row(
            children: [
              const Expanded(
                child: Text(
                  'Units',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SegmentedButton<MeasurementSystem>(
                segments: const [
                  ButtonSegment(
                    value: MeasurementSystem.metric,
                    label: Text('Metric'),
                  ),
                  ButtonSegment(
                    value: MeasurementSystem.imperial,
                    label: Text('Imperial'),
                  ),
                ],
                selected: {selected},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  MeasurementPreferences.setSystem(selection.first);
                  onChanged?.call(selection.first);
                },
              ),
            ],
          );
        },
      );
}

class CalculatorInputRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? unit;
  final bool wholeNumber;
  const CalculatorInputRow({
    super.key,
    required this.controller,
    required this.label,
    this.unit = 'm',
    this.wholeNumber = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DimensionInputField(
      controller: controller,
      label: label,
      unit: unit,
      wholeNumber: wholeNumber,
    ),
  );
}

class CalculatorAdvancedOptions extends StatelessWidget {
  final List<Widget> children;
  const CalculatorAdvancedOptions({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: const Text('Advanced Options'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: children,
    ),
  );
}

class CalculatorCalculateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const CalculatorCalculateButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calculate_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class ResultHeader extends StatelessWidget {
  final String label;
  final String value;
  const ResultHeader({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.view_in_ar_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MaterialRequirementCard extends StatelessWidget {
  final List<MaterialRequirement> materials;
  const MaterialRequirementCard({super.key, required this.materials});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Requirement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < materials.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(materials[i].icon, color: AppTheme.navy, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(materials[i].label)),
                  Flexible(
                    child: Text(
                      materials[i].value,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class MaterialRequirement {
  final String label;
  final String value;
  final IconData icon;
  const MaterialRequirement(this.label, this.value, this.icon);
}

class ResultActions extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  const ResultActions({super.key, this.onSave, this.onShare});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.bookmark_border_rounded),
          label: const Text('Save'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share'),
        ),
      ),
    ],
  );
}

class CalculationDetails extends StatelessWidget {
  final List<Widget> children;
  const CalculationDetails({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: const Text('Calculation Details'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: children,
    ),
  );
}
