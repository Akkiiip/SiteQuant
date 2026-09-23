import '../models/opening_deduction.dart';
import '../models/paint_result.dart';
import '../models/productivity_standard.dart';
import 'estimate_cost_calculator.dart';
import 'estimate_validation.dart';
import 'labour_calculator.dart';
import 'opening_calculator.dart';
import 'paint_productivity.dart';
import 'productivity_calculator.dart';

class PaintCalculator {
  PaintCalculator._();

  static PaintResult calculate({
    required PaintWorkType workType,
    required double grossArea,
    required List<PaintMaterialInput> materials,
    List<OpeningDeduction> openings = const [],
    required Map<LabourRole, int> crew,
    required Map<LabourRole, double> dailyWages,
    required double painterDaysPer10M2,
    required double helperDaysPer10M2,
  }) {
    final takeoff = OpeningCalculator.calculate(
      grossArea: grossArea,
      openings: openings,
    );
    final expected = workType.materials.toSet();
    final supplied = materials.map((material) => material.kind).toSet();
    if (expected.length != materials.length ||
        !supplied.containsAll(expected)) {
      throw ArgumentError(
        'Enter details for every material required by this work type.',
      );
    }
    final estimates = <PaintMaterialEstimate>[
      for (final material in materials) _material(takeoff.netArea, material),
    ];
    final materialCost = EstimateCostCalculator.total(
      estimates.map((estimate) => estimate.cost),
    );
    final productivity = ProductivityCalculator.calculate(
      quantity: takeoff.netArea,
      standard: PaintProductivity.siteSpecific(
        painterDaysPer10M2: painterDaysPer10M2,
        helperDaysPer10M2: helperDaysPer10M2,
      ),
      crew: crew,
    );
    final labour = LabourCalculator.calculate(
      productivity: productivity,
      dailyWages: dailyWages,
    );
    final total = EstimateCostCalculator.total([
      materialCost,
      labour.totalCost,
    ]);
    return PaintResult(
      workType: workType,
      takeoff: takeoff,
      materials: List.unmodifiable(estimates),
      materialCost: materialCost,
      productivity: productivity,
      labour: labour,
      totalCost: total,
      costPerSquareMetre: EstimateCostCalculator.perUnit(
        total,
        takeoff.netArea,
      ),
    );
  }

  static PaintMaterialEstimate _material(
    double netArea,
    PaintMaterialInput input,
  ) {
    EstimateValidation.count(input.coats, '${input.kind.label} coats');
    EstimateValidation.number(input.coverage, '${input.kind.label} coverage');
    if (input.puttyPackSizeKg != null) {
      if (input.kind != PaintMaterialKind.putty) {
        throw ArgumentError('Pack size is only supported for putty.');
      }
      EstimateValidation.number(input.puttyPackSizeKg!, 'Putty pack size');
    }
    EstimateValidation.number(
      input.wastagePercent,
      '${input.kind.label} wastage',
      allowZero: true,
    );
    final base =
        input.kind == PaintMaterialKind.putty &&
            input.puttyCoverageBasis == PuttyCoverageBasis.completeTwoCoats
        ? netArea * input.coats / 2 / input.coverage
        : input.kind.coverageIsConsumption
        ? netArea * input.coats * input.coverage
        : netArea * input.coats / input.coverage;
    final finalQuantity = EstimateValidation.number(
      base * (1 + input.wastagePercent / 100),
      '${input.kind.label} required quantity',
      allowZero: true,
    );
    return PaintMaterialEstimate(
      input: input,
      baseQuantity: base,
      wastageQuantity: finalQuantity - base,
      finalQuantity: finalQuantity,
      cost: EstimateCostCalculator.lineCost(
        finalQuantity,
        input.rate,
        input.kind.label,
      ),
    );
  }
}
