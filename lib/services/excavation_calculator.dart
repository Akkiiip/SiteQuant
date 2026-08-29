import '../models/excavation_result.dart';
import 'volume_calculator.dart';

class ExcavationCalculator {
  static ExcavationResult rectangular({
    required double length,
    required double width,
    required double depth,
  }) => ExcavationResult(
    volume: VolumeCalculator.cuboid(
      length: length,
      width: width,
      height: depth,
    ),
  );
  static ExcavationResult trench({
    required double length,
    required double width,
    required double depth,
  }) => rectangular(length: length, width: width, depth: depth);
  static ExcavationResult circularPit({
    required double diameter,
    required double depth,
  }) => ExcavationResult(
    volume: VolumeCalculator.circularFooting(
      diameter: diameter,
      depth: depth,
      number: 1,
    ),
  );
  static ExcavationResult custom({required double volume}) =>
      ExcavationResult(volume: VolumeCalculator.custom(volume: volume));
}
