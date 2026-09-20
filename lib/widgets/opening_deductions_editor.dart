import 'package:flutter/material.dart';
import '../models/opening_deduction.dart';
import '../services/measurement_system.dart';
import 'dimension_input_field.dart';

/// Reusable editor. Emits base-unit dimensions; calculation stays in services.
class OpeningDeductionsEditor extends StatefulWidget {
  final ValueChanged<List<OpeningDeduction>> onChanged;
  final VoidCallback? onOpeningAdded;
  const OpeningDeductionsEditor({
    super.key,
    required this.onChanged,
    this.onOpeningAdded,
  });

  @override
  State<OpeningDeductionsEditor> createState() =>
      _OpeningDeductionsEditorState();
}

class _OpeningDraft {
  final name = TextEditingController(text: 'Door');
  final width = TextEditingController();
  final height = TextEditingController();
  final quantity = TextEditingController(text: '1');
  List<TextEditingController> get controllers => [
    name,
    width,
    height,
    quantity,
  ];
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

class _OpeningDeductionsEditorState extends State<OpeningDeductionsEditor> {
  final _drafts = <_OpeningDraft>[];

  void _emit() {
    final system =
        MeasurementPreferences.system.value ?? MeasurementSystem.metric;
    widget.onChanged([
      for (final draft in _drafts)
        OpeningDeduction(
          name: draft.name.text.trim(),
          widthMetres: MeasurementPreferences.toMetres(
            double.tryParse(draft.width.text.trim()) ?? double.nan,
            system,
          ),
          heightMetres: MeasurementPreferences.toMetres(
            double.tryParse(draft.height.text.trim()) ?? double.nan,
            system,
          ),
          quantity: int.tryParse(draft.quantity.text.trim()) ?? 0,
        ),
    ]);
  }

  void _add() {
    final draft = _OpeningDraft();
    for (final controller in draft.controllers) {
      controller.addListener(_emit);
    }
    setState(() => _drafts.add(draft));
    _emit();
    widget.onOpeningAdded?.call();
  }

  void _remove(_OpeningDraft draft) {
    setState(() => _drafts.remove(draft));
    // Text fields finish detaching before their controllers are disposed.
    WidgetsBinding.instance.addPostFrameCallback((_) => draft.dispose());
    _emit();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Enter total opening quantities across all walls/surfaces. '
        'Each opening is deducted once. Use a name such as Door, Window or Vent.',
      ),
      for (var i = 0; i < _drafts.length; i++)
        Padding(
          key: ObjectKey(_drafts[i]),
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Opening ${i + 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove opening ${i + 1}',
                    onPressed: () => _remove(_drafts[i]),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              TextField(
                controller: _drafts[i].name,
                decoration: const InputDecoration(
                  labelText: 'Opening type / name',
                ),
              ),
              const SizedBox(height: 12),
              DimensionInputField(
                controller: _drafts[i].width,
                label: 'Opening width',
              ),
              const SizedBox(height: 12),
              DimensionInputField(
                controller: _drafts[i].height,
                label: 'Opening height',
              ),
              const SizedBox(height: 12),
              DimensionInputField(
                controller: _drafts[i].quantity,
                label: 'Opening quantity',
                unit: null,
                wholeNumber: true,
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add opening'),
      ),
    ],
  );
}
