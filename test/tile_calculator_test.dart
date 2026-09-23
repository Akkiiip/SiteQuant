import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/opening_deduction.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/services/tile_calculator.dart';
import 'package:site_quant/services/tile_reference_defaults.dart';

void main() {
  TileResult estimate({
    TileWorkType type = TileWorkType.floorTiles,
    List<OpeningDeduction> openings = const [],
    bool bedding = false,
    int masons = 1,
    int helpers = 1,
  }) => TileCalculator.calculate(
    workType: type,
    grossArea: 100,
    openings: openings,
    tileLengthMm: 600,
    tileWidthMm: 600,
    tileWastagePercent: 10,
    tileRatePerSquareMetre: 1000,
    includeAdhesive: true,
    adhesiveConsumptionKgPerSquareMetre: 4,
    adhesiveWastagePercent: 5,
    adhesiveRatePerKg: 20,
    includeGrout: true,
    groutConsumptionKgPerSquareMetre: .25,
    groutWastagePercent: 5,
    groutRatePerKg: 100,
    includeBedding: bedding,
    beddingThicknessMm: 20,
    cementRatePerBag: 450,
    sandRatePerCubicMetre: 1800,
    tileMasonDaysPer10M2: 1.25,
    helperDaysPer10M2: .9,
    crew: {LabourRole.tileMason: masons, LabourRole.helper: helpers},
    dailyWages: {LabourRole.tileMason: 1000, LabourRole.helper: 650},
    referenceNote: 'Test reference.',
  );

  test('floor tiles calculate area, rounded tile quantity and tile cost', () {
    final r = estimate();
    expect(r.netArea, 100);
    expect(r.tileAreaSquareMetres, .36);
    expect(r.baseTileQuantity, closeTo(277.777, .001));
    expect(r.tileQuantity, 306);
    expect(r.tileCoverageSquareMetres, closeTo(110.16, .001));
    expect(r.materials.first.cost, closeTo(110160, .001));
  });

  test('opening deductions are used once for all materials and labour', () {
    final r = estimate(
      openings: [
        const OpeningDeduction(
          name: 'Door',
          widthMetres: 1,
          heightMetres: 2,
          quantity: 2,
        ),
      ],
    );
    expect(r.deductionArea, 4);
    expect(r.netArea, 96);
    expect(r.materials[1].quantity, closeTo(403.2, .001));
    expect(r.productivity.mandays[LabourRole.tileMason], closeTo(12, .001));
  });

  test('wall and skirting estimates use supplied gross areas', () {
    expect(
      estimate(type: TileWorkType.wallTiles).workType,
      TileWorkType.wallTiles,
    );
    expect(estimate(type: TileWorkType.skirting).netArea, 100);
  });

  test('adhesive and grout include reference wastage and rates', () {
    final r = estimate();
    expect(r.materials[1].quantity, 420);
    expect(r.materials[1].cost, 8400);
    expect(r.materials[2].quantity, closeTo(26.25, .001));
    expect(r.materials[2].cost, 2625);
  });

  test('optional cement-sand bedding produces cement and sand costs', () {
    final r = estimate(bedding: true);
    expect(r.materials.map((m) => m.name), containsAll(['Cement', 'Sand']));
    expect(
      r.materials.firstWhere((m) => m.name == 'Cement').quantity,
      closeTo(15.3216, .001),
    );
    expect(
      r.materials.firstWhere((m) => m.name == 'Sand').quantity,
      closeTo(2.128, .001),
    );
  });

  test(
    'crew duration uses the controlling role and reduces for a larger crew',
    () {
      final one = estimate();
      final two = estimate(masons: 2, helpers: 2);
      expect(one.productivity.workingDays, closeTo(12.5, .001));
      expect(two.productivity.workingDays, closeTo(6.25, .001));
    },
  );

  test('labour, total cost and cost per m2 are calculated', () {
    final r = estimate();
    expect(r.labour.totalCost, closeTo(18350, .001));
    expect(r.totalCost, closeTo(r.materialCost + r.labour.totalCost, .001));
    expect(r.costPerSquareMetre, closeTo(r.totalCost / 100, .001));
  });

  test(
    'reference defaults supply usable assumptions without custom inputs',
    () {
      final p = TileReferenceDefaults.forWorkType(TileWorkType.floorTiles);
      expect(p.tileWastagePercent, greaterThanOrEqualTo(0));
      expect(p.adhesiveConsumptionKgPerSquareMetre, greaterThan(0));
      expect(p.tileMasonDaysPer10M2, greaterThan(0));
    },
  );

  test('invalid dimensions, deductions and crew are rejected', () {
    expect(
      () => TileCalculator.calculate(
        workType: TileWorkType.floorTiles,
        grossArea: 1,
        tileLengthMm: 0,
        tileWidthMm: 600,
        tileWastagePercent: 0,
        tileRatePerSquareMetre: 1,
        includeAdhesive: false,
        adhesiveConsumptionKgPerSquareMetre: 1,
        adhesiveWastagePercent: 0,
        adhesiveRatePerKg: 1,
        includeGrout: false,
        groutConsumptionKgPerSquareMetre: 1,
        groutWastagePercent: 0,
        groutRatePerKg: 1,
        includeBedding: false,
        beddingThicknessMm: 1,
        cementRatePerBag: 1,
        sandRatePerCubicMetre: 1,
        tileMasonDaysPer10M2: 1,
        helperDaysPer10M2: 1,
        crew: {LabourRole.tileMason: 0, LabourRole.helper: 1},
        dailyWages: {LabourRole.tileMason: 1, LabourRole.helper: 1},
        referenceNote: 'x',
      ),
      throwsArgumentError,
    );
  });
}
