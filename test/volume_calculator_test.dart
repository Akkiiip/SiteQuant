import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/services/concrete_calculator.dart';
import 'package:site_quant/services/volume_calculator.dart';

void main() {
  test('common structure volumes use their expected dimensions', () {
    expect(
      VolumeCalculator.slab(length: 2, width: 3, thickness: 0.2),
      closeTo(1.2, 0.0001),
    );
    expect(
      VolumeCalculator.beam(length: 4, width: 0.3, depth: 0.5),
      closeTo(0.6, 0.0001),
    );
    expect(
      VolumeCalculator.column(length: 0.3, breadth: 0.4, height: 3, number: 2),
      closeTo(0.72, 0.0001),
    );
    expect(
      VolumeCalculator.footing(length: 2, width: 2, depth: 0.4, number: 2),
      closeTo(3.2, 0.0001),
    );
  });

  test('circular structures use the existing pi-based volume methods', () {
    expect(
      VolumeCalculator.circularColumn(diameter: 2, height: 3, number: 2),
      closeTo(6 * pi, 0.0001),
    );
    expect(
      VolumeCalculator.circularFooting(diameter: 2, depth: 0.4, number: 1),
      closeTo(0.4 * pi, 0.0001),
    );
  });

  test('non-zero structure volumes generate non-zero material quantities', () {
    final volumes = [
      VolumeCalculator.slab(length: 2, width: 3, thickness: 0.2),
      VolumeCalculator.beam(length: 4, width: 0.3, depth: 0.5),
      VolumeCalculator.footing(length: 2, width: 2, depth: 0.4, number: 2),
      VolumeCalculator.circularFooting(diameter: 2, depth: 0.4, number: 1),
      VolumeCalculator.column(length: 0.3, breadth: 0.4, height: 3, number: 2),
      VolumeCalculator.circularColumn(diameter: 2, height: 3, number: 2),
    ];

    for (final volume in volumes) {
      final result = ConcreteCalculator.calculate(
        volume: volume,
        grade: 'M20',
        wcRatio: 0.45,
      );

      expect(result.cementBags, greaterThan(0));
      expect(result.sandM3, greaterThan(0));
      expect(result.aggregateM3, greaterThan(0));
      expect(result.waterLitres, greaterThan(0));
    }
  });
}
