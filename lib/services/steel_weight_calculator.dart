import '../models/steel_weight_result.dart';

class SteelWeightCalculator {
  static const Map<int, double> unitWeights = {
    6: 0.222,
    8: 0.395,
    10: 0.617,
    12: 0.888,
    16: 1.580,
    20: 2.470,
    25: 3.850,
    28: 4.830,
    32: 6.310,
  };

  static SteelWeightResult calculate({required int diameter, required double barLength, required int barCount}) {
    final unitWeight = unitWeights[diameter]!;
    final weightPerBar = unitWeight * barLength;
    return SteelWeightResult(diameter: diameter, unitWeight: unitWeight, barLength: barLength, barCount: barCount, weightPerBar: weightPerBar, totalWeight: weightPerBar * barCount);
  }
}
