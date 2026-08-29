import '../models/plaster_result.dart';

class PlasterCalculator {
  static const _dryFactor = 1.33,
      _cementDensity = 1440.0,
      _bagWeight = 50.0,
      _brassM3 = 2.8316846592;

  static PlasterResult calculate({
    required double area,
    required double thicknessMm,
    required double cementPart,
    required double sandPart,
    required double wastagePercent,
  }) {
    final wet = area * thicknessMm / 1000;
    final dry = wet * _dryFactor;
    final materials = dry * (1 + wastagePercent / 100);
    final total = cementPart + sandPart;
    final cementBags =
        materials * cementPart / total * _cementDensity / _bagWeight;
    final sand = materials * sandPart / total;
    return PlasterResult(
      area: area,
      wetVolume: wet,
      dryVolume: dry,
      cementBags: cementBags,
      sandM3: sand,
      sandBrass: sand / _brassM3,
    );
  }
}
