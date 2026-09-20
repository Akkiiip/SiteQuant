import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/opening_deduction.dart';
import 'package:site_quant/models/paint_result.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/services/opening_calculator.dart';
import 'package:site_quant/services/paint_calculator.dart';

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

void main() {
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
    expect(() => estimate(helpers: 4), throwsArgumentError);
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
