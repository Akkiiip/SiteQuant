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
    PaintWorkType.paintOnly => 'Paint Only',
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
    PaintMaterialKind.primer ||
    PaintMaterialKind.paint ||
    PaintMaterialKind.coating => 'L',
  };

  String get coverageLabel => switch (this) {
    PaintMaterialKind.putty => 'Coverage (m² / kg / coat)',
    PaintMaterialKind.primer ||
    PaintMaterialKind.paint ||
    PaintMaterialKind.coating => 'Coverage (m² / L / coat)',
    PaintMaterialKind.texture => 'Consumption (kg / m² / coat)',
  };

  bool get coverageIsConsumption => this == PaintMaterialKind.texture;
}

class PaintMaterialInput {
  final PaintMaterialKind kind;
  final int coats;
  final double coverage;
  final double wastagePercent, rate;

  const PaintMaterialInput({
    required this.kind,
    required this.coats,
    required this.coverage,
    required this.wastagePercent,
    required this.rate,
  });
}

class PaintMaterialEstimate {
  final PaintMaterialInput input;
  final double baseQuantity, wastageQuantity, finalQuantity, cost;

  const PaintMaterialEstimate({
    required this.input,
    required this.baseQuantity,
    required this.wastageQuantity,
    required this.finalQuantity,
    required this.cost,
  });
}

class PaintResult {
  final PaintWorkType workType;
  final AreaTakeoff takeoff;
  final List<PaintMaterialEstimate> materials;
  final double materialCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;
  final double totalCost;
  final double? costPerSquareMetre;

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

  double get grossArea => takeoff.grossArea;
  double get deductionArea => takeoff.deductionArea;
  double get netArea => takeoff.netArea;
}
