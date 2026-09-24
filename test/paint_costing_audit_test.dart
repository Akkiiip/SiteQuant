import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/paint_result.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/services/paint_calculator.dart';
import 'package:site_quant/services/paint_reference_defaults.dart';

PaintResult referenceEstimate(
  PaintWorkType type, {
  required double areaM2,
  int painters = 1,
  int helpers = 1,
}) {
  final preset = PaintReferenceDefaults.forWorkType(type);
  return PaintCalculator.calculate(
    workType: type,
    grossArea: areaM2,
    materials: [
      for (final entry in preset.materials.entries)
        PaintMaterialInput(
          kind: entry.key,
          coats: entry.value.coats,
          coverage: entry.value.coverage,
          coverageBasis: entry.value.coverageBasis,
          coverageCoats: entry.value.coverageCoats,
          wastagePercent: entry.value.wastagePercent,
          rate: entry.value.rate,
          puttyPackSizeKg: entry.value.puttyPackSizeKg,
          referenceLabel: entry.value.referenceLabel,
          referenceNote: entry.value.note,
        ),
    ],
    painterDaysPer10M2: preset.painterDaysPer10M2,
    helperDaysPer10M2: preset.helperDaysPer10M2,
    productivityName: preset.productivityName,
    productivityBasis: preset.labourNote,
    crew: {LabourRole.painter: painters, LabourRole.helper: helpers},
    dailyWages: const {LabourRole.painter: 900, LabourRole.helper: 750},
  );
}

void main() {
  group('research-backed Paint costing', () {
    test('3100 sq ft two-coat putty is traceable and bags round up', () {
      final area = MeasurementPreferences.toSquareMetres(
        3100,
        MeasurementSystem.imperial,
      );
      final result = referenceEstimate(PaintWorkType.puttyOnly, areaM2: area);
      final material = result.materials.single;
      final expectedBase = area * 2 / 2.02064;

      expect(material.baseQuantity, closeTo(expectedBase, 1e-8));
      expect(material.finalQuantity, closeTo(expectedBase * 1.05, 1e-8));
      expect(material.approximatePacks, 15);
      expect(material.cost, closeTo(material.finalQuantity * 35, 1e-8));
      expect(
        result.productivity.mandays[LabourRole.painter],
        closeTo(12.96, .01),
      );
      expect(
        result.productivity.mandays[LabourRole.helper],
        closeTo(12.96, .01),
      );
      expect(result.productivity.workingDays, closeTo(12.96, .01));
      expect(result.labour.totalCost, closeTo(21384, 1));
      expect(
        result.totalCost,
        closeTo(result.materialCost + result.labour.totalCost, 1e-8),
      );
      expect(result.costPerSquareFoot, closeTo(result.totalCost / 3100, 1e-8));
    });

    test('2780 sq ft putty benchmark has no generic labour inflation', () {
      final area = MeasurementPreferences.toSquareMetres(
        2780,
        MeasurementSystem.imperial,
      );
      final result = referenceEstimate(PaintWorkType.puttyOnly, areaM2: area);
      expect(result.materials.single.approximatePacks, 14);
      expect(
        result.productivity.mandays[LabourRole.painter],
        closeTo(11.62, .01),
      );
      expect(
        result.productivity.mandays[LabourRole.helper],
        closeTo(11.62, .01),
      );
      expect(result.labour.totalCost, closeTo(19176.58, .01));
      expect(result.totalCost, inInclusiveRange(28000, 29500));
    });

    test('primer 100 m² uses one-coat coverage and scoped labour', () {
      final result = referenceEstimate(PaintWorkType.primerOnly, areaM2: 100);
      final material = result.materials.single;
      expect(material.baseQuantity, closeTo(100 / 15.75, 1e-10));
      expect(material.finalQuantity, closeTo(100 / 15.75 * 1.05, 1e-10));
      expect(result.productivity.mandays[LabourRole.painter], 4);
      expect(result.productivity.mandays[LabourRole.helper], 2);
    });

    test('interior emulsion complete-operation coverage is not doubled', () {
      final result = referenceEstimate(PaintWorkType.paintOnly, areaM2: 100);
      final material = result.materials.single;
      expect(material.input.coats, 2);
      expect(
        material.input.effectiveCoverageBasis,
        PaintCoverageBasis.completeOperation,
      );
      expect(material.baseQuantity, closeTo(100 / 13.94, 1e-10));
      expect(material.finalQuantity, closeTo(100 / 13.94 * 1.05, 1e-10));
      expect(result.productivity.mandays[LabourRole.painter], 5.4);
      expect(result.productivity.mandays[LabourRole.helper], 5.4);
    });

    test('exterior emulsion remains separate from interior assumptions', () {
      final result = referenceEstimate(
        PaintWorkType.exteriorWalls,
        areaM2: 100,
      );
      final paint = result.materials.singleWhere(
        (entry) => entry.input.kind == PaintMaterialKind.paint,
      );
      expect(
        paint.input.effectiveCoverageBasis,
        PaintCoverageBasis.completeOperation,
      );
      expect(paint.baseQuantity, closeTo(100 / 6.35, 1e-10));
      expect(paint.finalQuantity, closeTo(100 / 6.35 * 1.07, 1e-10));
      expect(result.productivity.mandays[LabourRole.painter], 6);
      expect(result.productivity.mandays[LabourRole.helper], 3);
    });

    test('crew changes duration only, never mandays or labour cost', () {
      final estimates = [
        referenceEstimate(PaintWorkType.puttyOnly, areaM2: 100),
        referenceEstimate(
          PaintWorkType.puttyOnly,
          areaM2: 100,
          painters: 2,
          helpers: 2,
        ),
        referenceEstimate(
          PaintWorkType.puttyOnly,
          areaM2: 100,
          painters: 5,
          helpers: 5,
        ),
      ];
      expect(
        estimates[1].productivity.mandays,
        estimates[0].productivity.mandays,
      );
      expect(
        estimates[2].productivity.mandays,
        estimates[0].productivity.mandays,
      );
      expect(estimates[1].labour.totalCost, estimates[0].labour.totalCost);
      expect(estimates[2].labour.totalCost, estimates[0].labour.totalCost);
      expect(estimates[0].productivity.workingDays, 4.5);
      expect(estimates[1].productivity.workingDays, 2.25);
      expect(estimates[2].productivity.workingDays, closeTo(.9, 1e-10));
    });

    test('per-coat coverage scales with coats and wastage is applied once', () {
      PaintResult calculate(int coats) => PaintCalculator.calculate(
        workType: PaintWorkType.primerOnly,
        grossArea: 100,
        materials: [
          PaintMaterialInput(
            kind: PaintMaterialKind.primer,
            coats: coats,
            coverage: 10,
            coverageBasis: PaintCoverageBasis.perCoat,
            wastagePercent: 10,
            rate: 200,
          ),
        ],
        painterDaysPer10M2: .4,
        helperDaysPer10M2: .2,
        crew: const {LabourRole.painter: 1, LabourRole.helper: 1},
        dailyWages: const {LabourRole.painter: 900, LabourRole.helper: 750},
      );
      final one = calculate(1).materials.single;
      final two = calculate(2).materials.single;
      expect(one.baseQuantity, 10);
      expect(one.finalQuantity, 11);
      expect(two.baseQuantity, 20);
      expect(two.finalQuantity, 22);
      expect(two.cost, 4400);
    });
  });
}
