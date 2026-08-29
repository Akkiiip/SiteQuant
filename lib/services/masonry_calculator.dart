import '../models/masonry_result.dart';

class MasonryCalculator {
  static const double _cementDensity = 1440;
  static const double _bagWeight = 50;
  static const double _dryMortarFactor = 1.33;
  static const double _brassInM3 = 2.83;

  static MasonryResult calculate({
    required double length,
    required double height,
    required int walls,
    required double thicknessMm,
    required MasonryUnitSize unitSize,
    required double cementPart,
    required double sandPart,
    required double wastagePercent,
  }) {
    final wallArea = length * height * walls;
    final masonryVolume = wallArea * thicknessMm / 1000;
    final unit = _Dimensions(
      unitSize.lengthMm / 1000,
      unitSize.widthMm / 1000,
      unitSize.heightMm / 1000,
    );
    final nominal = _nominalDimensions(unit);
    final wastageFactor = 1 + wastagePercent / 100;
    final unitCount = (masonryVolume / _volume(nominal) * wastageFactor).ceil();
    final netMortarVolume =
        masonryVolume - unitCount / wastageFactor * _volume(unit);
    final mortarVolume =
        (netMortarVolume < 0 ? 0.0 : netMortarVolume) * wastageFactor;
    final dryMortar = mortarVolume * _dryMortarFactor;
    final totalParts = cementPart + sandPart;
    final cementKg = dryMortar * cementPart / totalParts * _cementDensity;
    final sandM3 = dryMortar * sandPart / totalParts;

    return MasonryResult(
      masonryVolume: masonryVolume,
      wallArea: wallArea,
      unitCount: unitCount,
      mortarVolume: mortarVolume,
      cementKg: cementKg,
      cementBags: cementKg / _bagWeight,
      sandM3: sandM3,
      sandBrass: sandM3 / _brassInM3,
    );
  }

  static _Dimensions _nominalDimensions(_Dimensions unit) =>
      _Dimensions(unit.length + 0.01, unit.width + 0.01, unit.height + 0.01);

  static double _volume(_Dimensions dimensions) =>
      dimensions.length * dimensions.width * dimensions.height;
}

class _Dimensions {
  final double length;
  final double width;
  final double height;

  const _Dimensions(this.length, this.width, this.height);
}
