import 'dart:math' as math;

import '../models/productivity_standard.dart';
import '../models/water_tank_input.dart';
import '../models/water_tank_result.dart';
import 'estimate_cost_calculator.dart';
import 'estimate_validation.dart';
import 'labour_calculator.dart';
import 'productivity_calculator.dart';

/// Calculates a simple closed RCC tank: base slab, side walls and top slab.
/// All dimensions are internal metric dimensions in metres; volumes include
/// [WaterTankInput.quantity]. Water depth is the vertical wall height.
class WaterTankCalculator {
  WaterTankCalculator._();

  static WaterTankResult calculate(WaterTankInput input) {
    _validate(input);
    final outerLength = input.type == WaterTankType.rectangular
        ? input.internalLength + 2 * input.wallThickness
        : 0.0;
    final outerWidthOrDiameter =
        input.internalWidthOrDiameter + 2 * input.wallThickness;

    final perTank = input.type == WaterTankType.rectangular
        ? _rectangularVolumes(input, outerLength, outerWidthOrDiameter)
        : _circularVolumes(input, outerWidthOrDiameter);
    final base = perTank.$1 * input.quantity;
    final walls = perTank.$2 * input.quantity;
    final top = perTank.$3 * input.quantity;
    final total = EstimateValidation.number(
      base + walls + top,
      'Total RCC volume',
    );
    final materialCost = EstimateCostCalculator.lineCost(
      total,
      input.rccRatePerCubicMetre,
      'RCC material',
    );
    final productivity = ProductivityCalculator.calculate(
      quantity: total,
      standard: ProductivityStandard(
        name: 'Reference water-tank RCC productivity',
        basis:
            'Editable reference estimate; not a universal productivity standard.',
        baseQuantity: 1,
        daysPerBaseQuantity: {
          LabourRole.mason: input.masonDaysPerCubicMetre,
          LabourRole.helper: input.helperDaysPerCubicMetre,
        },
      ),
      crew: input.crew,
    );
    final labour = LabourCalculator.calculate(
      productivity: productivity,
      dailyWages: input.dailyWages,
    );
    return WaterTankResult(
      input: input,
      outerLength: outerLength,
      outerWidthOrDiameter: outerWidthOrDiameter,
      baseSlabVolume: base,
      wallVolume: walls,
      topSlabVolume: top,
      totalRccVolume: total,
      materialCost: materialCost,
      productivity: productivity,
      labour: labour,
      totalCost: EstimateCostCalculator.total([materialCost, labour.totalCost]),
    );
  }

  static (double, double, double) _rectangularVolumes(
    WaterTankInput input,
    double outerLength,
    double outerWidth,
  ) {
    final outerFootprint = outerLength * outerWidth;
    final innerFootprint = input.internalLength * input.internalWidthOrDiameter;
    return (
      outerFootprint * input.baseSlabThickness,
      (outerFootprint - innerFootprint) * input.waterDepth,
      outerFootprint * input.topSlabThickness,
    );
  }

  static (double, double, double) _circularVolumes(
    WaterTankInput input,
    double outerDiameter,
  ) {
    final outerArea = math.pi * outerDiameter * outerDiameter / 4;
    final innerArea =
        math.pi *
        input.internalWidthOrDiameter *
        input.internalWidthOrDiameter /
        4;
    return (
      outerArea * input.baseSlabThickness,
      (outerArea - innerArea) * input.waterDepth,
      outerArea * input.topSlabThickness,
    );
  }

  static void _validate(WaterTankInput input) {
    EstimateValidation.number(input.internalLength, 'Internal length');
    EstimateValidation.number(
      input.internalWidthOrDiameter,
      input.type == WaterTankType.circular
          ? 'Internal diameter'
          : 'Internal width',
    );
    EstimateValidation.number(input.waterDepth, 'Water depth');
    EstimateValidation.number(input.wallThickness, 'Wall thickness');
    EstimateValidation.number(input.baseSlabThickness, 'Base slab thickness');
    EstimateValidation.number(input.topSlabThickness, 'Top slab thickness');
    EstimateValidation.count(input.quantity, 'Quantity');
    EstimateValidation.number(input.rccRatePerCubicMetre, 'RCC rate');
    EstimateValidation.number(
      input.masonDaysPerCubicMetre,
      'Mason productivity',
    );
    EstimateValidation.number(
      input.helperDaysPerCubicMetre,
      'Helper productivity',
    );
    if (input.type == WaterTankType.circular &&
        input.internalLength != input.internalWidthOrDiameter) {
      throw ArgumentError(
        'Circular tanks use the internal diameter for both plan dimensions.',
      );
    }
  }
}
