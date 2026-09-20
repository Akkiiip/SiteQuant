import 'dart:math';
import '../models/productivity_standard.dart';
import 'estimate_validation.dart';

class ProductivityCalculator {
  static ProductivityEstimate calculate({
    required double quantity,
    required ProductivityStandard standard,
    required Map<LabourRole, int> crew,
  }) {
    EstimateValidation.number(quantity, 'Work quantity', allowZero: true);
    EstimateValidation.number(standard.baseQuantity, 'Productivity basis');
    EstimateValidation.count(standard.maximumCrewPerRole, 'Crew limit');
    if (standard.daysPerBaseQuantity.isEmpty ||
        crew.length != standard.daysPerBaseQuantity.length) {
      throw ArgumentError('Select a crew for every labour role.');
    }
    final mandays = <LabourRole, double>{};
    var durationPerUnit = 0.0;
    for (final entry in standard.daysPerBaseQuantity.entries) {
      final coefficient = EstimateValidation.number(
        entry.value,
        '${entry.key.label} productivity coefficient',
      );
      final people = EstimateValidation.count(
        crew[entry.key] ?? 0,
        '${entry.key.label} crew',
        maximum: standard.maximumCrewPerRole,
      );
      final daysPerUnit = coefficient / standard.baseQuantity;
      mandays[entry.key] = EstimateValidation.number(
        quantity * daysPerUnit,
        '${entry.key.label} mandays',
        allowZero: true,
      );
      durationPerUnit = max(durationPerUnit, daysPerUnit / people);
    }
    final output = EstimateValidation.number(
      1 / durationPerUnit,
      'Crew productivity',
    );
    final duration = EstimateValidation.number(
      quantity * durationPerUnit,
      'Estimated working days',
      allowZero: true,
    );
    return ProductivityEstimate(
      standard: standard,
      mandays: mandays,
      crew: crew,
      workingDays: duration,
      crewOutputPerDay: output,
    );
  }
}
