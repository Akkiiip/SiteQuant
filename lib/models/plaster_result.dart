import 'opening_deduction.dart';
import 'productivity_standard.dart';

enum PlasterType { wall, ceiling }

extension PlasterTypeLabel on PlasterType {
  String get label =>
      this == PlasterType.wall ? 'Wall Plaster' : 'Ceiling Plaster';
}

class PlasterResult {
  final AreaTakeoff takeoff;
  final double thicknessMm, cementPart, sandPart, wastagePercent;
  final double wetVolume, dryVolume, cementBags, sandM3, sandBrass;
  final double cementRate, sandRate, cementCost, sandCost, materialCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;
  final double totalCost;
  final double? costPerSquareMetre;

  double get area => takeoff.netArea;
  double get grossArea => takeoff.grossArea;
  double get deductionArea => takeoff.deductionArea;

  const PlasterResult({
    required this.takeoff,
    required this.thicknessMm,
    required this.cementPart,
    required this.sandPart,
    required this.wastagePercent,
    required this.wetVolume,
    required this.dryVolume,
    required this.cementBags,
    required this.sandM3,
    required this.sandBrass,
    required this.cementRate,
    required this.sandRate,
    required this.cementCost,
    required this.sandCost,
    required this.materialCost,
    required this.productivity,
    required this.labour,
    required this.totalCost,
    required this.costPerSquareMetre,
  });
}
