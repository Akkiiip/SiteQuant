import '../models/concrete_result.dart';

class ConcreteCalculator {
  static const double dryVolumeFactor = 1.54;
  static const double cementDensity = 1440.0; // kg/m³
  static const double bagWeight = 50.0; // kg
  static const double brassConversion = 2.83; // 1 Brass = 2.83 m³

  static final Map<String, List<double>> mixRatios = {
    'M5': [1, 5, 10],
    'M7.5': [1, 4, 8],
    'M10': [1, 3, 6],
    'M15': [1, 2, 4],
    'M20': [1, 1.5, 3],
    'M25': [1, 1, 2],
  };

  static bool supportsGrade(String grade) => mixRatios.containsKey(grade);

  static ConcreteResult calculate({
    required double volume,
    required String grade,
    required double wcRatio,
  }) {
    if (!supportsGrade(grade)) {
      throw Exception('Design Mix (M30 and above) is not supported yet.');
    }

    final ratio = mixRatios[grade]!;

    final cementPart = ratio[0];
    final sandPart = ratio[1];
    final aggregatePart = ratio[2];

    final totalParts = cementPart + sandPart + aggregatePart;

    final dryVolume = volume * dryVolumeFactor;

    final cementVolume = dryVolume * cementPart / totalParts;

    final sandVolume = dryVolume * sandPart / totalParts;

    final aggregateVolume = dryVolume * aggregatePart / totalParts;

    final cementKg = cementVolume * cementDensity;

    final cementBags = cementKg / bagWeight;

    final sandBrass = sandVolume / brassConversion;

    final aggregateBrass = aggregateVolume / brassConversion;

    final waterLitres = cementKg * wcRatio;

    return ConcreteResult(
      volume: volume,
      cementKg: cementKg,
      cementBags: cementBags,
      sandM3: sandVolume,
      sandBrass: sandBrass,
      aggregateM3: aggregateVolume,
      aggregateBrass: aggregateBrass,
      waterLitres: waterLitres,
    );
  }
}
