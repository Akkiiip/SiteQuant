import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/services/masonry_calculator.dart';

void main() {
  test('brickwork calculation returns expected core quantities', () {
    final result = MasonryCalculator.calculate(
      length: 4,
      height: 3,
      walls: 1,
      thicknessMm: 230,
      unitSize: const MasonryUnitSize(
        lengthMm: 190,
        widthMm: 90,
        heightMm: 90,
      ),
      cementPart: 1,
      sandPart: 6,
      wastagePercent: 5,
    );
    expect(result.masonryVolume, closeTo(2.76, .0001));
    expect(result.wallArea, closeTo(12, .0001));
    expect(result.unitCount, greaterThan(0));
    expect(result.mortarVolume, greaterThan(0));
    expect(result.cementBags, greaterThan(0));
  });
}
