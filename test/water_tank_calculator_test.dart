import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/productivity_standard.dart';
import 'package:site_quant/models/water_tank_input.dart';
import 'package:site_quant/services/water_tank_calculator.dart';
import 'package:site_quant/services/water_tank_reference_defaults.dart';

void main() {
  WaterTankInput input({
    WaterTankType type = WaterTankType.rectangular,
    double length = 4,
    double widthOrDiameter = 3,
    double depth = 2,
    double wall = .2,
    double base = .25,
    double top = .15,
    int quantity = 1,
    int masons = 1,
    int helpers = 1,
  }) => WaterTankInput(
    type: type,
    internalLength: type == WaterTankType.circular ? widthOrDiameter : length,
    internalWidthOrDiameter: widthOrDiameter,
    waterDepth: depth,
    wallThickness: wall,
    baseSlabThickness: base,
    topSlabThickness: top,
    quantity: quantity,
    rccRatePerCubicMetre: 100,
    masonDaysPerCubicMetre: 1.2,
    helperDaysPerCubicMetre: 1.5,
    crew: {LabourRole.mason: masons, LabourRole.helper: helpers},
    dailyWages: {LabourRole.mason: 900, LabourRole.helper: 600},
  );

  test(
    'rectangular tank derives outer dimensions and separate RCC volumes',
    () {
      final result = WaterTankCalculator.calculate(input());
      expect(result.outerLength, 4.4);
      expect(result.outerWidthOrDiameter, 3.4);
      expect(result.baseSlabVolume, closeTo(3.74, .000001));
      expect(result.wallVolume, closeTo(5.92, .000001));
      expect(result.topSlabVolume, closeTo(2.244, .000001));
      expect(result.totalRccVolume, closeTo(11.904, .000001));
    },
  );

  test('quantity multiplies RCC, material and labour requirements', () {
    final one = WaterTankCalculator.calculate(input());
    final two = WaterTankCalculator.calculate(input(quantity: 2));
    expect(two.totalRccVolume, closeTo(one.totalRccVolume * 2, .000001));
    expect(two.materialCost, closeTo(one.materialCost * 2, .000001));
    expect(
      two.productivity.mandays[LabourRole.mason],
      closeTo(one.productivity.mandays[LabourRole.mason]! * 2, .000001),
    );
  });

  test(
    'rectangular material, labour, duration, total and unit cost are transparent',
    () {
      final result = WaterTankCalculator.calculate(input());
      expect(result.materialCost, closeTo(1190.4, .000001));
      expect(
        result.productivity.mandays[LabourRole.mason],
        closeTo(14.2848, .000001),
      );
      expect(
        result.productivity.mandays[LabourRole.helper],
        closeTo(17.856, .000001),
      );
      expect(result.productivity.workingDays, closeTo(17.856, .000001));
      expect(result.labour.costs[LabourRole.mason], closeTo(12856.32, .000001));
      expect(result.labour.costs[LabourRole.helper], closeTo(10713.6, .000001));
      expect(result.totalCost, closeTo(24760.32, .000001));
      expect(
        result.costPerCubicMetre,
        closeTo(result.totalCost / result.totalRccVolume, .000001),
      );
    },
  );

  test('larger crew reduces duration using the controlling role', () {
    final one = WaterTankCalculator.calculate(input());
    final two = WaterTankCalculator.calculate(input(masons: 2, helpers: 2));
    expect(
      two.productivity.workingDays,
      closeTo(one.productivity.workingDays / 2, .000001),
    );
  });

  test('circular tank uses outer diameter and annular wall geometry', () {
    final result = WaterTankCalculator.calculate(
      input(type: WaterTankType.circular, widthOrDiameter: 3, depth: 2),
    );
    final outerArea = math.pi * 3.4 * 3.4 / 4;
    final innerArea = math.pi * 3 * 3 / 4;
    expect(result.outerWidthOrDiameter, 3.4);
    expect(result.baseSlabVolume, closeTo(outerArea * .25, .000001));
    expect(result.wallVolume, closeTo((outerArea - innerArea) * 2, .000001));
    expect(result.topSlabVolume, closeTo(outerArea * .15, .000001));
    expect(
      result.totalRccVolume,
      closeTo(
        result.baseSlabVolume + result.wallVolume + result.topSlabVolume,
        .000001,
      ),
    );
  });

  test('reference defaults are usable editable assumptions', () {
    const defaults = WaterTankReferenceDefaults.standard;
    expect(defaults.rccRatePerCubicMetre, greaterThan(0));
    expect(defaults.masonDaysPerCubicMetre, greaterThan(0));
    expect(defaults.helperDailyWage, greaterThan(0));
  });

  test(
    'invalid dimensions, thickness, quantity, crew, rate, wage and productivity fail',
    () {
      expect(
        () => WaterTankCalculator.calculate(input(length: 0)),
        throwsArgumentError,
      );
      expect(
        () => WaterTankCalculator.calculate(input(wall: 0)),
        throwsArgumentError,
      );
      expect(
        () => WaterTankCalculator.calculate(input(quantity: 0)),
        throwsArgumentError,
      );
      final invalid = input();
      expect(
        () => WaterTankCalculator.calculate(
          WaterTankInput(
            type: invalid.type,
            internalLength: invalid.internalLength,
            internalWidthOrDiameter: invalid.internalWidthOrDiameter,
            waterDepth: invalid.waterDepth,
            wallThickness: invalid.wallThickness,
            baseSlabThickness: invalid.baseSlabThickness,
            topSlabThickness: invalid.topSlabThickness,
            quantity: invalid.quantity,
            rccRatePerCubicMetre: -1,
            masonDaysPerCubicMetre: invalid.masonDaysPerCubicMetre,
            helperDaysPerCubicMetre: invalid.helperDaysPerCubicMetre,
            crew: {LabourRole.mason: 0, LabourRole.helper: 1},
            dailyWages: {LabourRole.mason: 0, LabourRole.helper: 1},
          ),
        ),
        throwsArgumentError,
      );
    },
  );
}
