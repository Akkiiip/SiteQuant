import 'opening_deduction.dart';
import 'productivity_standard.dart';

enum PaintWorkType {
  interiorWalls,
  ceiling,
  exteriorWalls,
  texture,
  wood,
  metal,
  puttyOnly,
  primerOnly,
  paintOnly,
}

extension PaintWorkTypeDetails on PaintWorkType {
  String get label => switch (this) {
    PaintWorkType.interiorWalls => 'Interior Walls',
    PaintWorkType.ceiling => 'Ceiling',
    PaintWorkType.exteriorWalls => 'Exterior Walls',
    PaintWorkType.texture => 'Texture / Special Finish',
    PaintWorkType.wood => 'Wood',
    PaintWorkType.metal => 'Metal',
    PaintWorkType.puttyOnly => 'Putty Only',
    PaintWorkType.primerOnly => 'Primer Only',
    PaintWorkType.paintOnly => 'Interior Emulsion Only',
  };
  List<PaintMaterialKind> get materials => switch (this) {
    PaintWorkType.interiorWalls || PaintWorkType.ceiling => [
      PaintMaterialKind.putty,
      PaintMaterialKind.primer,
      PaintMaterialKind.paint,
    ],
    PaintWorkType.exteriorWalls => [
      PaintMaterialKind.primer,
      PaintMaterialKind.paint,
    ],
    PaintWorkType.texture => [PaintMaterialKind.texture],
    PaintWorkType.wood || PaintWorkType.metal => [PaintMaterialKind.coating],
    PaintWorkType.puttyOnly => [PaintMaterialKind.putty],
    PaintWorkType.primerOnly => [PaintMaterialKind.primer],
    PaintWorkType.paintOnly => [PaintMaterialKind.paint],
  };
}

enum PaintMaterialKind { putty, primer, paint, texture, coating }

enum PaintCoverageBasis { perCoat, completeOperation }

@Deprecated('Use PaintCoverageBasis and coverageCoats.')
enum PuttyCoverageBasis { perCoat, completeTwoCoats }

extension PaintMaterialDetails on PaintMaterialKind {
  String get label => switch (this) {
    PaintMaterialKind.putty => 'Putty',
    PaintMaterialKind.primer => 'Primer',
    PaintMaterialKind.paint => 'Paint',
    PaintMaterialKind.texture => 'Texture / Special Finish',
    PaintMaterialKind.coating => 'Wood / Metal Coating',
  };
  String get unit => switch (this) {
    PaintMaterialKind.putty || PaintMaterialKind.texture => 'kg',
    _ => 'L',
  };
  String get coverageLabel => switch (this) {
    PaintMaterialKind.putty => 'Coverage (m² / kg)',
    PaintMaterialKind.texture => 'Consumption (kg / m² / coat)',
    _ => 'Coverage (m² / L)',
  };
  bool get coverageIsConsumption => this == PaintMaterialKind.texture;
}

class PaintMaterialInput {
  const PaintMaterialInput({
    required this.kind,
    required this.coats,
    required this.coverage,
    required this.wastagePercent,
    required this.rate,
    this.coverageBasis,
    this.coverageCoats = 1,
    this.referenceLabel = 'Custom Product',
    this.referenceNote = 'User-entered product/site values.',
    this.puttyCoverageBasis = PuttyCoverageBasis.perCoat,
    this.puttyPackSizeKg,
  });
  final PaintMaterialKind kind;
  final int coats, coverageCoats;
  final double coverage, wastagePercent, rate;
  final PaintCoverageBasis? coverageBasis;
  final String referenceLabel, referenceNote;
  final PuttyCoverageBasis puttyCoverageBasis;
  final double? puttyPackSizeKg;
  PaintCoverageBasis get effectiveCoverageBasis =>
      coverageBasis ??
      (puttyCoverageBasis == PuttyCoverageBasis.completeTwoCoats
          ? PaintCoverageBasis.completeOperation
          : PaintCoverageBasis.perCoat);
  int get effectiveCoverageCoats =>
      coverageBasis == null &&
          puttyCoverageBasis == PuttyCoverageBasis.completeTwoCoats
      ? 2
      : coverageCoats;
}

class PaintMaterialEstimate {
  const PaintMaterialEstimate({
    required this.input,
    required this.baseQuantity,
    required this.wastageQuantity,
    required this.finalQuantity,
    required this.cost,
  });
  final PaintMaterialInput input;
  final double baseQuantity, wastageQuantity, finalQuantity, cost;
  int? get approximatePacks => input.puttyPackSizeKg == null
      ? null
      : (finalQuantity / input.puttyPackSizeKg!).ceil();
}

class PaintResult {
  const PaintResult({
    required this.workType,
    required this.takeoff,
    required this.materials,
    required this.materialCost,
    required this.productivity,
    required this.labour,
    required this.totalCost,
    required this.costPerSquareMetre,
  });
  final PaintWorkType workType;
  final AreaTakeoff takeoff;
  final List<PaintMaterialEstimate> materials;
  final double materialCost, totalCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;
  final double? costPerSquareMetre;
  double get grossArea => takeoff.grossArea;
  double get deductionArea => takeoff.deductionArea;
  double get netArea => takeoff.netArea;
  double? get costPerSquareFoot =>
      netArea <= 0 ? null : totalCost / (netArea * 10.763910416709722);
}
