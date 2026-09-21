import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/services/shuttering_calculator.dart';
import 'package:site_quant/services/shuttering_reference_defaults.dart';

void main() {
  ShutteringResult calculate({
    ShutteringType type = ShutteringType.column,
    double length = .3,
    double width = .4,
    double height = 3,
    int quantity = 2,
    int wallSides = 2,
    double wastage = 5,
    int carpenters = 1,
    int helpers = 1,
  }) => ShutteringCalculator.calculate(
    type: type,
    length: length,
    width: width,
    height: height,
    quantity: quantity,
    wallSides: wallSides,
    wastagePercent: wastage,
    materialRate: 100,
    carpenterDaysPer10M2: 1.2,
    helperDaysPer10M2: .9,
    crew: {LabourRole.carpenter: carpenters, LabourRole.helper: helpers},
    dailyWages: {LabourRole.carpenter: 1000, LabourRole.helper: 600},
  );

  test('column excludes top and bottom faces and applies quantity', () {
    final r = calculate();
    expect(r.contactArea, closeTo(8.4, .0001));
  });
  test('beam includes two sides and soffit only', () {
    final r = calculate(
      type: ShutteringType.beam,
      length: 5,
      width: .3,
      height: .5,
      quantity: 2,
    );
    expect(r.contactArea, closeTo(13, .0001));
  });
  test('footing includes side faces only', () {
    final r = calculate(
      type: ShutteringType.footing,
      length: 2,
      width: 1.5,
      height: .4,
      quantity: 3,
    );
    expect(r.contactArea, closeTo(8.4, .0001));
  });
  test('wall supports one and two shuttered sides', () {
    expect(
      calculate(
        type: ShutteringType.wall,
        length: 4,
        width: .2,
        height: 3,
        quantity: 2,
        wallSides: 1,
      ).contactArea,
      24,
    );
    expect(
      calculate(
        type: ShutteringType.wall,
        length: 4,
        width: .2,
        height: 3,
        quantity: 2,
        wallSides: 2,
      ).contactArea,
      48,
    );
  });
  test('slab uses soffit only', () {
    expect(
      calculate(
        type: ShutteringType.slab,
        length: 5,
        width: 4,
        height: 99,
        quantity: 2,
      ).contactArea,
      40,
    );
  });
  test('wastage material cost and project cost are calculated', () {
    final r = calculate();
    expect(r.panelArea, closeTo(8.82, .0001));
    expect(r.materialCost, closeTo(882, .0001));
    expect(r.totalCost, closeTo(r.materialCost + r.labour.totalCost, .0001));
    expect(r.costPerSquareMetre, closeTo(r.totalCost / r.contactArea, .0001));
  });
  test('mandays, role costs and controlling duration use crew', () {
    final r = calculate(
      type: ShutteringType.slab,
      length: 10,
      width: 10,
      height: 1,
      quantity: 1,
      carpenters: 2,
      helpers: 1,
    );
    expect(r.productivity.mandays[LabourRole.carpenter], 12);
    expect(r.productivity.mandays[LabourRole.helper], 9);
    expect(r.productivity.workingDays, 9);
    expect(r.labour.costs[LabourRole.carpenter], 12000);
    expect(r.labour.costs[LabourRole.helper], 5400);
    expect(r.labour.totalCost, 17400);
  });
  test('reference defaults are usable editable assumptions', () {
    final d = ShutteringReferenceDefaults.standard;
    expect(d.ratePerSquareMetre, greaterThan(0));
    expect(d.wastagePercent, greaterThanOrEqualTo(0));
    expect(d.carpenterDaysPer10M2, greaterThan(0));
    expect(d.helperDailyWage, greaterThan(0));
  });
  test(
    'invalid dimensions, quantity, crew, rates, wages and wall sides fail',
    () {
      expect(() => calculate(length: 0), throwsArgumentError);
      expect(() => calculate(quantity: 0), throwsArgumentError);
      expect(() => calculate(carpenters: 0), throwsArgumentError);
      expect(
        () => ShutteringCalculator.calculate(
          type: ShutteringType.column,
          length: 1,
          width: 1,
          height: 1,
          quantity: 1,
          wastagePercent: -1,
          materialRate: 1,
          carpenterDaysPer10M2: 1,
          helperDaysPer10M2: 1,
          crew: {LabourRole.carpenter: 1, LabourRole.helper: 1},
          dailyWages: {LabourRole.carpenter: 1, LabourRole.helper: 1},
        ),
        throwsArgumentError,
      );
      expect(
        () => calculate(type: ShutteringType.wall, wallSides: 3),
        throwsArgumentError,
      );
    },
  );
}
