import '../models/tile_result.dart';

class TileReferencePreset {
  final TileWorkType workType;
  final double tileLengthMm;
  final double tileWidthMm;
  final double tileWastagePercent;
  final double tileRatePerSquareMetre;
  final double adhesiveConsumptionKgPerSquareMetre;
  final double adhesiveWastagePercent;
  final double adhesiveRatePerKg;
  final double groutConsumptionKgPerSquareMetre;
  final double groutWastagePercent;
  final double groutRatePerKg;
  final double beddingThicknessMm;
  final double cementRatePerBag;
  final double sandRatePerCubicMetre;
  final double tileMasonDaysPer10M2;
  final double helperDaysPer10M2;
  final double tileMasonDailyWage;
  final double helperDailyWage;
  final String note;

  const TileReferencePreset({
    required this.workType,
    required this.tileLengthMm,
    required this.tileWidthMm,
    required this.tileWastagePercent,
    required this.tileRatePerSquareMetre,
    required this.adhesiveConsumptionKgPerSquareMetre,
    required this.adhesiveWastagePercent,
    required this.adhesiveRatePerKg,
    required this.groutConsumptionKgPerSquareMetre,
    required this.groutWastagePercent,
    required this.groutRatePerKg,
    required this.beddingThicknessMm,
    required this.cementRatePerBag,
    required this.sandRatePerCubicMetre,
    required this.tileMasonDaysPer10M2,
    required this.helperDaysPer10M2,
    required this.tileMasonDailyWage,
    required this.helperDailyWage,
    required this.note,
  });
}

/// Editable planning assumptions, not universal consumption, price, or output rates.
class TileReferenceDefaults {
  TileReferenceDefaults._();

  static TileReferencePreset forWorkType(TileWorkType type) {
    return TileReferencePreset(
      workType: type,
      tileLengthMm: type == TileWorkType.wallTiles ? 300 : 600,
      tileWidthMm: type == TileWorkType.wallTiles ? 600 : 600,
      tileWastagePercent: type == TileWorkType.skirting ? 10 : 7,
      tileRatePerSquareMetre: 850,
      adhesiveConsumptionKgPerSquareMetre: type == TileWorkType.wallTiles
          ? 4
          : 4.5,
      adhesiveWastagePercent: 5,
      adhesiveRatePerKg: 18,
      groutConsumptionKgPerSquareMetre: type == TileWorkType.wallTiles
          ? .3
          : .25,
      groutWastagePercent: 5,
      groutRatePerKg: 90,
      beddingThicknessMm: 20,
      cementRatePerBag: 450,
      sandRatePerCubicMetre: 1800,
      tileMasonDaysPer10M2: type == TileWorkType.wallTiles ? 1.5 : 1.25,
      helperDaysPer10M2: type == TileWorkType.wallTiles ? 1.0 : .9,
      tileMasonDailyWage: 1000,
      helperDailyWage: 650,
      note:
          'Reference estimate only. Adjust tile, adhesive, grout, bedding, productivity and wage assumptions for the selected product, pattern, substrate and local site conditions.',
    );
  }
}
