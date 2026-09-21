import 'productivity_standard.dart';

enum WaterTankType { rectangular, circular }

class WaterTankInput {
  const WaterTankInput({
    required this.type,
    required this.internalLength,
    required this.internalWidthOrDiameter,
    required this.waterDepth,
    required this.wallThickness,
    required this.baseSlabThickness,
    required this.topSlabThickness,
    required this.quantity,
    required this.rccRatePerCubicMetre,
    required this.masonDaysPerCubicMetre,
    required this.helperDaysPerCubicMetre,
    required this.crew,
    required this.dailyWages,
  });

  final WaterTankType type;
  final double internalLength, internalWidthOrDiameter, waterDepth;
  final double wallThickness, baseSlabThickness, topSlabThickness;
  final int quantity;
  final double rccRatePerCubicMetre;
  final double masonDaysPerCubicMetre, helperDaysPerCubicMetre;
  final Map<LabourRole, int> crew;
  final Map<LabourRole, double> dailyWages;
}
