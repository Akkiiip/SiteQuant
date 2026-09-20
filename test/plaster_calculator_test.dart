import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/opening_deduction.dart';
import 'package:site_quant/models/plaster_result.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/services/estimate_format.dart';
import 'package:site_quant/services/opening_calculator.dart';
import 'package:site_quant/services/plaster_calculator.dart';
import 'package:site_quant/services/plaster_productivity.dart';
import 'package:site_quant/services/productivity_calculator.dart';

PlasterResult estimate({
  double area = 100,
  double thickness = 20,
  double cementPart = 1,
  double sandPart = 4,
  double wastage = 5,
  List<OpeningDeduction> openings = const [],
  double cementRate = 400,
  double sandRate = 1500,
  int masons = 1,
  int helpers = 1,
  double masonWage = 900,
  double helperWage = 700,
  ProductivityStandard? standard,
}) => PlasterCalculator.calculate(
  area: area,
  thicknessMm: thickness,
  cementPart: cementPart,
  sandPart: sandPart,
  wastagePercent: wastage,
  openings: openings,
  cementRate: cementRate,
  sandRate: sandRate,
  crew: {LabourRole.mason: masons, LabourRole.helper: helpers},
  dailyWages: {LabourRole.mason: masonWage, LabourRole.helper: helperWage},
  productivityStandard: standard,
);

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

void main() {
  for (final thickness in [12.0, 15.0, 20.0]) {
    test('$thickness mm is preserved through service and display', () {
      final result = estimate(thickness: thickness);
      expect(result.thicknessMm, thickness);
      expect(
        EstimateFormat.number(result.thicknessMm, 0),
        thickness.toInt().toString(),
      );
      expect(result.wetVolume, closeTo(100 * thickness / 1000, 1e-10));
    });
  }
  test(
    'formatter retains significant integer zeroes and fractional thickness',
    () {
      expect(EstimateFormat.number(20, 0), '20');
      expect(EstimateFormat.number(100, 0), '100');
      expect(EstimateFormat.number(0, 0), '0');
      expect(EstimateFormat.number(12.5), '12.5');
      expect(EstimateFormat.number(20, 2), '20');
    },
  );
  test('gross area includes all surfaces', () {
    expect(
      OpeningCalculator.grossArea(
        lengthMetres: 5,
        heightMetres: 3,
        surfaces: 2,
      ),
      30,
    );
  });
  test('single door deduction', () {
    final result = estimate(openings: [door]);
    expect(result.deductionArea, 2.1);
    expect(result.area, 97.9);
  });
  test('multiple windows use quantity once', () {
    final result = estimate(openings: [windows]);
    expect(result.deductionArea, closeTo(5.76, 1e-10));
    expect(result.area, closeTo(94.24, 1e-10));
  });
  test('multiple types including custom opening and immutable snapshot', () {
    final openings = [
      door,
      windows,
      const OpeningDeduction(
        name: 'Vent',
        widthMetres: .5,
        heightMetres: .4,
        quantity: 2,
      ),
    ];
    final result = estimate(openings: openings);
    openings.clear();
    expect(result.takeoff.openings.length, 3);
    expect(result.deductionArea, closeTo(8.26, 1e-10));
    expect(result.area, closeTo(91.74, 1e-10));
  });
  test(
    'net area drives original material formula, without double deduction',
    () {
      final result = estimate(area: 107.86, openings: [door, windows]);
      expect(result.grossArea, 107.86);
      expect(result.area, closeTo(100, 1e-10));
      expect(result.wetVolume, closeTo(2, 1e-10));
      expect(result.dryVolume, closeTo(2.66, 1e-10));
      expect(result.cementBags, closeTo(16.08768, 1e-8));
      expect(result.sandM3, closeTo(2.2344, 1e-8));
      expect(result.sandBrass, closeTo(2.2344 / 2.8316846592, 1e-10));
    },
  );
  test('original zero wastage and mortar split are retained', () {
    final result = estimate(wastage: 0, sandPart: 3);
    expect(result.cementBags, closeTo(2.66 / 4 * 1440 / 50, 1e-10));
    expect(result.sandM3, closeTo(2.66 * 3 / 4, 1e-10));
  });
  test('editable rates produce cement, sand and material costs', () {
    final result = estimate();
    expect(result.cementCost, closeTo(6435.072, 1e-8));
    expect(result.sandCost, closeTo(3351.6, 1e-8));
    expect(result.materialCost, closeTo(9786.672, 1e-8));
    expect(estimate(cementRate: 500).cementCost, closeTo(8043.84, 1e-8));
    expect(estimate(sandRate: 2000).sandCost, closeTo(4468.8, 1e-8));
  });
  test(
    '20 mm labour example, including deductions, matches requested values',
    () {
      final result = estimate(area: 107.86, openings: [door, windows]);
      expect(
        result.productivity.mandays[LabourRole.mason],
        closeTo(9.4, 1e-10),
      );
      expect(
        result.productivity.mandays[LabourRole.helper],
        closeTo(10.2, 1e-10),
      );
      expect(result.labour.costs[LabourRole.mason], closeTo(8460, 1e-8));
      expect(result.labour.costs[LabourRole.helper], closeTo(7140, 1e-8));
      expect(result.labour.totalCost, closeTo(15600, 1e-8));
      expect(result.productivity.workingDays, closeTo(10.2, 1e-10));
      expect(result.productivity.crewOutputPerDay, closeTo(10 / 1.02, 1e-10));
    },
  );
  test('12 mm coefficients match reference', () {
    final result = estimate(thickness: 12);
    expect(result.productivity.mandays[LabourRole.mason], closeTo(6.7, 1e-10));
    expect(result.productivity.mandays[LabourRole.helper], closeTo(7.5, 1e-10));
    expect(result.productivity.workingDays, closeTo(7.5, 1e-10));
  });
  test('15 mm is explicitly interpolated rather than labelled a CPWD item', () {
    final standard = PlasterProductivity.forThickness(15);
    expect(standard.name, contains('Interpolated'));
    expect(
      standard.daysPerBaseQuantity[LabourRole.mason],
      closeTo(.77125, 1e-10),
    );
    expect(
      standard.daysPerBaseQuantity[LabourRole.helper],
      closeTo(.85125, 1e-10),
    );
  });
  for (final count in [1, 2, 3]) {
    test(
      '$count-person-per-role crew uses controlling role, not summed mandays',
      () {
        final result = estimate(masons: count, helpers: count);
        expect(result.productivity.workingDays, closeTo(10.2 / count, 1e-10));
        expect(result.labour.totalCost, closeTo(15600, 1e-8));
      },
    );
  }
  test('unequal crew can make mason the controlling role', () {
    expect(
      estimate(masons: 1, helpers: 2).productivity.workingDays,
      closeTo(9.4, 1e-10),
    );
    expect(
      estimate(masons: 2, helpers: 1).productivity.workingDays,
      closeTo(10.2, 1e-10),
    );
  });
  test('total project cost and cost per net square metre', () {
    final result = estimate(area: 107.86, openings: [door, windows]);
    expect(result.totalCost, closeTo(25386.672, 1e-8));
    expect(result.costPerSquareMetre, closeTo(253.86672, 1e-8));
  });
  test('fully deducted area is zero without division by zero', () {
    final result = estimate(area: 2.1, openings: [door]);
    expect(result.area, 0);
    expect(result.wetVolume, 0);
    expect(result.cementBags, 0);
    expect(result.materialCost, 0);
    expect(result.labour.totalCost, 0);
    expect(result.totalCost, 0);
    expect(result.productivity.workingDays, 0);
    expect(result.costPerSquareMetre, isNull);
  });
  test('custom thickness uses an explicit site-specific standard', () {
    final result = estimate(
      thickness: 25,
      standard: PlasterProductivity.siteSpecific(
        masonDaysPer10M2: 1.2,
        helperDaysPer10M2: 1.4,
      ),
    );
    expect(result.wetVolume, 2.5);
    expect(result.productivity.workingDays, closeTo(14, 1e-10));
    expect(() => estimate(thickness: 25), throwsArgumentError);
  });
  for (final invalid in [0.0, -1.0, double.nan, double.infinity]) {
    test('rejects invalid numeric inputs: $invalid', () {
      expect(() => estimate(area: invalid), throwsArgumentError);
      expect(() => estimate(thickness: invalid), throwsArgumentError);
      expect(() => estimate(cementRate: invalid), throwsArgumentError);
      expect(() => estimate(sandRate: invalid), throwsArgumentError);
      expect(() => estimate(masonWage: invalid), throwsArgumentError);
      expect(() => estimate(helperWage: invalid), throwsArgumentError);
      expect(() => estimate(cementPart: invalid), throwsArgumentError);
      expect(() => estimate(sandPart: invalid), throwsArgumentError);
      expect(
        () =>
            OpeningCalculator.grossArea(lengthMetres: invalid, heightMetres: 3),
        throwsArgumentError,
      );
      expect(
        () =>
            OpeningCalculator.grossArea(lengthMetres: 3, heightMetres: invalid),
        throwsArgumentError,
      );
      expect(
        () => estimate(
          openings: [
            OpeningDeduction(
              name: 'Door',
              widthMetres: invalid,
              heightMetres: 2,
              quantity: 1,
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => estimate(
          openings: [
            OpeningDeduction(
              name: 'Door',
              widthMetres: 1,
              heightMetres: invalid,
              quantity: 1,
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => PlasterProductivity.siteSpecific(
          masonDaysPer10M2: invalid,
          helperDaysPer10M2: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => PlasterProductivity.siteSpecific(
          masonDaysPer10M2: 1,
          helperDaysPer10M2: invalid,
        ),
        throwsArgumentError,
      );
      expect(
        () => ProductivityCalculator.calculate(
          quantity: 100,
          standard: ProductivityStandard(
            name: 'invalid',
            basis: 'test',
            daysPerBaseQuantity: {
              LabourRole.mason: invalid,
              LabourRole.helper: 1,
            },
          ),
          crew: {LabourRole.mason: 1, LabourRole.helper: 1},
        ),
        throwsArgumentError,
      );
    });
  }
  test('invalid quantities, crew, deductions and names are rejected', () {
    for (final value in [0, -1]) {
      expect(
        () => estimate(
          openings: [
            OpeningDeduction(
              name: 'Door',
              widthMetres: 1,
              heightMetres: 2,
              quantity: value,
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => OpeningCalculator.grossArea(
          lengthMetres: 1,
          heightMetres: 1,
          surfaces: value,
        ),
        throwsArgumentError,
      );
    }
    for (final count in [0, -1, 4, 100]) {
      expect(() => estimate(masons: count), throwsArgumentError);
      expect(() => estimate(helpers: count), throwsArgumentError);
    }
    expect(() => estimate(area: 1, openings: [door]), throwsArgumentError);
    expect(
      () => estimate(
        openings: [
          const OpeningDeduction(
            name: ' ',
            widthMetres: 1,
            heightMetres: 1,
            quantity: 1,
          ),
        ],
      ),
      throwsArgumentError,
    );
    for (final value in [-1.0, double.nan, double.infinity]) {
      expect(() => estimate(wastage: value), throwsArgumentError);
    }
    expect(
      () => estimate(area: 1e308, thickness: 20, sandRate: 1e308),
      throwsArgumentError,
    );
  });
}
