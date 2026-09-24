import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/opening_deduction.dart';
import 'package:site_quant/models/paint_result.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/services/opening_calculator.dart';
import 'package:site_quant/services/paint_calculator.dart';
import 'package:site_quant/services/paint_reference_defaults.dart';

const door = OpeningDeduction(
  name: 'Door',
  widthMetres: 1,
  heightMetres: 2.1,
  quantity: 1,
);
const windows = OpeningDeduction(
  name: 'Window',
  widthMetres: 1.2,
  heightMetres: 1.2,
  quantity: 4,
);

PaintMaterialInput material(
  PaintMaterialKind kind, {
  int coats = 1,
  double coverage = 10,
  double wastage = 5,
  double rate = 100,
}) => PaintMaterialInput(
  kind: kind,
  coats: coats,
  coverage: coverage,
  wastagePercent: wastage,
  rate: rate,
);

PaintResult estimate({
  PaintWorkType type = PaintWorkType.interiorWalls,
  double area = 100,
  List<OpeningDeduction> openings = const [],
  List<PaintMaterialInput>? materials,
  int painters = 1,
  int helpers = 1,
  double painterCoefficient = 1,
  double helperCoefficient = .5,
  double painterWage = 900,
  double helperWage = 600,
}) => PaintCalculator.calculate(
  workType: type,
  grossArea: area,
  openings: openings,
  materials:
      materials ??
      [
        material(PaintMaterialKind.putty, coats: 2, coverage: 2, rate: 40),
        material(PaintMaterialKind.primer, coverage: 10, rate: 200),
        material(PaintMaterialKind.paint, coats: 2, coverage: 10, rate: 300),
      ],
  painterDaysPer10M2: painterCoefficient,
  helperDaysPer10M2: helperCoefficient,
  crew: {LabourRole.painter: painters, LabourRole.helper: helpers},
  dailyWages: {LabourRole.painter: painterWage, LabourRole.helper: helperWage},
);

PaintResult referenceEstimate(
  PaintWorkType type, {
  int painters = 1,
  int helpers = 1,
}) {
  final preset = PaintReferenceDefaults.forWorkType(type);
  return PaintCalculator.calculate(
    workType: type,
    grossArea: 100,
    materials: [
      for (final entry in preset.materials.entries)
        PaintMaterialInput(
          kind: entry.key,
          coats: entry.value.coats,
          coverage: entry.value.coverage,
          wastagePercent: entry.value.wastagePercent,
          rate: entry.value.rate,
          coverageBasis: entry.value.coverageBasis,
          coverageCoats: entry.value.coverageCoats,
          puttyCoverageBasis: entry.value.puttyCoverageBasis,
          puttyPackSizeKg: entry.value.puttyPackSizeKg,
        ),
    ],
    painterDaysPer10M2: preset.painterDaysPer10M2,
    helperDaysPer10M2: preset.helperDaysPer10M2,
    crew: {LabourRole.painter: painters, LabourRole.helper: helpers},
    dailyWages: {LabourRole.painter: 900, LabourRole.helper: 600},
  );
}

void main() {
  test('60 brass is 6000 sq ft or 557.41824 m²', () {
    const squareFeet = 60 * 100.0;
    final squareMetres = MeasurementPreferences.toSquareMetres(
      squareFeet,
      MeasurementSystem.imperial,
    );
    expect(squareFeet, 6000);
    expect(squareMetres, closeTo(557.41824, 1e-5));
  });

  test('two-coat putty reference is not multiplied by two again', () {
    final reference = PaintReferenceDefaults.forWorkType(
      PaintWorkType.puttyOnly,
    ).materials[PaintMaterialKind.putty]!;
    expect(reference.coverageBasis, PaintCoverageBasis.perCoat);
    expect(reference.coverageDescription, contains('kg/coat'));
    final area = MeasurementPreferences.toSquareMetres(
      6000,
      MeasurementSystem.imperial,
    );
    final result = estimate(
      type: PaintWorkType.puttyOnly,
      area: area,
      materials: [
        PaintMaterialInput(
          kind: PaintMaterialKind.putty,
          coats: reference.coats,
          coverage: reference.coverage,
          wastagePercent: reference.wastagePercent,
          rate: reference.rate,
          puttyCoverageBasis: reference.puttyCoverageBasis,
          puttyPackSizeKg: reference.puttyPackSizeKg,
        ),
      ],
    );
    final putty = result.materials.single;
    final expectedBase = area * reference.coats / reference.coverage;
    expect(putty.baseQuantity, closeTo(expectedBase, 1e-8));
    expect(putty.finalQuantity, closeTo(expectedBase * 1.05, 1e-8));
    expect(putty.approximatePacks, 29);
  });

  test('putty 20, 30 and 40 kg packs round up without changing kg', () {
    final area = MeasurementPreferences.toSquareMetres(
      6000,
      MeasurementSystem.imperial,
    );
    double? requiredKg;
    for (final (packSize, expectedPacks) in [
      (20.0, 26),
      (30.0, 17),
      (40.0, 13),
    ]) {
      final putty = estimate(
        type: PaintWorkType.puttyOnly,
        area: area,
        materials: [
          PaintMaterialInput(
            kind: PaintMaterialKind.putty,
            coats: 2,
            coverage: 1.16,
            wastagePercent: 5,
            rate: 35,
            puttyCoverageBasis: PuttyCoverageBasis.completeTwoCoats,
            puttyPackSizeKg: packSize,
          ),
        ],
      ).materials.single;
      expect(putty.approximatePacks, expectedPacks);
      requiredKg ??= putty.finalQuantity;
      expect(putty.finalQuantity, requiredKg);
    }
  });

  test('custom per-coat putty coverage retains per-coat calculation', () {
    final putty = estimate(
      type: PaintWorkType.puttyOnly,
      area: 100,
      materials: [material(PaintMaterialKind.putty, coats: 2, coverage: 2)],
    ).materials.single;
    expect(putty.baseQuantity, 100);
  });

  test('100 m² two-coat acrylic reference uses 0.54/0.54 days per 10 m²', () {
    final one = referenceEstimate(PaintWorkType.paintOnly);
    final two = referenceEstimate(
      PaintWorkType.paintOnly,
      painters: 2,
      helpers: 2,
    );
    expect(one.productivity.mandays[LabourRole.painter], closeTo(5.4, 1e-10));
    expect(one.productivity.mandays[LabourRole.helper], closeTo(5.4, 1e-10));
    expect(one.productivity.workingDays, closeTo(5.4, 1e-10));
    expect(two.productivity.mandays, one.productivity.mandays);
    expect(two.productivity.workingDays, closeTo(2.7, 1e-10));
  });

  test(
    '100 m² one-coat wall primer reference uses 0.40/0.20 days per 10 m²',
    () {
      final one = referenceEstimate(PaintWorkType.primerOnly);
      final two = referenceEstimate(
        PaintWorkType.primerOnly,
        painters: 2,
        helpers: 2,
      );
      expect(one.productivity.mandays[LabourRole.painter], closeTo(4.0, 1e-10));
      expect(one.productivity.mandays[LabourRole.helper], closeTo(2.0, 1e-10));
      expect(one.productivity.workingDays, closeTo(4.0, 1e-10));
      expect(two.productivity.mandays, one.productivity.mandays);
      expect(two.productivity.workingDays, closeTo(2.0, 1e-10));
    },
  );

  test('every Paint work type has a scoped, editable labour reference', () {
    for (final type in PaintWorkType.values) {
      final preset = PaintReferenceDefaults.forWorkType(type);
      expect(preset.painterDaysPer10M2, greaterThan(0));
      expect(preset.helperDaysPer10M2, greaterThan(0));
      expect(preset.labourNote, isNotEmpty);
      expect(preset.productivityName, isNotEmpty);
    }
  });
  test(
    'gross, one opening, multiple openings and net area are calculated once',
    () {
      expect(
        OpeningCalculator.grossArea(lengthMetres: 10, heightMetres: 10),
        100,
      );
      expect(estimate(openings: [door]).netArea, 97.9);
      final result = estimate(openings: [door, windows]);
      expect(result.deductionArea, closeTo(7.86, 1e-10));
      expect(result.netArea, closeTo(92.14, 1e-10));
    },
  );

  test(
    'putty, primer and paint quantities use coats, coverage and wastage',
    () {
      final result = estimate();
      final putty = result.materials[0];
      final primer = result.materials[1];
      final paint = result.materials[2];
      expect(putty.baseQuantity, closeTo(100, 1e-10));
      expect(putty.wastageQuantity, closeTo(5, 1e-10));
      expect(putty.finalQuantity, closeTo(105, 1e-10));
      expect(primer.baseQuantity, closeTo(10, 1e-10));
      expect(primer.finalQuantity, closeTo(10.5, 1e-10));
      expect(paint.baseQuantity, closeTo(20, 1e-10));
      expect(paint.finalQuantity, closeTo(21, 1e-10));
    },
  );

  test('texture uses explicit kg per square metre consumption', () {
    final result = estimate(
      type: PaintWorkType.texture,
      materials: [
        material(
          PaintMaterialKind.texture,
          coats: 2,
          coverage: 1.5,
          wastage: 10,
          rate: 80,
        ),
      ],
    );
    final texture = result.materials.single;
    expect(texture.baseQuantity, 300);
    expect(texture.finalQuantity, 330);
    expect(texture.cost, 26400);
  });

  test('work types select only their applicable materials', () {
    expect(PaintWorkType.puttyOnly.materials, [PaintMaterialKind.putty]);
    expect(PaintWorkType.primerOnly.materials, [PaintMaterialKind.primer]);
    expect(PaintWorkType.paintOnly.materials, [PaintMaterialKind.paint]);
    expect(PaintWorkType.wood.materials, [PaintMaterialKind.coating]);
    expect(PaintWorkType.metal.materials, [PaintMaterialKind.coating]);
    expect(PaintWorkType.exteriorWalls.materials, [
      PaintMaterialKind.primer,
      PaintMaterialKind.paint,
    ]);
  });

  test(
    'material rates, cost, labour, total and cost per m² are transparent',
    () {
      final result = estimate();
      expect(result.materials[0].cost, 4200);
      expect(result.materials[1].cost, 2100);
      expect(result.materials[2].cost, 6300);
      expect(result.materialCost, 12600);
      expect(result.productivity.mandays[LabourRole.painter], 10);
      expect(result.productivity.mandays[LabourRole.helper], 5);
      expect(result.productivity.workingDays, 10);
      expect(result.labour.costs[LabourRole.painter], 9000);
      expect(result.labour.costs[LabourRole.helper], 3000);
      expect(result.labour.totalCost, 12000);
      expect(result.totalCost, 24600);
      expect(result.costPerSquareMetre, 246);
    },
  );

  test('crew duration uses the controlling labour role and scales by crew', () {
    expect(estimate(painters: 1, helpers: 2).productivity.workingDays, 10);
    expect(estimate(painters: 2, helpers: 1).productivity.workingDays, 5);
    expect(estimate(painters: 2, helpers: 2).productivity.workingDays, 5);
    expect(
      estimate(painters: 3, helpers: 3).productivity.workingDays,
      closeTo(10 / 3, 1e-10),
    );
  });

  test('metric and imperial area helpers use a consistent base area', () {
    const squareFeet = 100.0;
    final m2 = MeasurementPreferences.toSquareMetres(
      squareFeet,
      MeasurementSystem.imperial,
    );
    expect(
      MeasurementPreferences.fromSquareMetres(m2, MeasurementSystem.imperial),
      closeTo(squareFeet, 1e-10),
    );
    expect(estimate(area: m2).netArea, closeTo(m2, 1e-10));
  });

  test('invalid inputs, excessive deductions and invalid crew fail safely', () {
    expect(() => estimate(area: 0), throwsArgumentError);
    expect(() => estimate(openings: [door], area: 1), throwsArgumentError);
    expect(
      () =>
          estimate(materials: [material(PaintMaterialKind.putty, coverage: 0)]),
      throwsArgumentError,
    );
    expect(
      () => estimate(
        materials: [
          material(PaintMaterialKind.putty, coats: 0),
          material(PaintMaterialKind.primer),
          material(PaintMaterialKind.paint),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => estimate(
        materials: [
          material(PaintMaterialKind.putty, rate: -1),
          material(PaintMaterialKind.primer),
          material(PaintMaterialKind.paint),
        ],
      ),
      throwsArgumentError,
    );
    expect(() => estimate(painterCoefficient: 0), throwsArgumentError);
    expect(() => estimate(helperCoefficient: -1), throwsArgumentError);
    expect(() => estimate(painters: 0), throwsArgumentError);
    expect(() => estimate(helpers: 6), throwsArgumentError);
    expect(
      () => estimate(
        materials: [
          material(PaintMaterialKind.putty),
          material(PaintMaterialKind.primer),
        ],
      ),
      throwsArgumentError,
    );
  });

  test(
    'fully deducted area returns zero materials, labour and no unit cost',
    () {
      final result = estimate(area: 2.1, openings: [door]);
      expect(result.netArea, 0);
      expect(result.materialCost, 0);
      expect(result.labour.totalCost, 0);
      expect(result.totalCost, 0);
      expect(result.costPerSquareMetre, isNull);
    },
  );
}
