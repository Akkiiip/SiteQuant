import '../models/opening_deduction.dart';
import '../models/plaster_result.dart';
import '../models/productivity_standard.dart';
import 'estimate_cost_calculator.dart';
import 'estimate_validation.dart';
import 'labour_calculator.dart';
import 'opening_calculator.dart';
import 'plaster_productivity.dart';
import 'productivity_calculator.dart';

class PlasterCalculator {
  static const _dryFactor = 1.33,
      _cementDensity = 1440.0,
      _bagWeight = 50.0,
      _brassM3 = 2.8316846592;

  /// [area] is gross m². Openings are deducted exactly once here.
  /// Thickness stays in mm until the original material formula converts it.
  static PlasterResult calculate({
    required double area,
    required double thicknessMm,
    required double cementPart,
    required double sandPart,
    required double wastagePercent,
    List<OpeningDeduction> openings = const [],
    required double cementRate,
    required double sandRate,
    required Map<LabourRole, int> crew,
    required Map<LabourRole, double> dailyWages,
    ProductivityStandard? productivityStandard,
  }) {
    EstimateValidation.number(thicknessMm, 'Thickness');
    EstimateValidation.number(cementPart, 'Cement ratio');
    EstimateValidation.number(sandPart, 'Sand ratio');
    EstimateValidation.number(wastagePercent, 'Wastage', allowZero: true);
    final takeoff = OpeningCalculator.calculate(
      grossArea: area,
      openings: openings,
    );
    final wet = EstimateValidation.number(
      takeoff.netArea * thicknessMm / 1000,
      'Wet volume',
      allowZero: true,
    );
    final dry = EstimateValidation.number(
      wet * _dryFactor,
      'Dry volume',
      allowZero: true,
    );
    final materials = EstimateValidation.number(
      dry * (1 + wastagePercent / 100),
      'Material volume',
      allowZero: true,
    );
    final total = EstimateValidation.number(
      cementPart + sandPart,
      'Mortar ratio',
    );
    final cementBags =
        materials * cementPart / total * _cementDensity / _bagWeight;
    final sand = materials * sandPart / total;
    final cementCost = EstimateCostCalculator.lineCost(
      cementBags,
      cementRate,
      'Cement',
    );
    final sandCost = EstimateCostCalculator.lineCost(sand, sandRate, 'Sand');
    final materialCost = EstimateCostCalculator.total([cementCost, sandCost]);
    final standard =
        productivityStandard ?? PlasterProductivity.forThickness(thicknessMm);
    if (!standard.daysPerBaseQuantity.containsKey(LabourRole.mason) ||
        !standard.daysPerBaseQuantity.containsKey(LabourRole.helper) ||
        standard.maximumCrewPerRole > 3) {
      throw ArgumentError(
        'Plaster requires Mason and Helper crews of 1–3 each.',
      );
    }
    final productivity = ProductivityCalculator.calculate(
      quantity: takeoff.netArea,
      standard: standard,
      crew: crew,
    );
    final labour = LabourCalculator.calculate(
      productivity: productivity,
      dailyWages: dailyWages,
    );
    final totalCost = EstimateCostCalculator.total([
      materialCost,
      labour.totalCost,
    ]);
    return PlasterResult(
      takeoff: takeoff,
      thicknessMm: thicknessMm,
      cementPart: cementPart,
      sandPart: sandPart,
      wastagePercent: wastagePercent,
      wetVolume: wet,
      dryVolume: dry,
      cementBags: cementBags,
      sandM3: sand,
      sandBrass: sand / _brassM3,
      cementRate: cementRate,
      sandRate: sandRate,
      cementCost: cementCost,
      sandCost: sandCost,
      materialCost: materialCost,
      productivity: productivity,
      labour: labour,
      totalCost: totalCost,
      costPerSquareMetre: EstimateCostCalculator.perUnit(
        totalCost,
        takeoff.netArea,
      ),
    );
  }
}
