import 'opening_deduction.dart';
import 'productivity_standard.dart';

enum TileWorkType { floorTiles, wallTiles, skirting }

extension TileWorkTypeDetails on TileWorkType {
  String get label => switch (this) {
    TileWorkType.floorTiles => 'Floor Tiles',
    TileWorkType.wallTiles => 'Wall Tiles',
    TileWorkType.skirting => 'Skirting',
  };
}

class TileMaterialEstimate {
  final String name;
  final double quantity;
  final String unit;
  final double rate;
  final double cost;

  const TileMaterialEstimate({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.cost,
  });
}

class TileResult {
  final TileWorkType workType;
  final AreaTakeoff takeoff;
  final double tileLengthMm;
  final double tileWidthMm;
  final double tileAreaSquareMetres;
  final double baseTileQuantity;
  final int tileQuantity;
  final double tileCoverageSquareMetres;
  final double tileWastagePercent;
  final List<TileMaterialEstimate> materials;
  final double materialCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;
  final double totalCost;
  final double? costPerSquareMetre;
  final String referenceNote;

  const TileResult({
    required this.workType,
    required this.takeoff,
    required this.tileLengthMm,
    required this.tileWidthMm,
    required this.tileAreaSquareMetres,
    required this.baseTileQuantity,
    required this.tileQuantity,
    required this.tileCoverageSquareMetres,
    required this.tileWastagePercent,
    required this.materials,
    required this.materialCost,
    required this.productivity,
    required this.labour,
    required this.totalCost,
    required this.costPerSquareMetre,
    required this.referenceNote,
  });

  double get grossArea => takeoff.grossArea;
  double get deductionArea => takeoff.deductionArea;
  double get netArea => takeoff.netArea;
}
