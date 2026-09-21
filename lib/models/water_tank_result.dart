import 'productivity_standard.dart';
import 'water_tank_input.dart';

class WaterTankResult {
  const WaterTankResult({
    required this.input,
    required this.outerLength,
    required this.outerWidthOrDiameter,
    required this.baseSlabVolume,
    required this.wallVolume,
    required this.topSlabVolume,
    required this.totalRccVolume,
    required this.materialCost,
    required this.productivity,
    required this.labour,
    required this.totalCost,
  });

  final WaterTankInput input;
  final double outerLength, outerWidthOrDiameter;
  final double baseSlabVolume, wallVolume, topSlabVolume, totalRccVolume;
  final double materialCost, totalCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;

  double? get costPerCubicMetre =>
      totalRccVolume == 0 ? null : totalCost / totalRccVolume;
}
