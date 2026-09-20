import '../models/opening_deduction.dart';
import '../models/productivity_standard.dart';
import '../models/tile_result.dart';
import 'estimate_cost_calculator.dart';
import 'estimate_validation.dart';
import 'labour_calculator.dart';
import 'opening_calculator.dart';
import 'productivity_calculator.dart';

class TileCalculator {
  TileCalculator._();

  static TileResult calculate({
    required TileWorkType workType,
    required double grossArea,
    List<OpeningDeduction> openings = const [],
    required double tileLengthMm,
    required double tileWidthMm,
    required double tileWastagePercent,
    required double tileRatePerSquareMetre,
    required bool includeAdhesive,
    required double adhesiveConsumptionKgPerSquareMetre,
    required double adhesiveWastagePercent,
    required double adhesiveRatePerKg,
    required bool includeGrout,
    required double groutConsumptionKgPerSquareMetre,
    required double groutWastagePercent,
    required double groutRatePerKg,
    required bool includeBedding,
    required double beddingThicknessMm,
    required double cementRatePerBag,
    required double sandRatePerCubicMetre,
    required double tileMasonDaysPer10M2,
    required double helperDaysPer10M2,
    required Map<LabourRole, int> crew,
    required Map<LabourRole, double> dailyWages,
    required String referenceNote,
  }) {
    final takeoff = OpeningCalculator.calculate(
      grossArea: grossArea,
      openings: openings,
    );
    EstimateValidation.number(tileLengthMm, 'Tile length');
    EstimateValidation.number(tileWidthMm, 'Tile width');
    EstimateValidation.number(
      tileWastagePercent,
      'Tile wastage',
      allowZero: true,
    );
    final tileArea = tileLengthMm / 1000 * tileWidthMm / 1000;
    EstimateValidation.number(tileArea, 'Tile area');
    final baseTiles = takeoff.netArea / tileArea;
    final tileCount = (baseTiles * (1 + tileWastagePercent / 100)).ceil();
    final tileCoverage = tileCount * tileArea;

    final materials = <TileMaterialEstimate>[
      _material(
        name: 'Tiles',
        quantity: tileCoverage,
        unit: 'm2',
        rate: tileRatePerSquareMetre,
      ),
    ];
    if (includeAdhesive) {
      materials.add(
        _consumptionMaterial(
          name: 'Tile Adhesive',
          netArea: takeoff.netArea,
          consumption: adhesiveConsumptionKgPerSquareMetre,
          wastagePercent: adhesiveWastagePercent,
          rate: adhesiveRatePerKg,
        ),
      );
    }
    if (includeGrout) {
      materials.add(
        _consumptionMaterial(
          name: 'Grout',
          netArea: takeoff.netArea,
          consumption: groutConsumptionKgPerSquareMetre,
          wastagePercent: groutWastagePercent,
          rate: groutRatePerKg,
        ),
      );
    }
    if (includeBedding) {
      materials.addAll(
        _beddingMaterials(
          netArea: takeoff.netArea,
          thicknessMm: beddingThicknessMm,
          cementRatePerBag: cementRatePerBag,
          sandRatePerCubicMetre: sandRatePerCubicMetre,
        ),
      );
    }
    final materialCost = EstimateCostCalculator.total(
      materials.map((material) => material.cost),
    );
    final productivity = ProductivityCalculator.calculate(
      quantity: takeoff.netArea,
      standard: ProductivityStandard(
        name: 'Reference tile laying productivity',
        basis:
            'Reference productivity estimate. Adjust for tile size, pattern, access, substrate and site conditions.',
        daysPerBaseQuantity: {
          LabourRole.tileMason: tileMasonDaysPer10M2,
          LabourRole.helper: helperDaysPer10M2,
        },
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
    return TileResult(
      workType: workType,
      takeoff: takeoff,
      tileLengthMm: tileLengthMm,
      tileWidthMm: tileWidthMm,
      tileAreaSquareMetres: tileArea,
      baseTileQuantity: baseTiles,
      tileQuantity: tileCount,
      tileCoverageSquareMetres: tileCoverage,
      tileWastagePercent: tileWastagePercent,
      materials: List.unmodifiable(materials),
      materialCost: materialCost,
      productivity: productivity,
      labour: labour,
      totalCost: total,
      costPerSquareMetre: EstimateCostCalculator.perUnit(
        total,
        takeoff.netArea,
      ),
      referenceNote: referenceNote,
    );
  }

  static TileMaterialEstimate _consumptionMaterial({
    required String name,
    required double netArea,
    required double consumption,
    required double wastagePercent,
    required double rate,
  }) {
    EstimateValidation.number(consumption, '$name consumption');
    EstimateValidation.number(wastagePercent, '$name wastage', allowZero: true);
    final quantity = netArea * consumption * (1 + wastagePercent / 100);
    return _material(name: name, quantity: quantity, unit: 'kg', rate: rate);
  }

  static List<TileMaterialEstimate> _beddingMaterials({
    required double netArea,
    required double thicknessMm,
    required double cementRatePerBag,
    required double sandRatePerCubicMetre,
  }) {
    EstimateValidation.number(thicknessMm, 'Bedding thickness');
    final dryVolume = netArea * thicknessMm / 1000 * 1.33;
    const cementPart = 1.0;
    const sandPart = 4.0;
    final cementVolume = dryVolume * cementPart / (cementPart + sandPart);
    final sandVolume = dryVolume * sandPart / (cementPart + sandPart);
    final cementBags = cementVolume * 1440 / 50;
    return [
      _material(
        name: 'Cement',
        quantity: cementBags,
        unit: 'bags',
        rate: cementRatePerBag,
      ),
      _material(
        name: 'Sand',
        quantity: sandVolume,
        unit: 'm3',
        rate: sandRatePerCubicMetre,
      ),
    ];
  }

  static TileMaterialEstimate _material({
    required String name,
    required double quantity,
    required String unit,
    required double rate,
  }) {
    EstimateValidation.number(quantity, '$name quantity', allowZero: true);
    return TileMaterialEstimate(
      name: name,
      quantity: quantity,
      unit: unit,
      rate: rate,
      cost: EstimateCostCalculator.lineCost(quantity, rate, name),
    );
  }
}
